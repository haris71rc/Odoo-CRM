import 'package:flutter/material.dart';
import 'package:odoocrm/core/theme/app_theme.dart';

/// Stage accent colors for dark executive CRM cards / chips.
class StageColors {
  StageColors._();

  static Color forName(String? name) {
    final value = name?.toLowerCase().trim() ?? '';
    if (value.contains('won') || value == 'closed won') {
      return const Color(0xFF34D399);
    }
    if (value.contains('lost') || value == 'closed lost') {
      return const Color(0xFFF87171);
    }
    if (value.contains('negotiat')) {
      return const Color(0xFFFBBF24);
    }
    if (value.contains('proposal') || value.contains('qualif')) {
      return AppTheme.secondary;
    }
    if (value.contains('follow')) {
      return const Color(0xFFA78BFA);
    }
    if (value.contains('connect')) {
      return AppTheme.primary;
    }
    return AppTheme.textMuted;
  }

  static Color backgroundFor(String? name) {
    return forName(name).withValues(alpha: 0.16);
  }
}
