package com.bigoh.odoocrm.callrecording

import android.content.Context
import android.content.Intent
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.provider.OpenableColumns
import android.util.Log
import android.webkit.MimeTypeMap
import java.io.File
import java.util.Locale
import java.util.UUID

/**
 * Validates a user-granted content URI (document picker or share sheet) and
 * returns a [RecordingCandidate] the existing transcription pipeline can consume.
 *
 * Never converts a content URI into a guessed filesystem path. When persistable
 * access is unavailable, a temporary copy is made under the app cache.
 */
class ImportedRecordingResolver(private val context: Context) {

    data class ResolvedRecording(
        val candidate: RecordingCandidate,
        val cachedFile: File?,
    )

    fun resolve(uri: Uri, source: String, intent: Intent? = null): ResolvedRecording {
        takeReadPermission(uri, intent)

        val stream = try {
            context.contentResolver.openInputStream(uri)
        } catch (e: SecurityException) {
            throw UriAccessException("Unable to access the selected recording.", e)
        } catch (e: Exception) {
            throw UriAccessException("Unable to access the selected recording.", e)
        } ?: throw UriAccessException("Unable to access the selected recording.")

        stream.use { input ->
            if (input.read() < 0) {
                throw InvalidAudioException("The selected file is not a valid audio recording.")
            }
        }

        val meta = queryMetadata(uri)
        val mimeType = meta.mimeType ?: context.contentResolver.getType(uri)
        if (!isAudioMime(mimeType, meta.displayName)) {
            throw InvalidAudioException("The selected file is not a valid audio recording.")
        }

        val size = if (meta.size > 0) meta.size else readSize(uri)
        if (size <= 0L) {
            throw InvalidAudioException("The selected file is not a valid audio recording.")
        }

        val durationMs = readDurationMs(uri)
        val persistable = hasPersistableAccess(uri)
        val cachedFile: File?
        val stableUri: Uri
        if (persistable) {
            cachedFile = null
            stableUri = uri
        } else {
            cachedFile = copyToCache(uri, meta.displayName, mimeType)
            stableUri = Uri.fromFile(cachedFile)
        }

        Log.i(
            CallRecordingConfig.TAG,
            "Imported recording source=$source name=${meta.displayName} " +
                "mime=$mimeType size=$size durationMs=$durationMs persistable=$persistable",
        )

        val candidate = RecordingCandidate(
            id = 0L,
            uri = stableUri,
            name = meta.displayName ?: "Call recording",
            mimeType = mimeType,
            dateAddedSeconds = System.currentTimeMillis() / 1000,
            dateModifiedSeconds = System.currentTimeMillis() / 1000,
            durationMs = durationMs,
            size = size,
            relativePath = null,
            source = source,
        )
        return ResolvedRecording(candidate, cachedFile)
    }

    fun cleanupExpiredCache() {
        val dir = cacheDir()
        if (!dir.exists()) return
        val cutoff = System.currentTimeMillis() - CallRecordingConfig.IMPORT_CACHE_TTL_MS
        dir.listFiles()?.forEach { file ->
            if (file.lastModified() < cutoff) {
                if (!file.delete()) {
                    Log.w(CallRecordingConfig.TAG, "Failed to delete expired cache ${file.name}")
                }
            }
        }
    }

    fun deleteCacheFile(file: File?) {
        if (file == null) return
        try {
            if (file.exists() && !file.delete()) {
                Log.w(CallRecordingConfig.TAG, "Failed to delete cache ${file.name}")
            }
        } catch (e: Exception) {
            Log.w(CallRecordingConfig.TAG, "Failed to delete cache ${file.name}", e)
        }
    }

