package com.bigoh.odoocrm.callrecording.transcription

/**
 * Resamples signed 16-bit PCM audio to a target sample rate using linear interpolation.
 */
object PcmResampler {
    const val TARGET_SAMPLE_RATE = 16_000

    fun resamplePcm16(
        input: ShortArray,
        inputSampleRate: Int,
        outputSampleRate: Int = TARGET_SAMPLE_RATE,
    ): ShortArray {
        if (input.isEmpty()) return shortArrayOf()
        if (inputSampleRate == outputSampleRate) return input.copyOf()

        val outputLength =
            ((input.size.toLong() * outputSampleRate) / inputSampleRate).toInt().coerceAtLeast(1)
        val output = ShortArray(outputLength)
        val ratio = inputSampleRate.toDouble() / outputSampleRate.toDouble()

        for (i in 0 until outputLength) {
            val srcIndex = i * ratio
            val index0 = srcIndex.toInt().coerceIn(0, input.lastIndex)
            val index1 = (index0 + 1).coerceAtMost(input.lastIndex)
            val fraction = srcIndex - index0
            val sample0 = input[index0].toInt()
            val sample1 = input[index1].toInt()
            val interpolated = sample0 + ((sample1 - sample0) * fraction)
            output[i] = interpolated.toInt().coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt()).toShort()
        }

        return output
    }
}
