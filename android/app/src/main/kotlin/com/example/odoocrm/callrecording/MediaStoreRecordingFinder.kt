package com.bigoh.odoocrm.callrecording

import android.content.ContentUris
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import kotlin.math.abs
import kotlin.math.max

/**
 * Queries MediaStore for call recordings created during a tracked call window.
 *
 * Realme / ColorOS devices often index dialer recordings in [MediaStore.Files]
 * rather than [MediaStore.Audio.Media], and may delay indexing by 15–60 seconds.
 */
class MediaStoreRecordingFinder(private val context: Context) {

    data class SearchResult(
        val selected: RecordingCandidate?,
        val candidates: List<RecordingCandidate>,
    )

    fun findRecording(
        pendingCall: PendingCall,
        callEndedAt: Long,
        attemptIndex: Int = 0,
    ): SearchResult {
        val searchStartMs = pendingCall.callStartedAt - CallRecordingConfig.SEARCH_START_BUFFER_MS
        val endBufferMs = CallRecordingConfig.endBufferForAttempt(attemptIndex)
        val searchEndMs = max(callEndedAt + endBufferMs, System.currentTimeMillis())
        val callDurationMs = (callEndedAt - pendingCall.callStartedAt).coerceAtLeast(0)

        val searchStartSeconds = searchStartMs / 1000
        val searchEndSeconds = searchEndMs / 1000

        Log.i(
            CallRecordingConfig.TAG,
            "Searching MediaStore window: start=$searchStartSeconds end=$searchEndSeconds " +
                "callDurationMs=$callDurationMs attempt=${attemptIndex + 1} " +
                "manufacturer=${Build.MANUFACTURER}",
        )

        val rawCandidates = queryAllCollections(searchStartSeconds, searchEndSeconds)
        Log.i(
            CallRecordingConfig.TAG,
            "MediaStore raw candidates: ${rawCandidates.size} " +
                "(audio=${rawCandidates.count { it.source == "audio" }}, " +
                "files=${rawCandidates.count { it.source == "files" }})",
        )

        if (rawCandidates.isEmpty()) {
            logRecentAudioDiagnostic()
        }

        val scored = rawCandidates.map { candidate ->
            scoreCandidate(candidate, pendingCall, callEndedAt, callDurationMs)
        }.sortedByDescending { it.score }

        for (candidate in scored) {
            Log.i(
                CallRecordingConfig.TAG,
                "Candidate: name=${candidate.name} uri=${candidate.uri} " +
                    "duration=${candidate.durationMs} dateAdded=${candidate.dateAddedSeconds} " +
                    "dateModified=${candidate.dateModifiedSeconds} " +
                    "relativePath=${candidate.relativePath} source=${candidate.source} " +
                    "score=${candidate.score}",
            )
        }

        val strongCandidates = scored.filter { it.score >= MIN_STRONG_SCORE }
        val selected = when {
            strongCandidates.size == 1 -> strongCandidates.first()
            strongCandidates.size > 1 -> strongCandidates.maxByOrNull { it.score }
            else -> null
        }

        if (selected != null) {
            Log.i(CallRecordingConfig.TAG, "Selected: ${selected.name}")
        } else {
            Log.w(CallRecordingConfig.TAG, "No strong recording candidate found")
        }

        return SearchResult(selected = selected, candidates = scored)
    }

    private fun queryAllCollections(
        searchStartSeconds: Long,
        searchEndSeconds: Long,
    ): List<RecordingCandidate> {
        val merged = LinkedHashMap<String, RecordingCandidate>()
        fun merge(candidate: RecordingCandidate) {
            val key = "${candidate.name}|${candidate.size}|${candidate.dateAddedSeconds}"
            val existing = merged[key]
            if (existing == null || candidate.source == "audio") {
                merged[key] = candidate
            }
        }

        queryAudioCollection(searchStartSeconds, searchEndSeconds).forEach(::merge)
        queryFilesCollection(searchStartSeconds, searchEndSeconds).forEach(::merge)

        return merged.values.toList()
    }