    private fun takeReadPermission(uri: Uri, intent: Intent?) {
        val flags = (intent?.flags ?: 0) and Intent.FLAG_GRANT_READ_URI_PERMISSION
        if (flags == 0) return
        try {
            context.contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION,
            )
        } catch (_: SecurityException) {
            // Share-sheet grants are often not persistable; cache copy handles that.
        } catch (_: Exception) {
        }
    }

    private fun hasPersistableAccess(uri: Uri): Boolean {
        return context.contentResolver.persistedUriPermissions.any { permission ->
            permission.uri == uri && permission.isReadPermission
        }
    }

    private fun queryMetadata(uri: Uri): FileMeta {
        var name: String? = null
        var size = 0L
        var mime = context.contentResolver.getType(uri)
        try {
            context.contentResolver.query(
                uri,
                arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE),
                null,
                null,
                null,
            )?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val nameIdx = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    val sizeIdx = cursor.getColumnIndex(OpenableColumns.SIZE)
                    if (nameIdx >= 0) name = cursor.getString(nameIdx)
                    if (sizeIdx >= 0 && !cursor.isNull(sizeIdx)) {
                        size = cursor.getLong(sizeIdx)
                    }
                }
            }
        } catch (e: Exception) {
            Log.w(CallRecordingConfig.TAG, "Unable to query OpenableColumns", e)
        }
        if (mime.isNullOrBlank() && name != null) {
            mime = mimeFromFileName(name)
        }
        return FileMeta(displayName = name, size = size, mimeType = mime)
    }

    private fun readSize(uri: Uri): Long {
        return try {
            context.contentResolver.openAssetFileDescriptor(uri, "r")?.use { it.length } ?: 0L
        } catch (_: Exception) {
            0L
        }
    }

    private fun readDurationMs(uri: Uri): Long {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(context, uri)
            retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                ?.toLongOrNull()
                ?: 0L
        } catch (_: Exception) {
            0L
        } finally {
            try {
                retriever.release()
            } catch (_: Exception) {
            }
        }
    }

    private fun copyToCache(uri: Uri, displayName: String?, mimeType: String?): File {
        cleanupExpiredCache()
        val dir = cacheDir()
        if (!dir.exists() && !dir.mkdirs()) {
            throw UriAccessException("Unable to access the selected recording.")
        }
        val extension = extensionOf(displayName, mimeType)
        val out = File(dir, "import_${UUID.randomUUID()}$extension")
        try {
            context.contentResolver.openInputStream(uri).use { input ->
                if (input == null) {
                    throw UriAccessException("Unable to access the selected recording.")
                }
                out.outputStream().use { output -> input.copyTo(output) }
            }
        } catch (e: UriAccessException) {
            out.delete()
            throw e
        } catch (e: Exception) {
            out.delete()
            throw UriAccessException("Unable to access the selected recording.", e)
        }
        if (out.length() <= 0L) {
            out.delete()
            throw InvalidAudioException("The selected file is not a valid audio recording.")
        }
        return out
    }

    private fun cacheDir(): File = File(context.cacheDir, CACHE_DIR_NAME)

    private fun isAudioMime(mimeType: String?, displayName: String?): Boolean {
        val mime = mimeType?.lowercase(Locale.US)?.trim().orEmpty()
        if (mime.startsWith("audio/")) return true
        if (mime == "application/ogg" || mime == "application/x-ogg") return true
        if (mime.isEmpty() || mime == "application/octet-stream") {
            val inferred = mimeFromFileName(displayName)
            if (inferred?.startsWith("audio/") == true) return true
            // Last resort: duration probe already ran separately; allow unknown
            // MIME only when the file name looks like audio.
            val name = displayName?.lowercase(Locale.US).orEmpty()
            return AUDIO_EXTENSIONS.any { name.endsWith(it) }
        }
        return false
    }

    private fun mimeFromFileName(name: String?): String? {
        val extension = name?.substringAfterLast('.', "")?.lowercase(Locale.US)
        if (extension.isNullOrEmpty()) return null
        return MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension)
            ?: if (AUDIO_EXTENSIONS.contains(".$extension")) "audio/*" else null
    }

    private fun extensionOf(displayName: String?, mimeType: String?): String {
        val fromName = displayName?.substringAfterLast('.', "")
        if (!fromName.isNullOrBlank() && fromName.length in 2..4) {
            return ".${fromName.lowercase(Locale.US)}"
        }
        val fromMime = mimeType?.let { MimeTypeMap.getSingleton().getExtensionFromMimeType(it) }
        if (!fromMime.isNullOrBlank()) return ".${fromMime.lowercase(Locale.US)}"
        return ".audio"
    }

    private data class FileMeta(
        val displayName: String?,
        val size: Long,
        val mimeType: String?,
    )

    companion object {
        private const val CACHE_DIR_NAME = "call_recordings"
        private val AUDIO_EXTENSIONS = setOf(
            ".m4a", ".aac", ".amr", ".3gp", ".3gpp", ".mp3", ".wav",
            ".ogg", ".opus", ".flac", ".mp4", ".wma",
        )
    }
}

class UriAccessException(message: String, cause: Throwable? = null) : Exception(message, cause)

class InvalidAudioException(message: String, cause: Throwable? = null) : Exception(message, cause)
