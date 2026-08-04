import 'package:flutter/material.dart';
import 'package:odoocrm/core/theme/app_theme.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  static const _phase2 = [
    'Daily calls',
    'Answered vs DNP',
    'Avg duration',
    'Inbound / Outbound',
    'Productivity',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Text(
                'Analytics',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.02,
                ),
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(34, 0, 34, 90),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        size: 28,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'COMING IN PHASE 2',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.16,
                        color: AppTheme.gold,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Telecaller performance dashboard',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.02,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Daily calls, answered vs. DNP, average call duration, inbound / outbound split and productivity graphs.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppTheme.textBody,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final label in _phase2)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.scaffold,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
