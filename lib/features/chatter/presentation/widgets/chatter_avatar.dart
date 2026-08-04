import 'package:flutter/material.dart';

class ChatterAvatar extends StatelessWidget {
  const ChatterAvatar({
    super.key,
    required this.name,
    this.partnerId,
    this.size = 36,
  });

  final String name;
  final int? partnerId;
  final double size;

  static const _palette = [
    Color(0xFF6CC1ED),
    Color(0xFF30C381),
    Color(0xFFF7CD1F),
    Color(0xFFF4A460),
    Color(0xFF9365B8),
    Color(0xFF475577),
    Color(0xFF2C8397),
    Color(0xFFEB7E7F),
    Color(0xFF814968),
    Color(0xFFD6145F),
  ];

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty
        ? name.trim().substring(0, 1).toUpperCase()
        : '?';
    final colorIndex = (partnerId ?? name.hashCode).abs() % _palette.length;
    final background = _palette[colorIndex];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
