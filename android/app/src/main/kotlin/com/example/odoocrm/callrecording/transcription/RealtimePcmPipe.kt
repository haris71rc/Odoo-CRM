package com.bigoh.odoocrm.callrecording.transcription

import android.os.ParcelFileDescriptor
import android.os.SystemClock
import android.util.Log
import com.bigoh.odoocrm.callrecording.CallRecordingConfig
import java.io.IOException
import java.util.concurrent.atomic.AtomicBoolean

fun interface PcmChunkProducer {
    /** Returns the next PCM chunk, or null when production is finished. */
    fun nextChunk(): ByteArray?
}

/**
 * Writes PCM bytes into a pipe at approximately real-time speed for ML Kit custom audio input.
 */
class RealtimePcmPipe {
    companion object {
        const val BYTES_PER_SECOND = PcmResampler.TARGET_SAMPLE_RATE * 2 // mono PCM16
        const val CHUNK_BYTES = 4_096
        /** Trailing silence so ML Kit can emit a final segment before the pipe closes. */
        const val TRAILING_SILENCE_MS = 1_500L
    }

    private val pipe: Array<ParcelFileDescriptor> = ParcelFileDescriptor.createPipe()
    private val cancelled = AtomicBoolean(false)
    private var writerThread: Thread? = null

    val readEnd: ParcelFileDescriptor
        get() = pipe[0]

    fun startWriting(producer: PcmChunkProducer) {
        cancelled.set(false)
        writerThread = Thread {
            val output = ParcelFileDescriptor.AutoCloseOutputStream(pipe[1])
            var totalBytesWritten = 0L
            val startClock = SystemClock.elapsedRealtime()

            try {
                while (!cancelled.get()) {
                    val chunk = producer.nextChunk() ?: break
                    if (chunk.isEmpty()) continue

                    var offset = 0
                    while (offset < chunk.size && !cancelled.get()) {
                        val toWrite = minOf(CHUNK_BYTES, chunk.size - offset)
                        output.write(chunk, offset, toWrite)
                        output.flush()
                        offset += toWrite
                        totalBytesWritten += toWrite

                        val expectedElapsedMs =
                            (totalBytesWritten * 1000L) / BYTES_PER_SECOND
                        val actualElapsedMs = SystemClock.elapsedRealtime() - startClock
                        val sleepMs = expectedElapsedMs - actualElapsedMs
                        if (sleepMs > 0) {
                            SystemClock.sleep(sleepMs)
                        }
                    }
                }

                if (!cancelled.get()) {
                    writeTrailingSilence(output, startClock, totalBytesWritten)
                }
            } catch (e: IOException) {
                if (!cancelled.get()) {
                    Log.w(CallRecordingConfig.TAG, "Realtime PCM pipe write failed", e)
                }
            } finally {
                try {
                    output.close()
                } catch (_: Exception) {
                }
                try {
                    pipe[1].close()
                } catch (_: Exception) {
                }
            }
        }.also { it.start() }
    }

    private fun writeTrailingSilence(
        output: java.io.OutputStream,
        startClock: Long,
        bytesAlreadyWritten: Long,
    ) {
        val silenceBytes = ((TRAILING_SILENCE_MS * BYTES_PER_SECOND) / 1000L).toInt()
        if (silenceBytes <= 0) return

        Log.i(CallRecordingConfig.TAG, "Writing ${TRAILING_SILENCE_MS}ms trailing silence for ML Kit")
        val zeros = ByteArray(CHUNK_BYTES)
        var remaining = silenceBytes
        var totalBytesWritten = bytesAlreadyWritten
        while (remaining > 0 && !cancelled.get()) {
            val toWrite = minOf(CHUNK_BYTES, remaining)
            output.write(zeros, 0, toWrite)
            output.flush()
            remaining -= toWrite
            totalBytesWritten += toWrite

            val expectedElapsedMs = (totalBytesWritten * 1000L) / BYTES_PER_SECOND
            val actualElapsedMs = SystemClock.elapsedRealtime() - startClock
            val sleepMs = expectedElapsedMs - actualElapsedMs
            if (sleepMs > 0) {
                SystemClock.sleep(sleepMs)
            }
        }
    }

    fun cancel() {
        cancelled.set(true)
        writerThread?.interrupt()
        try {
            pipe[1].close()
        } catch (_: Exception) {
        }
    }

    fun awaitCompletion(timeoutMs: Long = 120_000L) {
        writerThread?.join(timeoutMs)
    }

    fun closeReadEnd() {
        try {
            pipe[0].close()
        } catch (_: Exception) {
        }
    }
}