    private fun queryAudioCollection(
        searchStartSeconds: Long,
        searchEndSeconds: Long,
    ): List<RecordingCandidate> {
        val results = mutableListOf<RecordingCandidate>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val volumes = listOfNotNull(
                MediaStore.VOLUME_EXTERNAL,
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    MediaStore.VOLUME_EXTERNAL_PRIMARY
                } else {
                    null
                },
            ).distinct()
            for (volume in volumes) {
                val collection = MediaStore.Audio.Media.getContentUri(volume)
                results += queryCollection(
                    collection = collection,
                    source = "audio",
                    idColumn = MediaStore.Audio.Media._ID,
                    nameColumn = MediaStore.Audio.Media.DISPLAY_NAME,
                    mimeColumn = MediaStore.Audio.Media.MIME_TYPE,
                    addedColumn = MediaStore.Audio.Media.DATE_ADDED,
                    modifiedColumn = MediaStore.Audio.Media.DATE_MODIFIED,
                    durationColumn = MediaStore.Audio.Media.DURATION,
                    sizeColumn = MediaStore.Audio.Media.SIZE,
                    relativePathColumn = MediaStore.Audio.Media.RELATIVE_PATH,
                    searchStartSeconds = searchStartSeconds,
                    searchEndSeconds = searchEndSeconds,
                )
            }
        } else {
            results += queryCollection(
                collection = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                source = "audio",
                idColumn = MediaStore.Audio.Media._ID,
                nameColumn = MediaStore.Audio.Media.DISPLAY_NAME,
                mimeColumn = MediaStore.Audio.Media.MIME_TYPE,
                addedColumn = MediaStore.Audio.Media.DATE_ADDED,
                modifiedColumn = MediaStore.Audio.Media.DATE_MODIFIED,
                durationColumn = MediaStore.Audio.Media.DURATION,
                sizeColumn = MediaStore.Audio.Media.SIZE,
                relativePathColumn = null,
                searchStartSeconds = searchStartSeconds,
                searchEndSeconds = searchEndSeconds,
            )
        }
        return results
    }

    private fun queryFilesCollection(
        searchStartSeconds: Long,
        searchEndSeconds: Long,
    ): List<RecordingCandidate> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            // Files table filtering is less reliable pre-Q; Audio collection is primary.
            return emptyList()
        }

        val volumes = listOfNotNull(
            MediaStore.VOLUME_EXTERNAL,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                MediaStore.VOLUME_EXTERNAL_PRIMARY
            } else {
                null
            },
        ).distinct()

        val audioType = MediaStore.Files.FileColumns.MEDIA_TYPE_AUDIO
        val mimeSelection =
            "(${MediaStore.Files.FileColumns.MEDIA_TYPE} = $audioType OR " +
                "${MediaStore.Files.FileColumns.MIME_TYPE} LIKE 'audio/%' OR " +
                "${MediaStore.Files.FileColumns.MIME_TYPE} = 'video/mp4' OR " +
                "${MediaStore.Files.FileColumns.MIME_TYPE} = 'application/mp4')"

        val results = mutableListOf<RecordingCandidate>()
        for (volume in volumes) {
            val collection = MediaStore.Files.getContentUri(volume)
            results += queryCollection(
                collection = collection,
                source = "files",
                idColumn = MediaStore.Files.FileColumns._ID,
                nameColumn = MediaStore.Files.FileColumns.DISPLAY_NAME,
                mimeColumn = MediaStore.Files.FileColumns.MIME_TYPE,
                addedColumn = MediaStore.Files.FileColumns.DATE_ADDED,
                modifiedColumn = MediaStore.Files.FileColumns.DATE_MODIFIED,
                durationColumn = MediaStore.Files.FileColumns.DURATION,
                sizeColumn = MediaStore.Files.FileColumns.SIZE,
                relativePathColumn = MediaStore.Files.FileColumns.RELATIVE_PATH,
                searchStartSeconds = searchStartSeconds,
                searchEndSeconds = searchEndSeconds,
                extraSelection = mimeSelection,
            )
        }
        return results
    }

    private fun queryCollection(
        collection: Uri,
        source: String,
        idColumn: String,
        nameColumn: String,
        mimeColumn: String,
        addedColumn: String,
        modifiedColumn: String,
        durationColumn: String,
        sizeColumn: String,
        relativePathColumn: String?,
        searchStartSeconds: Long,
        searchEndSeconds: Long,
        extraSelection: String? = null,
    ): List<RecordingCandidate> {
        val projection = buildList {
            add(idColumn)
            add(nameColumn)
            add(mimeColumn)
            add(addedColumn)
            add(modifiedColumn)
            add(durationColumn)
            add(sizeColumn)
            if (relativePathColumn != null) add(relativePathColumn)
        }.toTypedArray()

        val dateSelection =
            "(($addedColumn >= ? AND $addedColumn <= ?) OR " +
                "($modifiedColumn >= ? AND $modifiedColumn <= ?))"
        val selection = if (extraSelection.isNullOrBlank()) {
            dateSelection
        } else {
            "($extraSelection) AND $dateSelection"
        }
        val selectionArgs = arrayOf(
            searchStartSeconds.toString(),
            searchEndSeconds.toString(),
            searchStartSeconds.toString(),
            searchEndSeconds.toString(),
        )
        val sortOrder = "$addedColumn DESC"

        val results = mutableListOf<RecordingCandidate>()
        try {
            context.contentResolver.query(
                collection,
                projection,
                selection,
                selectionArgs,
                sortOrder,
            )?.use { cursor ->
                val idIdx = cursor.getColumnIndexOrThrow(idColumn)
                val nameIdx = cursor.getColumnIndexOrThrow(nameColumn)
                val mimeIdx = cursor.getColumnIndexOrThrow(mimeColumn)
                val addedIdx = cursor.getColumnIndexOrThrow(addedColumn)
                val modifiedIdx = cursor.getColumnIndexOrThrow(modifiedColumn)
                val durationIdx = cursor.getColumnIndex(durationColumn)
                val sizeIdx = cursor.getColumnIndexOrThrow(sizeColumn)
                val relativePathIdx = relativePathColumn?.let { cursor.getColumnIndex(it) } ?: -1

                while (cursor.moveToNext()) {
                    val id = cursor.getLong(idIdx)
                    val uri = ContentUris.withAppendedId(collection, id)
                    val name = cursor.getString(nameIdx) ?: "unknown"
                    val mimeType = cursor.getString(mimeIdx)
                    val dateAdded = cursor.getLong(addedIdx)
                    val dateModified = cursor.getLong(modifiedIdx)
                    val duration = if (durationIdx >= 0) cursor.getLong(durationIdx) else 0L
                    val size = cursor.getLong(sizeIdx)
                    val relativePath = if (relativePathIdx >= 0) {
                        cursor.getString(relativePathIdx)
                    } else {
                        null
                    }

                    results.add(
                        RecordingCandidate(
                            id = id,
                            uri = uri,
                            name = name,
                            mimeType = mimeType,
                            dateAddedSeconds = dateAdded,
                            dateModifiedSeconds = dateModified,
                            durationMs = duration,
                            size = size,
                            relativePath = relativePath,
                            source = source,
                        ),
                    )
                }
            }
        } catch (e: SecurityException) {
            Log.e(CallRecordingConfig.TAG, "MediaStore query denied for $collection", e)
            throw e
        } catch (e: Exception) {
            Log.e(CallRecordingConfig.TAG, "MediaStore query failed for $collection", e)
        }
        return results
    }

    private fun logRecentAudioDiagnostic() {
        try {
            val collection = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            context.contentResolver.query(
                collection,
                arrayOf(
                    MediaStore.Audio.Media.DISPLAY_NAME,
                    MediaStore.Audio.Media.DATE_ADDED,
                    MediaStore.Audio.Media.DATE_MODIFIED,
                    MediaStore.Audio.Media.RELATIVE_PATH,
                ),
                null,
                null,
                "${MediaStore.Audio.Media.DATE_ADDED} DESC",
            )?.use { cursor ->
                val nameIdx = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DISPLAY_NAME)
                val addedIdx = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_ADDED)
                val modifiedIdx = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_MODIFIED)
                val pathIdx = cursor.getColumnIndex(MediaStore.Audio.Media.RELATIVE_PATH)
                var count = 0
                while (cursor.moveToNext() && count < 5) {
                    Log.d(
                        CallRecordingConfig.TAG,
                        "Recent audio: name=${cursor.getString(nameIdx)} " +
                            "added=${cursor.getLong(addedIdx)} " +
                            "modified=${cursor.getLong(modifiedIdx)} " +
                            "path=${if (pathIdx >= 0) cursor.getString(pathIdx) else "?"}",
                    )
                    count++
                }
            }
        } catch (e: Exception) {
            Log.d(CallRecordingConfig.TAG, "Recent audio diagnostic failed", e)
        }
    }

    private fun scoreCandidate(
        candidate: RecordingCandidate,
        pendingCall: PendingCall,
        callEndedAt: Long,
        callDurationMs: Long,
    ): RecordingCandidate {
        var score = 0
        val createdMs = effectiveTimestampMs(candidate)
        val callStartedAt = pendingCall.callStartedAt

        if (createdMs >= callStartedAt - CallRecordingConfig.SEARCH_START_BUFFER_MS) score += 30
        if (createdMs <= callEndedAt + CallRecordingConfig.SEARCH_END_BUFFER_MS) score += 20
        if (candidate.durationMs > 0) score += 15

        if (callDurationMs > 0 && candidate.durationMs > 0) {
            val diff = abs(candidate.durationMs - callDurationMs)
            val tolerance = (callDurationMs * 0.35).coerceAtLeast(5_000.0)
            if (diff <= tolerance) score += 25
            else if (diff <= tolerance * 2) score += 10
        } else if (callDurationMs > 0 && candidate.size > 0) {
            // Realme Files entries often lack duration metadata.
            score += 8
        }

        val proximityMs = abs(createdMs - callEndedAt)
        when {
            proximityMs <= 10_000 -> score += 20
            proximityMs <= 30_000 -> score += 10
            proximityMs <= 90_000 -> score += 5
        }

        score += recordingKeywordScore(candidate.name, candidate.relativePath)

        candidate.score = score
        return candidate
    }

    private fun effectiveTimestampMs(candidate: RecordingCandidate): Long {
        return max(
            candidate.dateAddedSeconds * 1000,
            candidate.dateModifiedSeconds * 1000,
        )
    }

    private fun recordingKeywordScore(name: String, relativePath: String?): Int {
        var score = 0
        val lowerName = name.lowercase()
        val lowerPath = relativePath?.lowercase().orEmpty()
        val keywords = listOf(
            "record",
            "call",
            "voice",
            "phone",
            "dialer",
            "conversation",
            "callrecord",
            "sounds",
        )

        for (keyword in keywords) {
            if (lowerName.contains(keyword)) score += 8
            if (lowerPath.contains(keyword)) score += 12
        }

        if (lowerPath.contains("recording")) score += 15
        if (lowerPath.contains("recordings/call") || lowerPath.contains("recordings\\call")) {
            score += 10
        }
        // Realme / ColorOS common folders
        if (lowerPath.contains("music/recordings") || lowerPath.contains("music\\recordings")) {
            score += 12
        }

        return score.coerceAtMost(40)
    }

    companion object {
        private const val MIN_STRONG_SCORE = 45
    }
}
