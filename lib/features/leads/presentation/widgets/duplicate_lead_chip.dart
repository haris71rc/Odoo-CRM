import 'package:flutter/material.dart';
import 'package:odoocrm/core/theme/app_theme.dart';

/// Chip shown when another lead with the same number was already called.
class DuplicateLeadChip extends StatelessWidget {
  const DuplicateLeadChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.duplicateBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.duplicateBorder),
      ),
      child: const Text(
        'DUPLICATE',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: AppTheme.duplicateFg,
          letterSpacing: 0.02,
        ),
      ),
    );
  }
}
