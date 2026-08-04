import 'package:flutter/material.dart';
import 'package:odoocrm/core/theme/app_theme.dart';

/// DigiLawyer stage chip colors (prototype palette + heuristics).
class StageColors {
  StageColors._();

  static Color forName(String? name) {
    final value = name?.toLowerCase().trim() ?? '';
    if (value.contains('won') || value == 'closed won') {
      return AppTheme.wonFg;
    }
    if (value.contains('lost') || value == 'closed lost') {
      return AppTheme.lostFg;
    }
    if (value.contains('proposition') ||
        value.contains('proposal') ||
        value.contains('negotiat')) {
      return const Color(0xFFB54708);
    }
    if (value.contains('qualif')) {
      return AppTheme.navy;
    }
    if (value.contains('new') || value.isEmpty) {
      return AppTheme.textBody;
    }
    if (value.contains('follow')) {
      return AppTheme.followUpFg;
    }
    if (value.contains('connect')) {
      return AppTheme.navy;
    }
    return AppTheme.textBody;
  }

  static Color backgroundFor(String? name) {
    final value = name?.toLowerCase().trim() ?? '';
    if (value.contains('won') || value == 'closed won') {
      return AppTheme.wonBg;
    }
    if (value.contains('lost') || value == 'closed lost') {
      return AppTheme.lostBg;
    }
    if (value.contains('proposition') ||
        value.contains('proposal') ||
        value.contains('negotiat')) {
      return const Color(0xFFFEF0C7);
    }
    if (value.contains('qualif')) {
      return AppTheme.navyTint;
    }
    if (value.contains('new') || value.isEmpty) {
      return const Color(0xFFF2F4F7);
    }
    if (value.contains('follow')) {
      return AppTheme.followUpBg;
    }
    return const Color(0xFFF2F4F7);
  }
}
