package com.bigoh.odoocrm.callrecording

import android.content.Context
import android.os.Build
import android.telephony.PhoneStateListener
import android.telephony.TelephonyCallback
import android.telephony.TelephonyManager
import android.util.Log
import java.util.concurrent.Executor

/**
 * Monitors telephony call state (RINGING / OFFHOOK / IDLE) for tracked CRM calls.
 */
class CallStateMonitor(
    private val context: Context,
    private val onCallEnded: (callEndedAt: Long) -> Unit,
) {
    private val telephonyManager =
        context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager

    private var isRegistered = false
    private var phoneStateListener: PhoneStateListener? = null
    private var telephonyCallback: TelephonyCallback? = null

    /** Whether a tracked call has entered RINGING or OFFHOOK at least once. */
    var trackedCallWasActive: Boolean = false
        private set

    fun reset() {
        trackedCallWasActive = false
    }

    fun start() {
        if (isRegistered) return
        try {
            // Capture state if the call is already active when monitoring begins.
            try {
                @Suppress("DEPRECATION")
                val currentState = telephonyManager.callState
                if (currentState == TelephonyManager.CALL_STATE_RINGING ||
                    currentState == TelephonyManager.CALL_STATE_OFFHOOK
                ) {
                    trackedCallWasActive = true
                    Log.d(CallRecordingConfig.TAG, "Call already active at monitor start (state=$currentState)")
                }
            } catch (e: SecurityException) {
                Log.w(CallRecordingConfig.TAG, "Cannot read initial call state", e)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val callback = object : TelephonyCallback(), TelephonyCallback.CallStateListener {
                    override fun onCallStateChanged(state: Int) {
                        handleState(state)
                    }
                }
                telephonyCallback = callback
                val executor: Executor = context.mainExecutor
                telephonyManager.registerTelephonyCallback(executor, callback)
            } else {
                @Suppress("DEPRECATION")
                val listener = object : PhoneStateListener() {
                    @Deprecated("Deprecated in Java")
                    override fun onCallStateChanged(state: Int, phoneNumber: String?) {
                        handleState(state)
                    }
                }
                phoneStateListener = listener
                @Suppress("DEPRECATION")
                telephonyManager.listen(listener, PhoneStateListener.LISTEN_CALL_STATE)
            }
            isRegistered = true
            Log.i(CallRecordingConfig.TAG, "Call state monitor started")
        } catch (e: SecurityException) {
            Log.e(CallRecordingConfig.TAG, "Failed to register call state monitor", e)
        } catch (e: Exception) {
            Log.e(CallRecordingConfig.TAG, "Failed to register call state monitor", e)
        }
    }

    fun stop() {
        if (!isRegistered) return
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                telephonyCallback?.let { telephonyManager.unregisterTelephonyCallback(it) }
                telephonyCallback = null
            } else {
                @Suppress("DEPRECATION")
                phoneStateListener?.let {
                    telephonyManager.listen(it, PhoneStateListener.LISTEN_NONE)
                }
                phoneStateListener = null
            }
            isRegistered = false
            Log.i(CallRecordingConfig.TAG, "Call state monitor stopped")
        } catch (e: Exception) {
            Log.w(CallRecordingConfig.TAG, "Failed to unregister call state monitor", e)
        }
    }

    private fun handleState(state: Int) {
        when (state) {
            TelephonyManager.CALL_STATE_RINGING,
            TelephonyManager.CALL_STATE_OFFHOOK -> {
                trackedCallWasActive = true
                Log.d(CallRecordingConfig.TAG, "Call active (state=$state)")
            }
            TelephonyManager.CALL_STATE_IDLE -> {
                if (trackedCallWasActive) {
                    val endedAt = System.currentTimeMillis()
                    Log.i(CallRecordingConfig.TAG, "Call ended at $endedAt")
                    trackedCallWasActive = false
                    onCallEnded(endedAt)
                } else {
                    Log.d(CallRecordingConfig.TAG, "IDLE without active tracked call — ignored")
                }
            }
        }
    }
}
