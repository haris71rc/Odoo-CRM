package com.bigoh.odoocrm.callrecording.transcription

import android.content.Context
import android.media.AudioFormat
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.net.Uri
import android.util.Log
import com.bigoh.odoocrm.callrecording.CallRecordingConfig
import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * Streams decoded PCM from a MediaStore content URI using MediaExtractor + MediaCodec.
 */
class MediaStoreAudioDecoder(private val context: Context) {
    data class SourceAudioInfo(
        val mimeType: String,
        val sampleRate: Int,
        val channelCount: Int,
        val isFloat: Boolean,
    )

    class DecodeSession internal constructor(
        internal val extractor: MediaExtractor,
        internal val codec: MediaCodec,
        internal var sourceInfo: SourceAudioInfo,
        internal var inputDone: Boolean = false,
        internal var outputDone: Boolean = false,
    )

    fun open(uri: Uri, mimeTypeHint: String?): DecodeSession {
        val extractor = MediaExtractor()
        try {
            extractor.setDataSource(context, uri, null)
        } catch (e: Exception) {
            extractor.release()
            throw RecordingAccessException("Unable to open recording URI.", e)
        }

        val trackIndex = selectAudioTrack(extractor)
        if (trackIndex < 0) {
            extractor.release()
            throw UnsupportedAudioFormatException("No audio track found in recording.")
        }

        extractor.selectTrack(trackIndex)
        val trackFormat = extractor.getTrackFormat(trackIndex)
        val mime = trackFormat.getString(MediaFormat.KEY_MIME)
            ?: mimeTypeHint
            ?: throw UnsupportedAudioFormatException("Missing audio MIME type.")

        val codec = try {
            MediaCodec.createDecoderByType(mime)
        } catch (e: Exception) {
            extractor.release()
            throw UnsupportedAudioFormatException("Unsupported audio codec: $mime", e)
        }

        codec.configure(trackFormat, null, null, 0)
        codec.start()

        val sampleRate = trackFormat.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        val channelCount = trackFormat.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        val pcmEncoding = if (trackFormat.containsKey(MediaFormat.KEY_PCM_ENCODING)) {
            trackFormat.getInteger(MediaFormat.KEY_PCM_ENCODING)
        } else {
            AudioFormat.ENCODING_PCM_16BIT
        }

        val sourceInfo = SourceAudioInfo(
            mimeType = mime,
            sampleRate = sampleRate,
            channelCount = channelCount,
            isFloat = pcmEncoding == AudioFormat.ENCODING_PCM_FLOAT,
        )

        Log.i(
            CallRecordingConfig.TAG,
            "Original audio: sampleRate=$sampleRate channels=$channelCount mimeType=$mime " +
                "encoding=${if (sourceInfo.isFloat) "FLOAT" else "PCM_16BIT"}",
        )

        return DecodeSession(extractor, codec, sourceInfo)
    }

    /**
     * Reads the next chunk of decoded PCM bytes, or null when decoding is complete.
     */
    fun readDecodedPcm(session: DecodeSession): ByteArray? {
        if (session.outputDone) return null

        val timeoutUs = 10_000L
        if (!session.inputDone) {
            val inputIndex = session.codec.dequeueInputBuffer(timeoutUs)
            if (inputIndex >= 0) {
                val inputBuffer = session.codec.getInputBuffer(inputIndex) ?: ByteBuffer.allocate(0)
                val sampleSize = session.extractor.readSampleData(inputBuffer, 0)
                if (sampleSize < 0) {
                    session.codec.queueInputBuffer(
                        inputIndex,
                        0,
                        0,
                        0,
                        MediaCodec.BUFFER_FLAG_END_OF_STREAM,
                    )
                    session.inputDone = true
                } else {
                    session.codec.queueInputBuffer(
                        inputIndex,
                        0,
                        sampleSize,
                        session.extractor.sampleTime,
                        0,
                    )
                    session.extractor.advance()
                }
            }
        }

        val bufferInfo = MediaCodec.BufferInfo()
        val outputIndex = session.codec.dequeueOutputBuffer(bufferInfo, timeoutUs)
        when {
            outputIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                updateOutputFormat(session)
                return readDecodedPcm(session)
            }
            outputIndex >= 0 -> {
                if (bufferInfo.size <= 0) {
                    session.codec.releaseOutputBuffer(outputIndex, false)
                    if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                        session.outputDone = true
                    }
                    return readDecodedPcm(session)
                }

                val outputBuffer = session.codec.getOutputBuffer(outputIndex)
                    ?: ByteBuffer.allocate(0)
                val pcm = ByteArray(bufferInfo.size)
                outputBuffer.position(bufferInfo.offset)
                outputBuffer.limit(bufferInfo.offset + bufferInfo.size)
                outputBuffer.get(pcm)
                session.codec.releaseOutputBuffer(outputIndex, false)

                if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                    session.outputDone = true
                }
                return pcm
            }
            else -> return if (session.inputDone) null else ByteArray(0)
        }
    }

    fun release(session: DecodeSession) {
        try {
            session.codec.stop()
        } catch (_: Exception) {
        }
        try {
            session.codec.release()
        } catch (_: Exception) {
        }
        try {
            session.extractor.release()
        } catch (_: Exception) {
        }
    }

    private fun updateOutputFormat(session: DecodeSession) {
        val format = session.codec.outputFormat
        val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        val channelCount = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        val pcmEncoding = if (format.containsKey(MediaFormat.KEY_PCM_ENCODING)) {
            format.getInteger(MediaFormat.KEY_PCM_ENCODING)
        } else {
            AudioFormat.ENCODING_PCM_16BIT
        }
        session.sourceInfo = session.sourceInfo.copy(
            sampleRate = sampleRate,
            channelCount = channelCount,
            isFloat = pcmEncoding == AudioFormat.ENCODING_PCM_FLOAT,
        )
    }

    private fun selectAudioTrack(extractor: MediaExtractor): Int {
        for (i in 0 until extractor.trackCount) {
            val format = extractor.getTrackFormat(i)
            val mime = format.getString(MediaFormat.KEY_MIME) ?: continue
            if (mime.startsWith("audio/")) return i
        }
        return -1
    }

    /** Convenience helper for tests/logging. */
    fun readShortSamples(pcmBytes: ByteArray): ShortArray {
        val buffer = ByteBuffer.wrap(pcmBytes).order(ByteOrder.LITTLE_ENDIAN)
        val count = pcmBytes.size / 2
        return ShortArray(count) { buffer.short }
    }
}

class RecordingAccessException(message: String, cause: Throwable? = null) :
    Exception(message, cause)

class UnsupportedAudioFormatException(message: String, cause: Throwable? = null) :
    Exception(message, cause)

class AudioDecodeException(message: String, cause: Throwable? = null) :
    Exception(message, cause)

class AudioConversionException(message: String, cause: Throwable? = null) :
    Exception(message, cause)
