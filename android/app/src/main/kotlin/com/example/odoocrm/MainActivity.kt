package com.bigoh.odoocrm

import android.Manifest
import android.accounts.AccountManager
import android.content.ContentProviderOperation
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.ContactsContract
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.bigoh.odoocrm.callrecording.CallRecordingChannelHandler
import com.bigoh.odoocrm.callrecording.CallRecordingConfig
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors

/**
 * WhatsApp MethodChannel (`com.bigoh.odoocrm/whatsapp`).
 *
 * Methods:
 * - `startWhatsAppCall` `{ phone }` → success | fallback_chat | not_on_whatsapp |
 *   not_installed | error
 * - `isOnWhatsApp` `{ phone }` → registered | not_registered | unknown | not_installed | error
 *
 * Unknown numbers: creates a short-lived local contact with WhatsApp voip MIME rows,
 * launches the voice-call intent, then deletes the contact.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.bigoh.odoocrm/whatsapp"
    private val tag = "WhatsAppChannel"
    private val whatsAppPackages = listOf("com.whatsapp", "com.whatsapp.w4b")
    private val ioExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    private var callRecordingHandler: CallRecordingChannelHandler? = null

    private var pendingCallResult: MethodChannel.Result? = null
    private var pendingPhone: String? = null
    private var pendingAction: String? = null

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
                        beginWithPermissions(phone, result, ACTION_CALL)
                    }
                    "isOnWhatsApp" -> {
                        val phone = call.argument<String>("phone")?.trim().orEmpty()
                        if (phone.isEmpty()) {
                            result.success("error")
                            return@setMethodCallHandler
                        }
                        beginWithPermissions(phone, result, ACTION_CHECK)
                    }
                    else -> result.notImplemented()
                }
            }

        val callRecordingChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CallRecordingConfig.CHANNEL_NAME,
        )
        callRecordingHandler = CallRecordingChannelHandler(this, callRecordingChannel).also { handler ->
            callRecordingChannel.setMethodCallHandler { call, result ->
                handler.handleMethodCall(call.method, call.arguments, result)
            }
        }
    }

    override fun onDestroy() {
        callRecordingHandler?.dispose()
        callRecordingHandler = null
        super.onDestroy()
    }

    override fun onResume() {
        super.onResume()
        callRecordingHandler?.onActivityResumed()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == CallRecordingConfig.REQUEST_CALL_RECORDING) {
            callRecordingHandler?.onRequestPermissionsResult(
                requestCode,
                permissions,
                grantResults,
            )
            return
        }

        if (requestCode != REQUEST_WHATSAPP) return

        val phone = pendingPhone
        val result = pendingCallResult
        val action = pendingAction
        pendingPhone = null
        pendingCallResult = null
        pendingAction = null
        if (phone == null || result == null || action == null) return

        // Continue even if contacts were denied — we can still try jid/chat paths.
        dispatchAction(action, phone, result)
    }

    private fun beginWithPermissions(
        phone: String,
        result: MethodChannel.Result,
        action: String,
    ) {
        if (resolveWhatsAppPackage() == null) {
            result.success("not_installed")
            return
        }

        val needsRead = !hasReadContactsPermission()
        val needsWrite = action == ACTION_CALL && !hasWriteContactsPermission()
        if (needsRead || needsWrite) {
            pendingPhone = phone
            pendingCallResult = result
            pendingAction = action
            val permissions = buildList {
                add(Manifest.permission.READ_CONTACTS)
                if (action == ACTION_CALL) {
                    add(Manifest.permission.WRITE_CONTACTS)
                    add(Manifest.permission.CALL_PHONE)
                }
            }.toTypedArray()
            ActivityCompat.requestPermissions(this, permissions, REQUEST_WHATSAPP)
            return
        }

        dispatchAction(action, phone, result)
    }

    private fun dispatchAction(action: String, phone: String, result: MethodChannel.Result) {
        when (action) {
            ACTION_CHECK -> {
                ioExecutor.execute {
                    val status = checkIsOnWhatsApp(phone)
                    mainHandler.post { result.success(status) }
                }
            }
            ACTION_CALL -> {
                ioExecutor.execute {
                    val status = startWhatsAppCallInternal(phone)
                    // Delay the Flutter reply so delivering the MethodChannel result
                    // does not pull MainActivity back over WhatsApp's call trampoline.
                    val delayMs = when (status) {
                        "success", "opened_dialer", "fallback_chat" -> 600L
                        else -> 0L
                    }
                    mainHandler.postDelayed({
                        try {
                            result.success(status)
                        } catch (e: Exception) {
                            Log.w(tag, "Failed to send call result to Flutter", e)
                        }
                    }, delayMs)
                }
            }
        }
    }

    private fun startWhatsAppCallInternal(phone: String): String {
        val packageName = resolveWhatsAppPackage() ?: return "not_installed"
        val digits = phone.filter { it.isDigit() }
        if (digits.isEmpty()) return "error"

        Log.i(tag, "startWhatsAppCall v4 digits=$digits pkg=$packageName")

        // Presence check first (best-effort).
        when (checkIsOnWhatsApp(digits)) {
            "not_registered" -> return "not_on_whatsapp"
            "not_installed" -> return "not_installed"
        }

        // 1) Existing WhatsApp-synced contact → real voip content URI.
        if (hasReadContactsPermission()) {
            findWhatsAppVoipTarget(packageName, digits)?.let { voip ->
                if (launchVoipCall(packageName, voip)) {
                    Log.i(tag, "Call via existing contact dataId=${voip.dataId}")
                    return "success"
                }
            }
        }

        // 2) Unknown number: create cloud-account contact + voip MIME, then call.
        //    Skip whatsapp://call — it opens WhatsApp but does NOT start a voice call.
        createTemporaryVoipContact(packageName, digits)?.let { voip ->
            val launched = launchVoipCall(packageName, voip)
            scheduleTempContactCleanup(voip.rawContactId)
            if (launched) {
                Log.i(tag, "Call via temp contact dataId=${voip.dataId}")
                return "success"
            }
        }

        // 3) Open WhatsApp dialer (user taps Call) when available.
        if (tryOpenWhatsAppDialer(packageName, digits)) {
            Log.i(tag, "Opened WhatsApp dialer for $digits")
            return "opened_dialer"
        }

        // 4) Chat fallback — user can tap the call icon inside the chat.
        Log.w(tag, "Voip unavailable; opening chat for $digits")
        return if (tryOpenChat(packageName, digits)) "fallback_chat" else "error"
    }

    /**
     * Opens WhatsApp's in-app dialer with the number when that activity exists.
     */
    private fun tryOpenWhatsAppDialer(packageName: String, digits: String): Boolean {
        val withPlus = "+$digits"
        val dialerClasses = listOf(
            "com.whatsapp.calling.dialer.DialerActivity",
            "com.whatsapp.calling.ui.DialerActivity",
            "com.whatsapp.calling.dialer.DialerPhoneNumberChooserActivity",
        )

        for (cls in dialerClasses) {
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setClassName(packageName, cls)
                data = Uri.parse("tel:$withPlus")
                putExtra("number", digits)
                putExtra("phone", digits)
                putExtra("android.intent.extra.PHONE_NUMBER", withPlus)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            if (canResolve(intent) && startWhatsAppExternal(intent)) {
                Log.i(tag, "Dialer started: $cls")
                return true
            }
        }
        return false
    }

    private fun canResolve(intent: Intent): Boolean {
        return try {
            packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY) != null
        } catch (_: Exception) {
            false
        }
    }

    /**
     * Best-effort registration check.
     *
     * 1) Local WhatsApp-synced contact rows → registered
     * 2) HTTP probe of wa.me / api.whatsapp.com for known "invalid" markers
     * 3) Otherwise → unknown (caller may still attempt the call)
     */
    private fun checkIsOnWhatsApp(phone: String): String {
        if (resolveWhatsAppPackage() == null) return "not_installed"
        val digits = phone.filter { it.isDigit() }
        if (digits.isEmpty()) return "error"

        if (hasReadContactsPermission() && hasLocalWhatsAppPresence(digits)) {
            return "registered"
        }

        return when (probeWhatsAppRegistration(digits)) {
            true -> "registered"
            false -> "not_registered"
            null -> "unknown"
        }
    }

    private fun hasLocalWhatsAppPresence(digits: String): Boolean {
        val packageName = resolveWhatsAppPackage() ?: return false
        if (findWhatsAppVoipTarget(packageName, digits) != null) return true

        val variants = phoneVariants(digits)
        val messageMimes = listOf(
            "vnd.android.cursor.item/vnd.com.whatsapp.profile",
            "vnd.android.cursor.item/vnd.com.whatsapp.w4b.profile",
            "vnd.android.cursor.item/vnd.com.whatsapp.account",
        )
        for (mime in messageMimes) {
            for (variant in variants) {
                val jid = "$variant@s.whatsapp.net"
                contentResolver.query(
                    ContactsContract.Data.CONTENT_URI,
                    arrayOf(ContactsContract.Data._ID),
                    "${ContactsContract.Data.MIMETYPE}=? AND ${ContactsContract.Data.DATA1}=?",
                    arrayOf(mime, jid),
                    null,
                )?.use { if (it.moveToFirst()) return true }
            }
        }
        return false
    }

    /**
     * Returns true/false when the probe is conclusive, null when inconclusive.
     */
    private fun probeWhatsAppRegistration(digits: String): Boolean? {
        val urls = listOf(
            "https://api.whatsapp.com/send/?phone=$digits&text&type=phone_number&app_absent=0",
            "https://wa.me/$digits",
        )
        for (url in urls) {
            try {
                val connection = (URL(url).openConnection() as HttpURLConnection).apply {
                    instanceFollowRedirects = true
                    connectTimeout = 6_000
                    readTimeout = 6_000
                    requestMethod = "GET"
                    setRequestProperty(
                        "User-Agent",
                        "Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 "
                            + "Chrome/120.0.0.0 Mobile Safari/537.36",
                    )
                    setRequestProperty("Accept", "text/html,application/xhtml+xml")
                }
                val code = connection.responseCode
                val body = try {
                    (if (code in 200..399) connection.inputStream else connection.errorStream)
                        ?.bufferedReader()
                        ?.use { it.readText() }
                        .orEmpty()
                } catch (_: Exception) {
                    ""
                } finally {
                    connection.disconnect()
                }

                val lower = body.lowercase()
                if (lower.contains("phone number shared via url is invalid")
                    || lower.contains("phone number is invalid")
                    || lower.contains("invalid phone number")
                ) {
                    return false
                }
                // Inconclusive HTML / challenge pages are common; keep trying.
            } catch (e: Exception) {
                Log.d(tag, "Presence probe failed for $url", e)
            }
        }
        return null
    }

    private data class VoipTarget(
        val dataId: Long,
        val mimeType: String,
        val rawContactId: Long? = null,
    )

    private fun findWhatsAppVoipTarget(packageName: String, digits: String): VoipTarget? {
        if (!hasReadContactsPermission()) return null

        val mimes = voipMimeTypes(packageName)
        val variants = phoneVariants(digits)

        for (mime in mimes) {
            for (variant in variants) {
                val jid = "$variant@s.whatsapp.net"
                queryVoipId(mime, "${ContactsContract.Data.DATA1}=?", arrayOf(jid))
                    ?.let { return VoipTarget(it, mime) }
            }
        }

        for (contactId in findContactIdsByPhone(variants)) {
            for (mime in mimes) {
                queryVoipId(
                    mime,
                    "${ContactsContract.Data.CONTACT_ID}=?",
                    arrayOf(contactId.toString()),
                )?.let { return VoipTarget(it, mime) }
            }
        }

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

    /**
     * Inserts an ephemeral contact with WhatsApp voip MIME so we can launch a
     * call intent for numbers that are not already saved / synced.
     *
     * Modern Android (default account = cloud) rejects local/SIM inserts with:
     * "Cannot add contacts to local or SIM accounts when default account is set to cloud".
     * So we must write into a cloud account (Google / OEM sign-in).
     */
    private fun createTemporaryVoipContact(packageName: String, digits: String): VoipTarget? {
        if (!hasWriteContactsPermission()) return null

        val mime = voipMimeTypes(packageName).first()
        val jid = "$digits@s.whatsapp.net"
        val displayName = "CRM WA $digits"
        val accounts = resolveWritableContactAccounts()

        for (account in accounts) {
            if (account.type.isNullOrBlank() || account.name.isNullOrBlank()) {
                continue
            }
            try {
                val target = insertTemporaryVoipContact(
                    account = account,
                    packageName = packageName,
                    mime = mime,
                    jid = jid,
                    digits = digits,
                    displayName = displayName,
                )
                if (target != null) {
                    Log.i(
                        tag,
                        "Temp contact created on ${account.type}/${account.name} dataId=${target.dataId}",
                    )
                    return target
                }
            } catch (e: Exception) {
                Log.w(tag, "Temp contact insert failed for ${account.type}/${account.name}", e)
            }
        }

        Log.e(tag, "Failed to create temporary WhatsApp contact on any cloud account (v4)")
        return null
    }

    private fun insertTemporaryVoipContact(
        account: ContactAccount,
        packageName: String,
        mime: String,
        jid: String,
        digits: String,
        displayName: String,
    ): VoipTarget? {
        val ops = ArrayList<ContentProviderOperation>()
        ops.add(
            ContentProviderOperation.newInsert(ContactsContract.RawContacts.CONTENT_URI)
                .withValue(ContactsContract.RawContacts.ACCOUNT_TYPE, account.type)
                .withValue(ContactsContract.RawContacts.ACCOUNT_NAME, account.name)
                .build(),
        )
        ops.add(
            ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                .withValue(
                    ContactsContract.Data.MIMETYPE,
                    ContactsContract.CommonDataKinds.StructuredName.CONTENT_ITEM_TYPE,
                )
                .withValue(
                    ContactsContract.CommonDataKinds.StructuredName.DISPLAY_NAME,
                    displayName,
                )
                .build(),
        )
        ops.add(
            ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                .withValue(
                    ContactsContract.Data.MIMETYPE,
                    ContactsContract.CommonDataKinds.Phone.CONTENT_ITEM_TYPE,
                )
                .withValue(ContactsContract.CommonDataKinds.Phone.NUMBER, "+$digits")
                .withValue(
                    ContactsContract.CommonDataKinds.Phone.TYPE,
                    ContactsContract.CommonDataKinds.Phone.TYPE_MOBILE,
                )
                .build(),
        )
        ops.add(
            ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                .withValue(
                    ContactsContract.Data.MIMETYPE,
                    if (packageName == "com.whatsapp.w4b") {
                        "vnd.android.cursor.item/vnd.com.whatsapp.w4b.profile"
                    } else {
                        "vnd.android.cursor.item/vnd.com.whatsapp.profile"
                    },
                )
                .withValue(ContactsContract.Data.DATA1, jid)
                .build(),
        )
        ops.add(
            ContentProviderOperation.newInsert(ContactsContract.Data.CONTENT_URI)
                .withValueBackReference(ContactsContract.Data.RAW_CONTACT_ID, 0)
                .withValue(ContactsContract.Data.MIMETYPE, mime)
                .withValue(ContactsContract.Data.DATA1, jid)
                .withValue(ContactsContract.Data.DATA2, "WhatsApp Call")
                .build(),
        )

        val results = contentResolver.applyBatch(ContactsContract.AUTHORITY, ops)
        val rawContactId = results[0].uri?.lastPathSegment?.toLongOrNull()

        var dataId: Long? = null
        if (rawContactId != null) {
            contentResolver.query(
                ContactsContract.Data.CONTENT_URI,
                arrayOf(ContactsContract.Data._ID),
                "${ContactsContract.Data.RAW_CONTACT_ID}=? AND ${ContactsContract.Data.MIMETYPE}=?",
                arrayOf(rawContactId.toString(), mime),
                null,
            )?.use { cursor ->
                if (cursor.moveToFirst()) dataId = cursor.getLong(0)
            }
        }
        if (dataId == null) {
            dataId = queryVoipId(mime, "${ContactsContract.Data.DATA1}=?", arrayOf(jid))
        }

        return if (dataId == null) {
            rawContactId?.let { deleteRawContact(it) }
            null
        } else {
            VoipTarget(dataId!!, mime, rawContactId)
        }
    }

    private data class ContactAccount(val name: String?, val type: String?)

    /**
     * Cloud / WhatsApp accounts only. Never uses local/SIM (Android rejects those
     * when the device default account is cloud).
     */
    private fun resolveWritableContactAccounts(): List<ContactAccount> {
        val preferredTypes = listOf(
            "com.whatsapp",
            "com.whatsapp.w4b",
            "com.google",
            "com.google.android.gm.exchange",
            "com.osp.app.signin",
            "com.xiaomi",
            "com.huawei.hwid",
        )
        val ordered = linkedSetOf<ContactAccount>()

        // 0) Platform default account for new contacts (API 35+).
        defaultAccountForNewContacts()?.let { ordered.add(it) }

        // 1) Contacts settings rows.
        try {
            contentResolver.query(
                ContactsContract.Settings.CONTENT_URI,
                arrayOf(
                    ContactsContract.Settings.ACCOUNT_NAME,
                    ContactsContract.Settings.ACCOUNT_TYPE,
                ),
                null,
                null,
                null,
            )?.use { cursor ->
                val nameIdx = cursor.getColumnIndex(ContactsContract.Settings.ACCOUNT_NAME)
                val typeIdx = cursor.getColumnIndex(ContactsContract.Settings.ACCOUNT_TYPE)
                while (cursor.moveToNext()) {
                    val type = cursor.getString(typeIdx) ?: continue
                    val name = cursor.getString(nameIdx) ?: continue
                    if (!isLocalOrSimAccount(type)) {
                        ordered.add(ContactAccount(name, type))
                    }
                }
            }
        } catch (e: Exception) {
            Log.w(tag, "Contacts settings account lookup failed", e)
        }

        // 2) Accounts already used by contacts on this device.
        try {
            contentResolver.query(
                ContactsContract.RawContacts.CONTENT_URI,
                arrayOf(
                    ContactsContract.RawContacts.ACCOUNT_NAME,
                    ContactsContract.RawContacts.ACCOUNT_TYPE,
                ),
                "${ContactsContract.RawContacts.ACCOUNT_TYPE} IS NOT NULL AND "
                    + "${ContactsContract.RawContacts.DELETED}=0",
                null,
                null,
            )?.use { cursor ->
                val nameIdx = cursor.getColumnIndex(ContactsContract.RawContacts.ACCOUNT_NAME)
                val typeIdx = cursor.getColumnIndex(ContactsContract.RawContacts.ACCOUNT_TYPE)
                val discovered = mutableListOf<ContactAccount>()
                while (cursor.moveToNext()) {
                    val type = cursor.getString(typeIdx) ?: continue
                    val name = cursor.getString(nameIdx) ?: continue
                    if (isLocalOrSimAccount(type)) continue
                    discovered.add(ContactAccount(name, type))
                }
                for (pref in preferredTypes) {
                    discovered.filter { it.type == pref }.forEach { ordered.add(it) }
                }
                discovered.forEach { ordered.add(it) }
            }
        } catch (e: Exception) {
            Log.w(tag, "Failed to discover contact accounts from RawContacts", e)
        }

        // 3) AccountManager.
        try {
            val am = AccountManager.get(this)
            for (pref in preferredTypes) {
                for (account in am.getAccountsByType(pref)) {
                    ordered.add(ContactAccount(account.name, account.type))
                }
            }
            for (account in am.accounts) {
                if (!isLocalOrSimAccount(account.type)) {
                    ordered.add(ContactAccount(account.name, account.type))
                }
            }
        } catch (e: Exception) {
            Log.w(tag, "AccountManager lookup failed", e)
        }

        // Prefer WhatsApp / Google first in final order.
        val preferred = ordered.filter { it.type in preferredTypes }
        val rest = ordered.filterNot { it.type in preferredTypes }
        val result = (preferred + rest).distinct()
        Log.i(tag, "Writable contact accounts: $result")
        return result
    }

    private fun defaultAccountForNewContacts(): ContactAccount? {
        return try {
            // android.provider.ContactsContract.RawContacts.DefaultAccount (API 35+)
            val clazz = Class.forName(
                "android.provider.ContactsContract\$RawContacts\$DefaultAccount",
            )
            val method = clazz.getMethod(
                "getDefaultAccountForNewContacts",
                android.content.ContentResolver::class.java,
            )
            val account = method.invoke(null, contentResolver) as? android.accounts.Account
                ?: return null
            if (isLocalOrSimAccount(account.type)) return null
            ContactAccount(account.name, account.type)
        } catch (_: Throwable) {
            null
        }
    }

    private fun isLocalOrSimAccount(type: String): Boolean {
        val t = type.lowercase()
        return t.contains("sim")
            || t.contains("local")
            || t == "com.android.localphone"
            || t == "vnd.sec.contact.phone"
            || t == "com.android.contacts.sim"
            || t == "com.android.mtk"
            || t == "device"
            || t == "phone"
    }

    private fun scheduleTempContactCleanup(rawContactId: Long?) {
        if (rawContactId == null) return
        mainHandler.postDelayed({
            ioExecutor.execute { deleteRawContact(rawContactId) }
        }, 30_000L)
    }

    private fun deleteRawContact(rawContactId: Long) {
        try {
            contentResolver.delete(
                ContactsContract.RawContacts.CONTENT_URI,
                "${ContactsContract.RawContacts._ID}=?",
                arrayOf(rawContactId.toString()),
            )
            Log.i(tag, "Deleted temp raw contact $rawContactId")
        } catch (e: Exception) {
            Log.w(tag, "Failed to delete temp contact $rawContactId", e)
        }
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
            if (cursor.moveToFirst()) return cursor.getLong(0)
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
                    while (cursor.moveToNext()) ids.add(cursor.getLong(0))
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
                while (cursor.moveToNext()) ids.add(cursor.getLong(0))
            }
        }
        return ids
    }

    private fun launchVoipCall(packageName: String, target: VoipTarget): Boolean {
        val dataUri = Uri.parse("content://com.android.contacts/data/${target.dataId}")

        // Use a single landing intent. Launching VIEW and then landing back-to-back
        // causes: WhatsApp → CRM → WhatsApp call UI.
        val landing = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(dataUri, target.mimeType)
            setClassName(
                packageName,
                "com.whatsapp.accountsync.CallContactLandingActivity",
            )
            setPackage(packageName)
        }
        if (startWhatsAppExternal(landing)) return true

        val view = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(dataUri, target.mimeType)
            setPackage(packageName)
        }
        return startWhatsAppExternal(view)
    }

    private fun tryOpenChat(packageName: String, digits: String): Boolean {
        val intents = listOf(
            Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("whatsapp://send?phone=$digits")
                setPackage(packageName)
            },
            Intent(Intent.ACTION_VIEW).apply {
                data = Uri.parse("https://wa.me/$digits")
                setPackage(packageName)
            },
        )
        for (intent in intents) {
            if (startWhatsAppExternal(intent)) return true
        }
        return false
    }

    private fun phoneVariants(digits: String): List<String> {
        val out = linkedSetOf<String>()
        out.add(digits)
        if (digits.length > 10) out.add(digits.takeLast(10))
        if (digits.length == 10) out.add("91$digits")
        if (digits.startsWith("0") && digits.length > 10) out.add(digits.drop(1))
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

    private fun hasReadContactsPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_CONTACTS,
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun hasWriteContactsPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.WRITE_CONTACTS,
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

    /**
     * Starts WhatsApp on the main thread and immediately pushes our task back so
     * WhatsApp's CallContactLandingActivity trampoline cannot briefly resume CRM
     * before the real call UI appears (WA → CRM → WA call flash).
     */
    private fun startWhatsAppExternal(intent: Intent): Boolean {
        return try {
            val started = java.util.concurrent.atomic.AtomicBoolean(false)
            val latch = java.util.concurrent.CountDownLatch(1)
            mainHandler.post {
                try {
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    // Landing activities often finish() back to us; stay behind WhatsApp.
                    moveTaskToBack(true)
                    started.set(true)
                } catch (e: Exception) {
                    Log.d(tag, "Intent failed: $intent", e)
                } finally {
                    latch.countDown()
                }
            }
            latch.await(3, java.util.concurrent.TimeUnit.SECONDS)
            started.get()
        } catch (e: Exception) {
            Log.d(tag, "startWhatsAppExternal failed", e)
            false
        }
    }

    companion object {
        private const val REQUEST_WHATSAPP = 9911
        private const val ACTION_CALL = "call"
        private const val ACTION_CHECK = "check"
    }
}
