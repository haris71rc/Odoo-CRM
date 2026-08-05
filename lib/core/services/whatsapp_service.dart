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

  /// Opened WhatsApp dialer — user should tap Call.
  openedDialer,

  /// Number does not appear to be registered on WhatsApp.
  notOnWhatsApp,

  /// WhatsApp is not installed on the device.
  notInstalled,

  /// Phone number was missing / invalid.
  invalidPhone,

  /// Platform does not support this action (e.g. call on iOS).
  unsupported,

  /// Launch failed for an unexpected reason.
  failed,
}

/// Best-effort WhatsApp registration status for a phone number.
enum WhatsAppRegistration {
  registered,
  notRegistered,

  /// Could not determine (no public API; probe was inconclusive).
  unknown,
  notInstalled,
  invalidPhone,
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

  /// Best-effort check whether [phone] is registered on WhatsApp (Android).
  ///
  /// Uses local WhatsApp-synced contacts when available, then a lightweight
  /// web probe. There is no official consumer API, so [WhatsAppRegistration.unknown]
  /// means we could not prove either way.
  Future<WhatsAppRegistration> isOnWhatsApp(String phone) async {
    final normalized = PhoneNumberUtils.normalizeOrNull(phone);
    if (normalized == null) return WhatsAppRegistration.invalidPhone;

    if (kIsWeb || !Platform.isAndroid) {
      // iOS / web: no reliable local check; treat as unknown.
      return WhatsAppRegistration.unknown;
    }

    try {
      final raw = await _channel.invokeMethod<String>(
        'isOnWhatsApp',
        <String, dynamic>{'phone': normalized},
      );
      return switch (raw) {
        'registered' => WhatsAppRegistration.registered,
        'not_registered' => WhatsAppRegistration.notRegistered,
        'not_installed' => WhatsAppRegistration.notInstalled,
        'unknown' => WhatsAppRegistration.unknown,
        _ => WhatsAppRegistration.failed,
      };
    } on PlatformException catch (e) {
      if (e.code == 'not_installed') {
        return WhatsAppRegistration.notInstalled;
      }
      return WhatsAppRegistration.failed;
    } catch (_) {
      return WhatsAppRegistration.failed;
    }
  }

  /// Starts a WhatsApp voice call on Android (including unsaved numbers).
  ///
  /// Checks registration first when possible. Falls back to chat when a direct
  /// call intent cannot be started. Not supported on iOS.
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
        case 'opened_dialer':
          return WhatsAppLaunchResult.openedDialer;
        case 'fallback_chat':
          return WhatsAppLaunchResult.openedChatFallback;
        case 'not_on_whatsapp':
          return WhatsAppLaunchResult.notOnWhatsApp;
        case 'not_installed':
          return WhatsAppLaunchResult.notInstalled;
        default:
          return WhatsAppLaunchResult.failed;
      }
    } on PlatformException catch (e) {
      if (e.code == 'not_installed') {
        return WhatsAppLaunchResult.notInstalled;
      }
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
      WhatsAppLaunchResult.notOnWhatsApp =>
        'This number is not on WhatsApp.',
      WhatsAppLaunchResult.unsupported =>
        'WhatsApp call is not available on this device.',
      WhatsAppLaunchResult.failed => 'Unable to open WhatsApp',
      WhatsAppLaunchResult.openedDialer =>
        'WhatsApp dialer opened — tap Call to start the voice call.',
      WhatsAppLaunchResult.openedChatFallback =>
        'Opened chat. Tap the phone icon in WhatsApp to start the call.',
      WhatsAppLaunchResult.success => null,
    };
  }
}

final whatsAppServiceProvider = Provider<WhatsAppService>((ref) {
  return WhatsAppService();
});
