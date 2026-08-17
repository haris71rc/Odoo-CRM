package com.bigoh.odoocrm.callrecording

object CallRecordingConfig {
    const val CHANNEL_NAME = "com.bigoh.odoocrm/call_recording"
    const val TAG = "CallRecording"

    /**
     * MVP target OEMs for call-recording detection and on-device transcription.
     * Implementation is MediaStore-based (no hardcoded filesystem paths).
     */
    val SUPPORTED_OEMS = listOf("Samsung", "OnePlus", "Realme")

    /** Initial delay before the first MediaStore query after call ends. */
    const val RECORDING_DETECTION_DELAY_MS = 3_000L

    /** Search window starts this many ms before [PendingCall.callStartedAt]. */
    const val SEARCH_START_BUFFER_MS = 5_000L

    /** Retry delays (ms from call end). Realme/ColorOS can index recordings slowly. */
    val RETRY_DELAYS_MS = longArrayOf(3_000L, 8_000L, 15_000L, 25_000L, 40_000L, 60_000L)

    /** Accept recordings created up to this many ms after call end. */
    const val SEARCH_END_BUFFER_MS = 120_000L

    /** Expands the post-call search window on later retry attempts. */
    fun endBufferForAttempt(attemptIndex: Int): Long = when {
        attemptIndex >= 4 -> 180_000L
        attemptIndex >= 3 -> 150_000L
        attemptIndex >= 2 -> 120_000L
        else -> SEARCH_END_BUFFER_MS
    }

    const val REQUEST_CALL_RECORDING = 9922
    const val REQUEST_IMPORT_RECORDING = 9923

    /** Keep pending call context so the user can import/share a recording. */
    const val PENDING_IMPORT_TTL_MS = 30 * 60_000L

    /** Temporary copies of share-sheet recordings. */
    const val IMPORT_CACHE_TTL_MS = 60 * 60_000L
}
