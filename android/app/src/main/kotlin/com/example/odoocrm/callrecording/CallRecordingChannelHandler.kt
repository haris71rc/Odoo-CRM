package com.bigoh.odoocrm.callrecording

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.bigoh.odoocrm.callrecording.transcription.CallRecordingTranscriber
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.ArrayDeque
import java.util.concurrent.Executors

/**
 * MethodChannel handler for call recording detection MVP.
 *
 * Methods (Flutter → Native):
 * - startCallTracking { leadId, phoneNumber, callStartedAt }
 * - stopCallTracking
 * - transcribeRecording { leadId, uri, name, mimeType, languageTag? }
 * - cancelTranscription
 * - importCallRecording
 * - cancelPendingImport
 *
 * Callbacks (Native → Flutter via same channel):
 * - onCallTrackingStarted
 * - onCallEnded
 * - onSearchingMediaStore { attempt }
 * - onRecordingCandidates { candidates }
 * - onRecordingFound { success, leadId, uri, name, source, ... }
 * - onRecordingError { code, message, leadId }
 * - onTranscriptionStatus { leadId, status }
 * - onPartialTranscript { leadId, text }
 * - onFinalTranscript { leadId, text }
 * - onTranscriptionComplete { leadId, transcript }
 * - onTranscriptionError { leadId, code, message }
 */
