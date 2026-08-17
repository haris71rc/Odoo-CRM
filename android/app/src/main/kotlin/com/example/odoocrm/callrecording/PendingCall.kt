package com.bigoh.odoocrm.callrecording

/**
 * Tracks an outbound CRM-initiated call while the native dialer is active.
 */
data class PendingCall(
    val leadId: Long,
    val phoneNumber: String,
    val callStartedAt: Long,
    var callActive: Boolean = false,
    var callEndedAt: Long? = null,
    var awaitingImport: Boolean = false,
) {
    fun isExpired(now: Long = System.currentTimeMillis()): Boolean {
        val anchor = callEndedAt ?: callStartedAt
        return now - anchor > CallRecordingConfig.PENDING_IMPORT_TTL_MS
    }
}
