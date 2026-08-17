package com.bigoh.odoocrm.callrecording.transcription

import java.nio.ByteBuffer
import java.nio.ByteOrder

/**
 * Converts decoded PCM into ML Kit input format: 16 kHz, mono, signed 16-bit LE.
 */
object PcmAudioProcessor {
    data class SourceFormat(
        val sampleRate: Int,
        val channelCount: Int,
        val isFloat: Boolean,
    )

    data class OutputFormat(
        val sampleRate: Int = PcmResampler.TARGET_SAMPLE_RATE,
        val channelCount: Int = 1,
        val encoding: String = "PCM_16BIT",
    )

    fun toMonoPcm16(source: SourceFormat, pcmBytes: ByteArray): ShortArray {
        if (pcmBytes.isEmpty()) return shortArrayOf()

        val samples = if (source.isFloat) {
            bytesToFloatSamples(pcmBytes)
        } else {
            bytesToShortSamples(pcmBytes)
        }

        val mono = when {
            source.channelCount <= 1 -> samples.map { floatToShort(it) }.toShortArray()
            else -> mixToMono(samples, source.channelCount)
        }

        return if (source.sampleRate == PcmResampler.TARGET_SAMPLE_RATE) {
            mono
        } else {
            PcmResampler.resamplePcm16(mono, source.sampleRate)
        }
    }

    fun shortsToBytes(samples: ShortArray): ByteArray {
        val buffer = ByteBuffer.allocate(samples.size * 2).order(ByteOrder.LITTLE_ENDIAN)
        for (sample in samples) {
            buffer.putShort(sample)
        }
        return buffer.array()
    }

    private fun bytesToShortSamples(pcmBytes: ByteArray): FloatArray {
        val buffer = ByteBuffer.wrap(pcmBytes).order(ByteOrder.LITTLE_ENDIAN)
        val count = pcmBytes.size / 2
        val out = FloatArray(count)
        for (i in 0 until count) {
            out[i] = buffer.short.toFloat()
        }
        return out
    }

    private fun bytesToFloatSamples(pcmBytes: ByteArray): FloatArray {
        val buffer = ByteBuffer.wrap(pcmBytes).order(ByteOrder.LITTLE_ENDIAN)
        val count = pcmBytes.size / 4
        val out = FloatArray(count)
        for (i in 0 until count) {
            out[i] = buffer.float
        }
        return out
    }

    private fun mixToMono(samples: FloatArray, channelCount: Int): ShortArray {
        if (channelCount <= 1) {
            return samples.map { floatToShort(it) }.toShortArray()
        }

        val frameCount = samples.size / channelCount
        val mono = ShortArray(frameCount)
        for (frame in 0 until frameCount) {
            var sum = 0.0
            val base = frame * channelCount
            for (channel in 0 until channelCount) {
                sum += samples[base + channel]
            }
            mono[frame] = floatToShort((sum / channelCount).toFloat())
        }
        return mono
    }

    private fun floatToShort(value: Float): Short {
        val scaled = when {
            value.isNaN() -> 0
            value > 1f -> Short.MAX_VALUE.toInt()
            value < -1f -> Short.MIN_VALUE.toInt()
            else -> (value * Short.MAX_VALUE).toInt()
        }
        return scaled.coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt()).toShort()
    }
}
