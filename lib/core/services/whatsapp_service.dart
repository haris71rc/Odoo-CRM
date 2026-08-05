import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/utils/phone_number_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// Outcome of a WhatsApp chat / call attempt.
enum WhatsAppLaunchResult {
  /// WhatsApp was opened successfully (chat or call UI).
  success,

  /// Direct call was unavailable; opened the chat conversation instead.
  openedChatFallback,

  /// WhatsApp is not installed on the device.
  notInstalled,

  /// Phone number was missing / invalid.
  invalidPhone,

  /// Platform does not support this action (e.g. call on iOS).
  unsupported,

  /// Launch failed for an unexpected reason.
  failed,
}

/// Cross-platform WhatsApp helpers. Call UI stays in widgets; launch logic here.
class WhatsAppService {
  WhatsAppService({
    MethodChannel? channel,
    this.defaultMessage =
        "Hello, I'm contacting you regarding your enquiry.",
  }) : _channel = channel ??
            const MethodChannel('com.bigoh.odoocrm/whatsapp');

  static const String whatsAppGreenHex = '#25D366';

  final MethodChannel _channel;
  final String defaultMessage;

  /// Opens a WhatsApp chat for [phone], optionally with a prefilled [message].
  Future<WhatsAppLaunchResult> openChat(
    String phone, {
    String? message,
  }) async {
    final normalized = PhoneNumberUtils.normalizeOrNull(phone);
    if (normalized == null) return WhatsAppLaunchResult.invalidPhone;

    final text = message ?? defaultMessage;
    final uri = Uri.https('wa.me', '/$normalized', {
      if (text.isNotEmpty) 'text': text,
    });

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        // Android package visibility / iOS queries can make this false even
        // when WhatsApp is present; still attempt an external launch.
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return launched
            ? WhatsAppLaunchResult.success
            : WhatsAppLaunchResult.notInstalled;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      return launched
          ? WhatsAppLaunchResult.success
          : WhatsAppLaunchResult.failed;
    } on PlatformException {
      return WhatsAppLaunchResult.failed;
    } catch (_) {
      return WhatsAppLaunchResult.failed;
    }
  }

  /// Starts a WhatsApp voice call on Android.
  ///
  /// Falls back to opening the chat when a direct call intent is unavailable.
  /// Not supported on iOS — returns [WhatsAppLaunchResult.unsupported].
  Future<WhatsAppLaunchResult> startCall(String phone) async {
    final normalized = PhoneNumberUtils.normalizeOrNull(phone);
    if (normalized == null) return WhatsAppLaunchResult.invalidPhone;

    if (kIsWeb || !Platform.isAndroid) {
      return WhatsAppLaunchResult.unsupported;
    }

    try {
      final raw = await _channel.invokeMethod<String>(
        'startWhatsAppCall',
        <String, dynamic>{'phone': normalized},
      );

      switch (raw) {
        case 'success':
          return WhatsAppLaunchResult.success;
        case 'fallback_chat':
          return WhatsAppLaunchResult.openedChatFallback;
        case 'not_installed':
          return WhatsAppLaunchResult.notInstalled;
        default:
          return WhatsAppLaunchResult.failed;
      }
    } on PlatformException catch (e) {
      if (e.code == 'not_installed') {
        return WhatsAppLaunchResult.notInstalled;
      }
      // Native call failed — still try chat so the user can reach the lead.
      final fallback = await openChat(normalized, message: '');
      if (fallback == WhatsAppLaunchResult.success) {
        return WhatsAppLaunchResult.openedChatFallback;
      }
      return WhatsAppLaunchResult.failed;
    } catch (_) {
      return WhatsAppLaunchResult.failed;
    }
  }

  /// User-facing message for [result], or `null` when no snackbar is needed.
  String? messageFor(WhatsAppLaunchResult result) {
    return switch (result) {
      WhatsAppLaunchResult.notInstalled => 'WhatsApp is not installed.',
      WhatsAppLaunchResult.invalidPhone => 'No phone number available',
      WhatsAppLaunchResult.unsupported =>
        'WhatsApp call is not available on this device.',
      WhatsAppLaunchResult.failed => 'Unable to open WhatsApp',
      WhatsAppLaunchResult.openedChatFallback =>
        'Opened chat. Save this number in Contacts to enable direct WhatsApp calls.',
      WhatsAppLaunchResult.success => null,
    };
  }
}

final whatsAppServiceProvider = Provider<WhatsAppService>((ref) {
  return WhatsAppService();
});
