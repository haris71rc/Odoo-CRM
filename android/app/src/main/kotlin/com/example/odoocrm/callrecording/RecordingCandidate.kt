package com.bigoh.odoocrm.callrecording

import android.net.Uri

data class RecordingCandidate(
    val id: Long,
    val uri: Uri,
    val name: String,
    val mimeType: String?,
    val dateAddedSeconds: Long,
    val dateModifiedSeconds: Long,
    val durationMs: Long,
    val size: Long,
    val relativePath: String?,
    val source: String = "audio",
    var score: Int = 0,
) {
    fun toResultMap(leadId: Long): Map<String, Any?> = mapOf(
        "success" to true,
        "leadId" to leadId,
        "uri" to uri.toString(),
        "name" to name,
        "mimeType" to (mimeType ?: ""),
        "duration" to durationMs,
        "dateAdded" to dateAddedSeconds,
        "size" to size,
        "relativePath" to (relativePath ?: ""),
        "source" to source,
    )

    fun toDebugMap(): Map<String, Any?> = mapOf(
        "name" to name,
        "uri" to uri.toString(),
        "duration" to durationMs,
        "dateAdded" to dateAddedSeconds,
        "dateModified" to dateModifiedSeconds,
        "size" to size,
        "relativePath" to (relativePath ?: ""),
        "source" to source,
        "score" to score,
    )
}