class CallRecordingChannelHandler(
    private val activity: Activity,
    private val channel: MethodChannel,
) {
    private data class PendingPermissionWork(
        val permissions: Set<String>,
        val onAllGranted: () -> Unit,
        val onDenied: (List<String>) -> Unit,
    )

    private val mainHandler = Handler(Looper.getMainLooper())
    private val ioExecutor = Executors.newSingleThreadExecutor()

    private var pendingCall: PendingCall? = null
    private var callStateMonitor: CallStateMonitor? = null
    private val recordingFinder = MediaStoreRecordingFinder(activity)
    private val importResolver = ImportedRecordingResolver(activity)
    private var cachedImportFile: File? = null
    private val transcriber = CallRecordingTranscriber(
        activity,
        object : CallRecordingTranscriber.Callbacks {
            override fun onStatus(leadId: Long, status: String) {
                invokeFlutter("onTranscriptionStatus", mapOf(
                    "event" to "status",
                    "leadId" to leadId,
                    "status" to status,
                ))
            }

            override fun onPartialTranscript(leadId: Long, text: String) {
                invokeFlutter("onPartialTranscript", mapOf(
                    "event" to "partial_transcript",
                    "leadId" to leadId,
                    "text" to text,
                ))
            }

            override fun onFinalTranscript(leadId: Long, text: String) {
                invokeFlutter("onFinalTranscript", mapOf(
                    "event" to "final_transcript",
                    "leadId" to leadId,
                    "text" to text,
                ))
            }

            override fun onComplete(leadId: Long, transcript: String) {
                cleanupCachedImport(keepForRetry = false)
                invokeFlutter("onTranscriptionComplete", mapOf(
                    "event" to "transcription_complete",
                    "leadId" to leadId,
                    "transcript" to transcript,
                    "success" to true,
                ))
            }

            override fun onError(leadId: Long, code: String, message: String) {
                cleanupCachedImport(keepForRetry = true)
                invokeFlutter("onTranscriptionError", mapOf(
                    "event" to "transcription_error",
                    "leadId" to leadId,
                    "code" to code,
                    "message" to message,
                    "success" to false,
                ))
            }
        },
    )

    private val permissionWorkQueue = ArrayDeque<PendingPermissionWork>()
    private var permissionRequestInFlight = false
    private var pendingTranscribeRequest: CallRecordingTranscriber.Request? = null
    private var resumeRetryCall: PendingCall? = null
    private var resumeRetryEndedAt: Long = 0L
    private var resumeRetryScheduled = false

    fun handleMethodCall(method: String, arguments: Any?, result: MethodChannel.Result) {
        when (method) {
            "startCallTracking" -> startCallTracking(arguments, result)
            "stopCallTracking" -> {
                stopTracking(clearPending = true)
                result.success(true)
            }
            "transcribeRecording" -> transcribeRecording(arguments, result)
            "importCallRecording" -> importCallRecording(result)
            "cancelPendingImport" -> {
                stopTracking(clearPending = true)
                result.success(true)
            }
            "cancelTranscription" -> {
                transcriber.cancel()
                pendingTranscribeRequest = null
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (requestCode != CallRecordingConfig.REQUEST_CALL_RECORDING) return

        permissionRequestInFlight = false

        val denied = permissions.indices.mapNotNull { index ->
            val permission = permissions[index]
            val granted = grantResults.getOrNull(index) == PackageManager.PERMISSION_GRANTED
            if (granted) null else permission
        }.toSet()

        if (denied.isNotEmpty()) {
            Log.w(
                CallRecordingConfig.TAG,
                "Permissions denied: ${denied.joinToString()}",
            )
        }

        val remaining = ArrayDeque<PendingPermissionWork>()
        for (work in permissionWorkQueue) {
            val stillMissing = work.permissions.filterNot { hasPermission(it) }
            when {
                stillMissing.isEmpty() -> work.onAllGranted()
                stillMissing.any { it in denied } -> work.onDenied(stillMissing)
                else -> remaining.add(work)
            }
        }
        permissionWorkQueue.clear()
        permissionWorkQueue.addAll(remaining)

        drainPermissionQueue()
    }

    private fun transcribeRecording(arguments: Any?, result: MethodChannel.Result) {
        val args = arguments as? Map<*, *>
        val leadId = (args?.get("leadId") as? Number)?.toLong()
        val uri = args?.get("uri") as? String
        val name = args?.get("name") as? String
        val mimeType = args?.get("mimeType") as? String
        val languageTag = (args?.get("languageTag") as? String)
            ?: CallRecordingTranscriber.DEFAULT_LANGUAGE_TAG

        if (leadId == null || uri.isNullOrBlank()) {
            result.error("INVALID_ARGUMENTS", "leadId and uri are required", null)
            return
        }

        val request = CallRecordingTranscriber.Request(
            leadId = leadId,
            uri = uri,
            name = name,
            mimeType = mimeType,
            languageTag = languageTag,
        )

        pendingTranscribeRequest = request
        if (hasPermission(Manifest.permission.RECORD_AUDIO)) {
            pendingTranscribeRequest = null
            transcriber.transcribe(request)
            result.success(true)
            return
        }

        Log.w(
            CallRecordingConfig.TAG,
            "RECORD_AUDIO not granted — Flutter should request before transcribe",
        )
        invokeFlutter("onTranscriptionError", mapOf(
            "event" to "transcription_error",
            "leadId" to leadId,
            "code" to "SPEECH_RECOGNITION_PERMISSION_DENIED",
            "message" to "Microphone permission is required for on-device speech recognition.",
            "success" to false,
        ))
        pendingTranscribeRequest = null
        result.success(false)
    }

    private fun startCallTracking(arguments: Any?, result: MethodChannel.Result) {
        val args = arguments as? Map<*, *>
        val leadId = (args?.get("leadId") as? Number)?.toLong()
        val phoneNumber = args?.get("phoneNumber") as? String
        val callStartedAt = (args?.get("callStartedAt") as? Number)?.toLong()

        if (leadId == null || phoneNumber.isNullOrBlank() || callStartedAt == null) {
            result.error("INVALID_ARGUMENTS", "leadId, phoneNumber, and callStartedAt are required", null)
            return
        }

        stopTracking(clearPending = false)

        pendingCall = PendingCall(
            leadId = leadId,
            phoneNumber = phoneNumber,
            callStartedAt = callStartedAt,
        )

        val monitor = CallStateMonitor(activity) { callEndedAt ->
            onTrackedCallEnded(callEndedAt)
        }
        callStateMonitor = monitor
        monitor.start()

        Log.i(
            CallRecordingConfig.TAG,
            "Call tracking started leadId=$leadId phone=$phoneNumber startedAt=$callStartedAt " +
                "manufacturer=${android.os.Build.MANUFACTURER} model=${android.os.Build.MODEL}",
        )
        invokeFlutter("onCallTrackingStarted", mapOf(
            "leadId" to leadId,
            "phoneNumber" to phoneNumber,
            "callStartedAt" to callStartedAt,
        ))

        // Request media + microphone together — Android allows only one dialog at a time.
        requestCallRecordingPermissionsIfNeeded()

        result.success(true)
    }

    private fun onTrackedCallEnded(callEndedAt: Long) {
        val call = pendingCall ?: return
        call.callActive = true
        call.callEndedAt = callEndedAt

        Log.i(
            CallRecordingConfig.TAG,
            "Call ended for leadId=${call.leadId} endedAt=$callEndedAt",
        )
        invokeFlutter("onCallEnded", mapOf(
            "leadId" to call.leadId,
            "callEndedAt" to callEndedAt,
            "callStartedAt" to call.callStartedAt,
        ))

        stopCallStateMonitor()

        ensureMediaPermission {
            scheduleRecordingSearch(call, callEndedAt)
        }
    }

    private fun scheduleRecordingSearch(call: PendingCall, callEndedAt: Long) {
        searchWithRetries(call, callEndedAt, attemptIndex = 0)
    }

    private fun searchWithRetries(call: PendingCall, callEndedAt: Long, attemptIndex: Int) {
        val delays = CallRecordingConfig.RETRY_DELAYS_MS
        if (attemptIndex >= delays.size) {
            scheduleResumeRetry(call, callEndedAt)
            notifyRecordingNotFound(call.leadId)
            return
        }

        if (pendingCall?.leadId != call.leadId) {
            Log.d(CallRecordingConfig.TAG, "Pending call replaced — aborting search")
            return
        }

        val attempt = attemptIndex + 1
        val delayMs = delays[attemptIndex]
        val elapsed = System.currentTimeMillis() - callEndedAt
        val waitMs = (delayMs - elapsed).coerceAtLeast(0)

        mainHandler.postDelayed({
            if (pendingCall?.leadId != call.leadId) return@postDelayed

            invokeFlutter("onSearchingMediaStore", mapOf(
                "leadId" to call.leadId,
                "attempt" to attempt,
            ))
            Log.i(CallRecordingConfig.TAG, "Searching MediaStore (attempt $attempt)...")

            ioExecutor.execute {
                try {
                    val searchResult = recordingFinder.findRecording(
                        call,
                        callEndedAt,
                        attemptIndex,
                    )
                    mainHandler.post {
                        handleSearchResult(call, searchResult, callEndedAt, attemptIndex)
                    }
                } catch (e: SecurityException) {
                    mainHandler.post {
                        pendingCall?.awaitingImport = true
                        notifyError(
                            code = "MEDIA_PERMISSION_DENIED",
                            message = "Audio access permission is required to detect call recordings.",
                            leadId = call.leadId,
                        )
                    }
                } catch (e: Exception) {
                    mainHandler.post {
                        Log.e(CallRecordingConfig.TAG, "MediaStore search failed", e)
                        searchWithRetries(call, callEndedAt, attemptIndex + 1)
                    }
                }
            }
        }, waitMs)
    }

    private fun handleSearchResult(
        call: PendingCall,
        searchResult: MediaStoreRecordingFinder.SearchResult,
        callEndedAt: Long,
        attemptIndex: Int,
    ) {
        if (pendingCall?.leadId != call.leadId) return

        invokeFlutter("onRecordingCandidates", mapOf(
            "leadId" to call.leadId,
            "candidates" to searchResult.candidates.map { it.toDebugMap() },
        ))

        val selected = searchResult.selected
        if (selected != null) {
            processRecording(call.leadId, selected)
            return
        }

        searchWithRetries(call, callEndedAt, attemptIndex + 1)
    }

    private fun scheduleResumeRetry(call: PendingCall, callEndedAt: Long) {
        resumeRetryCall = call
        resumeRetryEndedAt = callEndedAt
        resumeRetryScheduled = true
        Log.i(
            CallRecordingConfig.TAG,
            "Scheduled resume retry for leadId=${call.leadId} (Realme/ColorOS may index late)",
        )
    }

    /** Called when the app returns to foreground — Realme often indexes recordings then. */
    fun onActivityResumed() {
        expirePendingCallIfNeeded()
        retryDroppedPermissionRequest()
        retryPendingTranscription()

        val call = resumeRetryCall ?: return
        if (!resumeRetryScheduled) return
        if (call.isExpired()) {
            resumeRetryCall = null
            resumeRetryScheduled = false
            return
        }

        resumeRetryScheduled = false
        Log.i(CallRecordingConfig.TAG, "Resume-triggered MediaStore search for leadId=${call.leadId}")

        ensureMediaPermission {
            invokeFlutter("onSearchingMediaStore", mapOf(
                "leadId" to call.leadId,
                "attempt" to "resume",
            ))
            ioExecutor.execute {
                try {
                    val searchResult = recordingFinder.findRecording(
                        call,
                        resumeRetryEndedAt,
                        attemptIndex = 5,
                    )
                    mainHandler.post {
                        handleResumeSearchResult(call, searchResult)
                    }
                } catch (e: SecurityException) {
                    mainHandler.post {
                        pendingCall?.awaitingImport = true
                        notifyError(
                            code = "MEDIA_PERMISSION_DENIED",
                            message = "Audio access permission is required to detect call recordings.",
                            leadId = call.leadId,
                        )
                        resumeRetryCall = null
                    }
                } catch (e: Exception) {
                    mainHandler.post {
                        Log.e(CallRecordingConfig.TAG, "Resume MediaStore search failed", e)
                        pendingCall?.awaitingImport = true
                        resumeRetryCall = null
                    }
                }
            }
        }
    }

    private fun retryPendingTranscription() {
        val request = pendingTranscribeRequest ?: return
        if (!hasPermission(Manifest.permission.RECORD_AUDIO)) {
            ensureRecordAudioPermission(request) {
                pendingTranscribeRequest = null
                transcriber.transcribe(request)
            }
            return
        }
        pendingTranscribeRequest = null
        transcriber.transcribe(request)
    }

    private fun retryDroppedPermissionRequest() {
        if (!permissionRequestInFlight) {
            drainPermissionQueue()
            return
        }

        val anyStillMissing = permissionWorkQueue.any { work ->
            work.permissions.any { !hasPermission(it) }
        }
        if (anyStillMissing) {
            Log.w(CallRecordingConfig.TAG, "Retrying permission request after resume")
            permissionRequestInFlight = false
            drainPermissionQueue()
        }
    }

    private fun handleResumeSearchResult(
        call: PendingCall,
        searchResult: MediaStoreRecordingFinder.SearchResult,
    ) {
        invokeFlutter("onRecordingCandidates", mapOf(
            "leadId" to call.leadId,
            "candidates" to searchResult.candidates.map { it.toDebugMap() },
        ))

        val selected = searchResult.selected
        if (selected != null) {
            processRecording(call.leadId, selected)
        } else {
            pendingCall?.awaitingImport = true
            Log.i(
                CallRecordingConfig.TAG,
                "Resume search found nothing — keeping pending call for import leadId=${call.leadId}",
            )
        }

        resumeRetryCall = null
    }

    private fun notifyRecordingNotFound(leadId: Long) {
        pendingCall?.awaitingImport = true
        Log.w(CallRecordingConfig.TAG, "No recording found for leadId=$leadId")
        notifyError(
            code = "RECORDING_NOT_FOUND",
            message = "We couldn't automatically find the call recording. Please import it manually.",
            leadId = leadId,
        )
    }

    private fun notifyError(code: String, message: String, leadId: Long? = null) {
        val payload = mutableMapOf<String, Any?>(
            "code" to code,
            "message" to message,
            "success" to false,
        )
        payload["leadId"] = leadId ?: pendingCall?.leadId ?: 0L
        invokeFlutter("onRecordingError", payload)
    }

    /**
     * Single entry for MediaStore, document picker, and share-sheet recordings.
     * Flutter then starts the existing ML Kit pipeline via transcribeRecording.
     */
    private fun processRecording(leadId: Long, candidate: RecordingCandidate) {
        val payload = candidate.toResultMap(leadId).toMutableMap()
        if (candidate.source != "import" && candidate.source != "share") {
            payload["source"] = "mediastore"
        }
        Log.i(
            CallRecordingConfig.TAG,
            "Processing recording source=${payload["source"]} name=${candidate.name} leadId=$leadId",
        )
        invokeFlutter("onRecordingFound", payload)
        clearPendingCall(leadId)
        resumeRetryCall = null
        resumeRetryScheduled = false
    }

    private fun importCallRecording(result: MethodChannel.Result) {
        expirePendingCallIfNeeded()
        val call = pendingCall
        if (call == null || call.isExpired()) {
            notifyError(
                code = "NO_PENDING_LEAD",
                message = "Please start the call from a lead before importing a recording.",
            )
            result.success(false)
            return
        }

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "audio/*"
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION)
        }
        try {
            activity.startActivityForResult(intent, CallRecordingConfig.REQUEST_IMPORT_RECORDING)
            Log.i(CallRecordingConfig.TAG, "Opened document picker for leadId=${call.leadId}")
            result.success(true)
        } catch (e: Exception) {
            Log.e(CallRecordingConfig.TAG, "Failed to open document picker", e)
            notifyError(
                code = "URI_ACCESS_ERROR",
                message = "Unable to access the selected recording.",
                leadId = call.leadId,
            )
            result.success(false)
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != CallRecordingConfig.REQUEST_IMPORT_RECORDING) return

        expirePendingCallIfNeeded()
        val call = pendingCall
        if (resultCode != Activity.RESULT_OK) {
            Log.i(CallRecordingConfig.TAG, "Import picker cancelled")
            notifyError(
                code = "IMPORT_CANCELLED",
                message = "Import cancelled.",
                leadId = call?.leadId,
            )
            return
        }

        val uri = data?.data
        if (uri == null) {
            notifyError(
                code = "URI_ACCESS_ERROR",
                message = "Unable to access the selected recording.",
                leadId = call?.leadId,
            )
            return
        }

        if (call == null || call.isExpired()) {
            notifyError(
                code = "NO_PENDING_LEAD",
                message = "Please start the call from a lead before importing a recording.",
            )
            return
        }

        resolveAndProcess(uri, source = "import", intent = data, leadId = call.leadId)
    }

    fun handleIncomingShare(intent: Intent?) {
        if (intent == null) return
        val action = intent.action ?: return
        if (action != Intent.ACTION_SEND && action != Intent.ACTION_SEND_MULTIPLE) return

        expirePendingCallIfNeeded()

        if (action == Intent.ACTION_SEND_MULTIPLE) {
            val uris = shareUris(intent)
            if (uris.size > 1) {
                notifyError(
                    code = "MULTIPLE_FILES_SELECTED",
                    message = "Please share one call recording at a time.",
                    leadId = pendingCall?.leadId,
                )
                return
            }
            if (uris.isEmpty()) {
                notifyError(
                    code = "URI_ACCESS_ERROR",
                    message = "Unable to access the selected recording.",
                    leadId = pendingCall?.leadId,
                )
                return
            }
            handleSharedUri(uris.first(), intent)
            return
        }

        val uri = shareUri(intent)
        if (uri == null) {
            notifyError(
                code = "URI_ACCESS_ERROR",
                message = "Unable to access the selected recording.",
                leadId = pendingCall?.leadId,
            )
            return
        }
        handleSharedUri(uri, intent)
    }

    private fun handleSharedUri(uri: Uri, intent: Intent) {
        val call = pendingCall
        if (call == null || call.isExpired()) {
            notifyError(
                code = "NO_PENDING_LEAD",
                message = "Please open a lead and start the call from the CRM before importing a recording.",
            )
            return
        }
        resolveAndProcess(uri, source = "share", intent = intent, leadId = call.leadId)
    }

    private fun resolveAndProcess(uri: Uri, source: String, intent: Intent?, leadId: Long) {
        ioExecutor.execute {
            try {
                importResolver.cleanupExpiredCache()
                val resolved = importResolver.resolve(uri, source, intent)
                mainHandler.post {
                    cachedImportFile?.let { previous ->
                        if (previous != resolved.cachedFile) {
                            importResolver.deleteCacheFile(previous)
                        }
                    }
                    cachedImportFile = resolved.cachedFile
                    processRecording(leadId, resolved.candidate)
                }
            } catch (e: InvalidAudioException) {
                mainHandler.post {
                    notifyError(
                        code = "INVALID_AUDIO",
                        message = e.message
                            ?: "The selected file is not a valid audio recording.",
                        leadId = leadId,
                    )
                }
            } catch (e: UriAccessException) {
                mainHandler.post {
                    notifyError(
                        code = "URI_ACCESS_ERROR",
                        message = e.message ?: "Unable to access the selected recording.",
                        leadId = leadId,
                    )
                }
            } catch (e: Exception) {
                Log.e(CallRecordingConfig.TAG, "Failed to import recording", e)
                mainHandler.post {
                    notifyError(
                        code = "URI_ACCESS_ERROR",
                        message = "Unable to access the selected recording.",
                        leadId = leadId,
                    )
                }
            }
        }
    }

    private fun shareUri(intent: Intent): Uri? {
        extraShareUri(intent)?.let { return it }
        intent.clipData?.takeIf { it.itemCount > 0 }?.getItemAt(0)?.uri?.let { return it }
        return intent.data
    }

    private fun shareUris(intent: Intent): List<Uri> {
        extraShareUris(intent).takeIf { it.isNotEmpty() }?.let { return it }
        val clip = intent.clipData ?: return emptyList()
        return buildList {
            for (i in 0 until clip.itemCount) {
                clip.getItemAt(i).uri?.let { add(it) }
            }
        }
    }

    private fun extraShareUri(intent: Intent): Uri? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(Intent.EXTRA_STREAM)
        }
    }

    private fun extraShareUris(intent: Intent): List<Uri> {
        val list = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableArrayListExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableArrayListExtra<Uri>(Intent.EXTRA_STREAM)
        }
        return list?.filterNotNull().orEmpty()
    }

    private fun expirePendingCallIfNeeded() {
        val call = pendingCall ?: return
        if (!call.isExpired()) return
        Log.i(CallRecordingConfig.TAG, "Pending call expired for leadId=${call.leadId}")
        clearPendingCall(call.leadId)
        resumeRetryCall = null
        resumeRetryScheduled = false
    }

    private fun cleanupCachedImport(keepForRetry: Boolean) {
        if (keepForRetry) return
        importResolver.deleteCacheFile(cachedImportFile)
        cachedImportFile = null
        importResolver.cleanupExpiredCache()
    }

    private fun notifyTranscriptionPermissionDenied(leadId: Long) {
        invokeFlutter("onTranscriptionError", mapOf(
            "event" to "transcription_error",
            "leadId" to leadId,
            "code" to "SPEECH_RECOGNITION_PERMISSION_DENIED",
            "message" to "Microphone permission is required for on-device speech recognition.",
            "success" to false,
        ))
    }

    private fun callRecordingPermissions(): List<String> = buildList {
        add(requiredAudioPermission())
        add(Manifest.permission.RECORD_AUDIO)
    }

    private fun requestCallRecordingPermissionsIfNeeded() {
        val missing = callRecordingPermissions().filterNot { hasPermission(it) }
        if (missing.isEmpty()) return

        ensurePermissions(
            permissions = missing,
            onAllGranted = {
                Log.i(CallRecordingConfig.TAG, "Call recording permissions granted")
            },
            onDenied = { denied ->
                Log.w(
                    CallRecordingConfig.TAG,
                    "Call recording permissions denied: ${denied.joinToString()}",
                )
            },
        )
    }

    private fun ensureMediaPermission(onGranted: () -> Unit) {
        ensurePermissions(
            permissions = listOf(requiredAudioPermission()),
            onAllGranted = onGranted,
            onDenied = {
                pendingCall?.awaitingImport = true
                notifyError(
                    code = "MEDIA_PERMISSION_DENIED",
                    message = "Audio access permission is required to detect call recordings.",
                )
            },
        )
    }

    private fun ensureRecordAudioPermission(
        request: CallRecordingTranscriber.Request,
        onGranted: () -> Unit,
    ) {
        ensurePermissions(
            permissions = listOf(Manifest.permission.RECORD_AUDIO),
            onAllGranted = onGranted,
            onDenied = {
                pendingTranscribeRequest = null
                notifyTranscriptionPermissionDenied(request.leadId)
            },
        )
    }

    private fun ensurePermissions(
        permissions: List<String>,
        onAllGranted: () -> Unit,
        onDenied: (List<String>) -> Unit,
    ) {
        val missing = permissions.filterNot { hasPermission(it) }.toSet()
        if (missing.isEmpty()) {
            onAllGranted()
            return
        }

        permissionWorkQueue.add(
            PendingPermissionWork(
                permissions = missing,
                onAllGranted = onAllGranted,
                onDenied = onDenied,
            ),
        )
        drainPermissionQueue()
    }

    private fun drainPermissionQueue() {
        if (permissionRequestInFlight) return

        while (permissionWorkQueue.isNotEmpty()) {
            val work = permissionWorkQueue.first()
            val stillMissing = work.permissions.filterNot { hasPermission(it) }
            if (stillMissing.isEmpty()) {
                permissionWorkQueue.removeFirst()
                work.onAllGranted()
                continue
            }
            break
        }

        if (permissionWorkQueue.isEmpty()) return

        val batchedMissing = permissionWorkQueue
            .flatMap { work -> work.permissions.filterNot { hasPermission(it) } }
            .distinct()

        if (batchedMissing.isEmpty()) {
            drainPermissionQueue()
            return
        }

        permissionRequestInFlight = true
        Log.i(
            CallRecordingConfig.TAG,
            "Requesting permissions: ${batchedMissing.joinToString()}",
        )
        ActivityCompat.requestPermissions(
            activity,
            batchedMissing.toTypedArray(),
            CallRecordingConfig.REQUEST_CALL_RECORDING,
        )

        // Android silently drops concurrent permission requests — retry on resume.
        mainHandler.postDelayed({
            if (!permissionRequestInFlight) return@postDelayed
            val callbackMissing = permissionWorkQueue.any { work ->
                work.permissions.any { !hasPermission(it) }
            }
            if (callbackMissing) {
                Log.w(
                    CallRecordingConfig.TAG,
                    "Permission dialog may have been dropped — will retry on resume",
                )
            }
        }, 1_500L)
    }

    private fun hasPermission(permission: String): Boolean {
        return ContextCompat.checkSelfPermission(activity, permission) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun requiredAudioPermission(): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_AUDIO
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }
    }

    private fun stopTracking(clearPending: Boolean) {
        stopCallStateMonitor()
        if (clearPending) {
            pendingCall = null
            resumeRetryCall = null
            resumeRetryScheduled = false
        }
    }

    private fun stopCallStateMonitor() {
        callStateMonitor?.stop()
        callStateMonitor = null
    }

    private fun clearPendingCall(leadId: Long) {
        if (pendingCall?.leadId == leadId) {
            pendingCall = null
        }
        callStateMonitor?.reset()
    }

    private fun invokeFlutter(method: String, arguments: Map<String, Any?>) {
        mainHandler.post {
            try {
                channel.invokeMethod(method, arguments)
            } catch (e: Exception) {
                Log.w(CallRecordingConfig.TAG, "Failed to invoke Flutter method $method", e)
            }
        }
    }

    fun dispose() {
        stopTracking(clearPending = true)
        transcriber.dispose()
        cleanupCachedImport(keepForRetry = false)
        ioExecutor.shutdown()
    }
}
