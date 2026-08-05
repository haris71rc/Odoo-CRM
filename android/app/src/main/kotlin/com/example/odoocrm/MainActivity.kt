package com.bigoh.odoocrm

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.ContactsContract
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts the WhatsApp MethodChannel used by [WhatsAppService].
 *
 * Channel: `com.bigoh.odoocrm/whatsapp`
 * Method: `startWhatsAppCall` with `{ phone: String }`
 *
 * Returns:
 * - `success` — voice-call intent launched
 * - `fallback_chat` — call intent unavailable; opened chat instead
 * - `not_installed` — neither WhatsApp nor WhatsApp Business found
 * - `error` — unexpected failure
 *
 * Direct WhatsApp voice calls on Android require a Contacts row that WhatsApp
 * synced (`vnd…voip.call`). We request READ_CONTACTS, look that row up, then
 * fall back to opening the chat when a call cannot be started.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.bigoh.odoocrm/whatsapp"
    private val tag = "WhatsAppChannel"

    private val whatsAppPackages = listOf("com.whatsapp", "com.whatsapp.w4b")

    private var pendingCallResult: MethodChannel.Result? = null
    private var pendingPhone: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startWhatsAppCall" -> {
                        val phone = call.argument<String>("phone")?.trim().orEmpty()
                        if (phone.isEmpty()) {
                            result.success("error")
                            return@setMethodCallHandler
                        }
                        beginWhatsAppCall(phone, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != REQUEST_WHATSAPP_CALL) return

        val phone = pendingPhone
        val result = pendingCallResult
        pendingPhone = null
        pendingCallResult = null
        if (phone == null || result == null) return

        try {
            result.success(startWhatsAppCallInternal(phone))
        } catch (e: Exception) {
            Log.e(tag, "startWhatsAppCall after permission failed", e)
            result.success("error")
        }
    }

    private fun beginWhatsAppCall(phone: String, result: MethodChannel.Result) {
        if (resolveWhatsAppPackage() == null) {
            result.success("not_installed")
            return
        }

        // Contacts permission unlocks the only reliable voip.call intent path.
        if (!hasContactsPermission()) {
            pendingPhone = phone
            pendingCallResult = result
            ActivityCompat.requestPermissions(
                this,
                arrayOf(
                    Manifest.permission.READ_CONTACTS,
                    Manifest.permission.CALL_PHONE,
                ),
                REQUEST_WHATSAPP_CALL,
            )
            return
        }

        try {
            result.success(startWhatsAppCallInternal(phone))
        } catch (e: Exception) {
            Log.e(tag, "startWhatsAppCall failed", e)
            result.success("error")
        }
    }

    private fun startWhatsAppCallInternal(phone: String): String {
        val packageName = resolveWhatsAppPackage() ?: return "not_installed"
        val digits = phone.filter { it.isDigit() }
        if (digits.isEmpty()) return "error"

        val voip = findWhatsAppVoipTarget(packageName, digits)
        if (voip != null && launchVoipCall(packageName, voip)) {
            Log.i(tag, "Launched WhatsApp voip call dataId=${voip.dataId}")
            return "success"
        }

        // Last-resort jid landing activity (works on some WhatsApp builds only).
        if (tryCallLandingActivity(packageName, digits)) {
            Log.i(tag, "Launched CallContactLandingActivity for $digits")
            return "success"
        }

        Log.w(tag, "Voip call unavailable; falling back to chat for $digits")
        return if (tryOpenChat(packageName, digits)) {
            "fallback_chat"
        } else {
            "error"
        }
    }

    private data class VoipTarget(val dataId: Long, val mimeType: String)

    private fun findWhatsAppVoipTarget(packageName: String, digits: String): VoipTarget? {
        if (!hasContactsPermission()) return null

        val mimes = voipMimeTypes(packageName)
        val variants = phoneVariants(digits)

        // 1) Exact jid match on DATA1 (most common WhatsApp sync shape).
        for (mime in mimes) {
            for (variant in variants) {
                val jid = "$variant@s.whatsapp.net"
                queryVoipId(mime, "${ContactsContract.Data.DATA1}=?", arrayOf(jid))
                    ?.let { return VoipTarget(it, mime) }
            }
        }

        // 2) Contact matched by phone number → voip row for that contact.
        for (contactId in findContactIdsByPhone(variants)) {
            for (mime in mimes) {
                queryVoipId(
                    mime,
                    "${ContactsContract.Data.CONTACT_ID}=?",
                    arrayOf(contactId.toString()),
                )?.let { return VoipTarget(it, mime) }
            }
        }

        // 3) Fuzzy match last 10 digits against all voip DATA1 values.
        val needle = digits.takeLast(10)
        if (needle.length >= 8) {
            for (mime in mimes) {
                contentResolver.query(
                    ContactsContract.Data.CONTENT_URI,
                    arrayOf(ContactsContract.Data._ID, ContactsContract.Data.DATA1),
                    "${ContactsContract.Data.MIMETYPE}=?",
                    arrayOf(mime),
                    null,
                )?.use { cursor ->
                    val idIdx = cursor.getColumnIndexOrThrow(ContactsContract.Data._ID)
                    val dataIdx = cursor.getColumnIndexOrThrow(ContactsContract.Data.DATA1)
                    while (cursor.moveToNext()) {
                        val data1 = cursor.getString(dataIdx) ?: continue
                        val rowDigits = data1.substringBefore("@").filter { it.isDigit() }
                        if (rowDigits.endsWith(needle) || needle.endsWith(rowDigits.takeLast(10))) {
                            return VoipTarget(cursor.getLong(idIdx), mime)
                        }
                    }
                }
            }
        }

        return null
    }

    private fun queryVoipId(
        mime: String,
        extraSelection: String,
        extraArgs: Array<String>,
    ): Long? {
        val selection = "${ContactsContract.Data.MIMETYPE}=? AND $extraSelection"
        val args = arrayOf(mime) + extraArgs
        contentResolver.query(
            ContactsContract.Data.CONTENT_URI,
            arrayOf(ContactsContract.Data._ID),
            selection,
            args,
            null,
        )?.use { cursor ->
            if (cursor.moveToFirst()) {
                return cursor.getLong(0)
            }
        }
        return null
    }

    private fun findContactIdsByPhone(variants: List<String>): Set<Long> {
        val ids = linkedSetOf<Long>()
        for (variant in variants) {
            val uri = Uri.withAppendedPath(
                ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
                Uri.encode(variant),
            )
            try {
                contentResolver.query(
                    uri,
                    arrayOf(ContactsContract.PhoneLookup._ID),
                    null,
                    null,
                    null,
                )?.use { cursor ->
                    while (cursor.moveToNext()) {
                        ids.add(cursor.getLong(0))
                    }
                }
            } catch (e: Exception) {
                Log.w(tag, "PhoneLookup failed for $variant", e)
            }

            contentResolver.query(
                ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                arrayOf(ContactsContract.CommonDataKinds.Phone.CONTACT_ID),
                "${ContactsContract.CommonDataKinds.Phone.NORMALIZED_NUMBER} LIKE ? OR "
                    + "${ContactsContract.CommonDataKinds.Phone.NUMBER} LIKE ?",
                arrayOf("%$variant", "%$variant"),
                null,
            )?.use { cursor ->
                while (cursor.moveToNext()) {
                    ids.add(cursor.getLong(0))
                }
            }
        }
        return ids
    }

    private fun launchVoipCall(packageName: String, target: VoipTarget): Boolean {
        val dataUri = Uri.parse("content://com.android.contacts/data/${target.dataId}")
        val attempts = listOf(
            Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(dataUri, target.mimeType)
                setPackage(packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
            Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(dataUri, target.mimeType)
                setClassName(
                    packageName,
                    "com.whatsapp.accountsync.CallContactLandingActivity",
                )
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
        )
        for (intent in attempts) {
            if (safeStart(intent)) return true
        }
        return false
    }

    private fun tryCallLandingActivity(packageName: String, digits: String): Boolean {
        val jid = "$digits@s.whatsapp.net"
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setClassName(
                packageName,
                "com.whatsapp.accountsync.CallContactLandingActivity",
            )
            putExtra("jid", jid)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        return safeStart(intent)
    }

    private fun tryOpenChat(packageName: String, digits: String): Boolean {
        val intents = listOf(
            Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("whatsapp://send?phone=$digits")
                setPackage(packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
            Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("https://wa.me/$digits")
                setPackage(packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
            Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("https://api.whatsapp.com/send?phone=$digits")
                setPackage(packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            },
        )
        for (intent in intents) {
            if (safeStart(intent)) return true
        }
        return false
    }

    private fun phoneVariants(digits: String): List<String> {
        val out = linkedSetOf<String>()
        out.add(digits)
        if (digits.length > 10) out.add(digits.takeLast(10))
        if (digits.length == 10) out.add("91$digits")
        if (digits.startsWith("0") && digits.length > 10) {
            out.add(digits.drop(1))
        }
        return out.toList()
    }

    private fun voipMimeTypes(packageName: String): List<String> {
        return if (packageName == "com.whatsapp.w4b") {
            listOf(
                "vnd.android.cursor.item/vnd.com.whatsapp.w4b.voip.call",
                "vnd.android.cursor.item/vnd.com.whatsapp.voip.call",
            )
        } else {
            listOf(
                "vnd.android.cursor.item/vnd.com.whatsapp.voip.call",
                "vnd.android.cursor.item/vnd.com.whatsapp.w4b.voip.call",
            )
        }
    }

    private fun hasContactsPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_CONTACTS,
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun resolveWhatsAppPackage(): String? {
        for (pkg in whatsAppPackages) {
            if (isPackageInstalled(pkg)) return pkg
        }
        return null
    }

    private fun isPackageInstalled(packageName: String): Boolean {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getPackageInfo(
                    packageName,
                    PackageManager.PackageInfoFlags.of(0),
                )
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName, 0)
            }
            true
        } catch (_: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun safeStart(intent: Intent): Boolean {
        return try {
            startActivity(intent)
            true
        } catch (e: Exception) {
            Log.d(tag, "Intent failed: $intent", e)
            false
        }
    }

    companion object {
        private const val REQUEST_WHATSAPP_CALL = 9911
    }
}
