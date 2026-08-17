package com.bigoh.odoocrm.callrecording.transcription

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.core.content.ContextCompat
import com.bigoh.odoocrm.callrecording.CallRecordingConfig
import com.google.mlkit.genai.common.DownloadStatus
import com.google.mlkit.genai.common.FeatureStatus
import com.google.mlkit.genai.common.audio.AudioSource
import com.google.mlkit.genai.speechrecognition.SpeechRecognition
import com.google.mlkit.genai.speechrecognition.SpeechRecognizer
import com.google.mlkit.genai.speechrecognition.SpeechRecognizerOptions
import com.google.mlkit.genai.speechrecognition.SpeechRecognizerResponse
import com.google.mlkit.genai.speechrecognition.speechRecognizerOptions
import com.google.mlkit.genai.speechrecognition.speechRecognizerRequest
import java.util.Locale
import java.util.concurrent.atomic.AtomicBoolean
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.NonCancellable
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancelAndJoin
import kotlinx.coroutines.flow.takeWhile
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Converts a MediaStore recording to real-time PCM and transcribes it with ML Kit.
 */
class CallRecordingTranscriber(
    private val context: Context,
    private val callbacks: Callbacks,
) {
    interface Callbacks {
        fun onStatus(leadId: Long, status: String)
        fun onPartialTranscript(leadId: Long, text: String)
        fun onFinalTranscript(leadId: Long, text: String)
        fun onComplete(leadId: Long, transcript: String)
        fun onError(leadId: Long, code: String, message: String)
    }

    data class Request(
        val leadId: Long,
        val uri: String,
        val name: String?,
        val mimeType: String?,
        val languageTag: String = DEFAULT_LANGUAGE_TAG,
    )

    private val jobSupervisor = SupervisorJob()
    private val scope = CoroutineScope(jobSupervisor + Dispatchers.IO)
    private var activeJob: Job? = null
    private val cancelled = AtomicBoolean(false)
    private var speechRecognizer: SpeechRecognizer? = null
    private var pcmPipe: RealtimePcmPipe? = null
    private var decodeSession: MediaStoreAudioDecoder.DecodeSession? = null
    private val decoder = MediaStoreAudioDecoder(context)

    fun transcribe(request: Request) {
        cancelled.set(false)

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            callbacks.onError(
                request.leadId,
                "SPEECH_RECOGNITION_UNAVAILABLE",
                "On-device speech recognition requires Android 12 (API 31) or higher.",
            )
            return
        }

        val previousJob = activeJob
        activeJob = scope.launch {
            try {
                previousJob?.cancelAndJoin()
            } catch (_: CancellationException) {
                // Expected when replacing an in-flight transcription.
            }
            releaseResources()
            runTranscription(request)
        }
    }

    fun cancel() {
        cancelled.set(true)
        activeJob?.cancel()
    }

    private suspend fun releaseResources() {
        pcmPipe?.cancel()
        decodeSession?.let { decoder.release(it) }
        decodeSession = null
        try {
            speechRecognizer?.stopRecognition()
        } catch (_: Exception) {
        }
        try {
            speechRecognizer?.close()
        } catch (_: Exception) {
        }
        speechRecognizer = null
        pcmPipe = null
    }

    private suspend fun runTranscription(request: Request) {
        val leadId = request.leadId
        var session: MediaStoreAudioDecoder.DecodeSession? = null

        try {
            callbacks.onStatus(leadId, "preparingAudio")
            Log.i(
                CallRecordingConfig.TAG,
                "Transcription starting uri=${request.uri} name=${request.name} " +
                    "mimeType=${request.mimeType}",
            )

            if (!hasRecordAudioPermission()) {
                callbacks.onError(
                    leadId,
                    "SPEECH_RECOGNITION_PERMISSION_DENIED",
                    "Microphone permission is required for on-device speech recognition.",
                )
                return
            }

            val locale = parseLocale(request.languageTag)
            val recognizer = createSpeechRecognizer(locale)
            speechRecognizer = recognizer

            ensureFeatureReady(recognizer)

            callbacks.onStatus(leadId, "convertingAudio")
            val uri = Uri.parse(request.uri)
            session = decoder.open(uri, request.mimeType)
            decodeSession = session

            val sourceFormat = PcmAudioProcessor.SourceFormat(
                sampleRate = session.sourceInfo.sampleRate,
                channelCount = session.sourceInfo.channelCount,
                isFloat = session.sourceInfo.isFloat,
            )

            val outputFormat = PcmAudioProcessor.OutputFormat()
            Log.i(
                CallRecordingConfig.TAG,
                "Converted audio target: sampleRate=${outputFormat.sampleRate} " +
                    "channels=${outputFormat.channelCount} encoding=${outputFormat.encoding}",
            )

            val activeSession = session
            val pipe = RealtimePcmPipe()
            pcmPipe = pipe

            pipe.startWriting(
                PcmChunkProducer {
                    if (cancelled.get()) return@PcmChunkProducer null

                    val decoded = try {
                        decoder.readDecodedPcm(activeSession)
                    } catch (e: Exception) {
                        throw AudioDecodeException("Unable to decode recording.", e)
                    }

                    if (decoded == null) return@PcmChunkProducer null
                    if (decoded.isEmpty()) return@PcmChunkProducer ByteArray(0)

                    val processed = try {
                        PcmAudioProcessor.toMonoPcm16(sourceFormat, decoded)
                    } catch (e: Exception) {
                        throw AudioConversionException("Audio conversion failed.", e)
                    }

                    if (processed.isEmpty()) return@PcmChunkProducer ByteArray(0)
                    PcmAudioProcessor.shortsToBytes(processed)
                },
            )

            callbacks.onStatus(leadId, "transcribing")
            Log.i(CallRecordingConfig.TAG, "Starting ML Kit recognition...")

            val mlRequest = speechRecognizerRequest {
                audioSource = AudioSource.fromPfd(pipe.readEnd)
            }

            val transcriptBuilder = StringBuilder()
            var latestPartial = ""

            fun commitPartialIfNeeded() {
                val pending = latestPartial.trim()
                if (pending.isEmpty()) return
                if (transcriptBuilder.isNotEmpty()) transcriptBuilder.append(' ')
                transcriptBuilder.append(pending)
                callbacks.onFinalTranscript(leadId, pending)
                latestPartial = ""
            }

            try {
                var continueRecognition = true
                recognizer.startRecognition(mlRequest)
                    .takeWhile { continueRecognition }
                    .collect { response ->
                        if (cancelled.get()) {
                            continueRecognition = false
                            return@collect
                        }
                        when (response) {
                            is SpeechRecognizerResponse.PartialTextResponse -> {
                                val next = response.text
                                if (latestPartial.isNotBlank() &&
                                    !isSameUtterance(latestPartial, next)
                                ) {
                                    commitPartialIfNeeded()
                                }
                                latestPartial = next
                                Log.d(CallRecordingConfig.TAG, "Partial: \"$next\"")
                                callbacks.onPartialTranscript(leadId, next)
                            }
                            is SpeechRecognizerResponse.FinalTextResponse -> {
                                Log.i(
                                    CallRecordingConfig.TAG,
                                    "Final segment: \"${response.text}\"",
                                )
                                latestPartial = ""
                                val segment = response.text.trim()
                                if (segment.isNotEmpty()) {
                                    if (transcriptBuilder.isNotEmpty()) transcriptBuilder.append(' ')
                                    transcriptBuilder.append(segment)
                                    callbacks.onFinalTranscript(leadId, response.text)
                                }
                            }
                            is SpeechRecognizerResponse.CompletedResponse -> {
                                Log.i(CallRecordingConfig.TAG, "Recognition completed")
                            }
                            is SpeechRecognizerResponse.ErrorResponse -> {
                                val message = response.e.message ?: "Speech recognition failed."
                                if (message.contains("INSUFFICIENT_PERMISSION", ignoreCase = true)) {
                                    throw SpeechRecognitionException(
                                        "Microphone permission is required for on-device speech recognition.",
                                        response.e.errorCode,
                                        insufficientPermission = true,
                                    )
                                }
                                if (isBenignEndOfSpeech(message)) {
                                    Log.i(
                                        CallRecordingConfig.TAG,
                                        "ML Kit end-of-speech: $message — completing with captured text",
                                    )
                                    continueRecognition = false
                                    return@collect
                                }
                                throw SpeechRecognitionException(
                                    message,
                                    response.e.errorCode,
                                )
                            }
                        }
                    }
            } catch (e: SpeechRecognitionException) {
                throw e
            } catch (e: Exception) {
                val message = e.message.orEmpty()
                if (!isBenignEndOfSpeech(message)) throw e
                Log.i(
                    CallRecordingConfig.TAG,
                    "ML Kit closed after audio ended: $message — completing with captured text",
                )
            }

            commitPartialIfNeeded()
            pipe.awaitCompletion()

            val finalTranscript = transcriptBuilder.toString().trim()
            Log.i(
                CallRecordingConfig.TAG,
                "Transcription complete (${finalTranscript.length} chars)",
            )
            callbacks.onComplete(leadId, finalTranscript)
        } catch (e: CancellationException) {
            Log.i(CallRecordingConfig.TAG, "Transcription cancelled")
            throw e
        } catch (e: RecordingAccessException) {
            callbacks.onError(leadId, "RECORDING_ACCESS_ERROR", e.message ?: "Unable to open recording.")
        } catch (e: UnsupportedAudioFormatException) {
            callbacks.onError(leadId, "UNSUPPORTED_AUDIO_FORMAT", e.message ?: "Unsupported audio format.")
        } catch (e: AudioDecodeException) {
            callbacks.onError(leadId, "AUDIO_DECODE_ERROR", e.message ?: "Unable to decode recording.")
        } catch (e: AudioConversionException) {
            callbacks.onError(leadId, "AUDIO_CONVERSION_ERROR", e.message ?: "Audio conversion failed.")
        } catch (e: SpeechInitException) {
            val code = if (e.message?.contains("downloading", ignoreCase = true) == true ||
                e.message?.contains("not available", ignoreCase = true) == true
            ) {
                "SPEECH_RECOGNITION_UNAVAILABLE"
            } else {
                "SPEECH_RECOGNITION_INIT_ERROR"
            }
            callbacks.onError(
                leadId,
                code,
                e.message ?: "Unable to initialize on-device speech recognition.",
            )
        } catch (e: SpeechRecognitionException) {
            if (e.insufficientPermission) {
                callbacks.onError(
                    leadId,
                    "SPEECH_RECOGNITION_PERMISSION_DENIED",
                    e.message ?: "Microphone permission is required.",
                )
            } else if (isBenignEndOfSpeech(e.message.orEmpty())) {
                Log.i(CallRecordingConfig.TAG, "Treating end-of-speech as empty transcript")
                callbacks.onComplete(leadId, "")
            } else {
                callbacks.onError(
                    leadId,
                    "SPEECH_RECOGNITION_ERROR",
                    e.message ?: "Speech recognition failed.",
                )
            }
        } catch (e: Exception) {
            Log.e(CallRecordingConfig.TAG, "Transcription failed", e)
            callbacks.onError(
                leadId,
                "SPEECH_RECOGNITION_ERROR",
                e.message ?: "Speech recognition failed.",
            )
        } finally {
            withContext(NonCancellable) {
                pcmPipe?.closeReadEnd()
                releaseResources()
            }
        }
    }

    private suspend fun ensureFeatureReady(recognizer: SpeechRecognizer) {
        val featureStatus = recognizer.checkStatus()
        Log.i(CallRecordingConfig.TAG, "ML Kit availability status=$featureStatus")
        when (featureStatus) {
            FeatureStatus.AVAILABLE -> return
            FeatureStatus.DOWNLOADABLE -> {
                recognizer.download().collect { status ->
                    when (status) {
                        is DownloadStatus.DownloadCompleted -> return@collect
                        is DownloadStatus.DownloadFailed -> {
                            throw SpeechInitException(
                                "On-device speech model download failed: ${status.e.message}",
                                status.e,
                            )
                        }
                        else -> Unit
                    }
                }
            }
            FeatureStatus.DOWNLOADING -> {
                throw SpeechInitException(
                    "On-device speech model is still downloading. Please try again shortly.",
                )
            }
            else -> {
                throw SpeechInitException(
                    "On-device speech recognition is not available on this device.",
                )
            }
        }
    }

    private fun createSpeechRecognizer(locale: Locale): SpeechRecognizer {
        return SpeechRecognition.getClient(
            speechRecognizerOptions {
                this.locale = locale
                preferredMode = SpeechRecognizerOptions.Mode.MODE_BASIC
            },
        )
    }

    private fun hasRecordAudioPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.RECORD_AUDIO,
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun isSameUtterance(previous: String, next: String): Boolean {
        val prev = previous.trim()
        val curr = next.trim()
        if (prev.isEmpty() || curr.isEmpty()) return true
        return curr.startsWith(prev) || prev.startsWith(curr)
    }

    private fun isBenignEndOfSpeech(message: String): Boolean {
        val lower = message.lowercase()
        return lower.contains("no_speech_detected") ||
            lower.contains("no speech detected")
    }

    private fun parseLocale(languageTag: String): Locale {
        val parsed = Locale.forLanguageTag(languageTag)
        return if (parsed.language.isNullOrBlank()) {
            Locale.forLanguageTag(DEFAULT_LANGUAGE_TAG)
        } else {
            parsed
        }
    }

    fun dispose() {
        cancel()
        jobSupervisor.cancel()
    }

    companion object {
        // Basic mode officially supports en-US; en-IN is used as app default.
        const val DEFAULT_LANGUAGE_TAG = "en-US"
    }
}

class SpeechInitException(message: String, cause: Throwable? = null) : Exception(message, cause)

class SpeechRecognitionException(
    message: String,
    val errorCode: Int = 0,
    val insufficientPermission: Boolean = false,
    cause: Throwable? = null,
) : Exception(message, cause)
