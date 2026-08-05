import 'package:flutter/material.dart';

/// WhatsApp brand green (#25D366).
const Color kWhatsAppGreen = Color(0xFF25D366);

/// Official WhatsApp logo asset used by the FAB and action sheet.
class WhatsAppIcon extends StatelessWidget {
  const WhatsAppIcon({
    super.key,
    this.size = 24,
    this.color,
  });

  static const String assetPath = 'assets/images/whatsapp.png';

  final double size;

  /// Optional tint; leave null to keep the brand colors from the asset.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (color == null) return image;

    return ColorFiltered(
      colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
      child: image,
    );
  }
}
