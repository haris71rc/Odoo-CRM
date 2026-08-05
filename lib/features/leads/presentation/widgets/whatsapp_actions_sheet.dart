import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:odoocrm/core/services/whatsapp_service.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/core/utils/phone_number_utils.dart';
import 'package:odoocrm/core/widgets/whatsapp_icon.dart';

/// Shows the WhatsApp quick-actions sheet for [phone].
Future<void> showWhatsAppActionsSheet({
  required BuildContext context,
  required String? phone,
  required WhatsAppService service,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => WhatsAppActionsSheet(
      phone: phone,
      service: service,
    ),
  );
}

/// Small bottom sheet: WhatsApp Call (Android) + WhatsApp Message.
class WhatsAppActionsSheet extends StatelessWidget {
  const WhatsAppActionsSheet({
    super.key,
    required this.phone,
    required this.service,
  });

  final String? phone;
  final WhatsAppService service;

  bool get _hasPhone => PhoneNumberUtils.isValid(phone);

  bool get _showCall => !kIsWeb && Platform.isAndroid;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Contact via WhatsApp',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_showCall)
              _WhatsAppActionTile(
                label: 'WhatsApp Call',
                enabled: _hasPhone,
                onTap: () {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.of(context).pop();
                  // Fire after the sheet closes so we don't fight its animation.
                  Future<void>.delayed(const Duration(milliseconds: 180), () async {
                    final result = await service.startCall(phone ?? '');
                    final message = service.messageFor(result);
                    if (message == null) return;
                    messenger.showSnackBar(SnackBar(content: Text(message)));
                  });
                },
              ),
            _WhatsAppActionTile(
              label: 'WhatsApp Message',
              enabled: _hasPhone,
              onTap: () {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.of(context).pop();
                Future<void>.delayed(const Duration(milliseconds: 180), () async {
                  final result = await service.openChat(phone ?? '');
                  final message = service.messageFor(result);
                  if (message == null) return;
                  messenger.showSnackBar(SnackBar(content: Text(message)));
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WhatsAppActionTile extends StatelessWidget {
  const _WhatsAppActionTile({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = enabled ? AppTheme.textPrimary : AppTheme.textMuted;

    return ListTile(
      enabled: enabled,
      onTap: enabled ? onTap : null,
      leading: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: const WhatsAppIcon(size: 40),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
