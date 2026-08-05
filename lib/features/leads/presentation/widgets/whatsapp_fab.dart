import 'package:flutter/material.dart';
import 'package:odoocrm/core/widgets/whatsapp_icon.dart';

/// Circular WhatsApp FAB using the official brand asset.
class WhatsAppFab extends StatelessWidget {
  const WhatsAppFab({
    super.key,
    required this.onPressed,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: kWhatsAppGreen.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onPressed : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: const WhatsAppIcon(size: 56),
        ),
      ),
    );
  }
}
