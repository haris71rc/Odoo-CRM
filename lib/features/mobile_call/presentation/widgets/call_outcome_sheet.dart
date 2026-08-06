import 'package:flutter/material.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/features/mobile_call/domain/entities/latest_mobile_call_entity.dart';

/// Compact outcome picker used when the device call log is unavailable.
Future<LatestMobileCallEntity?> showCallOutcomeSheet({
  required BuildContext context,
  required String phone,
  required DateTime dialedAt,
}) {
  return showModalBottomSheet<LatestMobileCallEntity>(
    context: context,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 34,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D5DD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Call outcome',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select how the call ended so it can be saved to Odoo.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textBody,
                ),
              ),
              const SizedBox(height: 12),
              for (final option in _options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    option.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      LatestMobileCallEntity(
                        status: option.status,
                        duration: option.durationSeconds,
                        direction: 'outgoing',
                        phone: phone,
                        timestamp: dialedAt,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _OutcomeOption {
  const _OutcomeOption({
    required this.label,
    required this.status,
    required this.durationSeconds,
  });

  final String label;
  final String status;
  final int durationSeconds;
}

const _options = [
  _OutcomeOption(
    label: 'Answered',
    status: 'answered',
    durationSeconds: 60,
  ),
  _OutcomeOption(
    label: 'No answer',
    status: 'no_answer',
    durationSeconds: 0,
  ),
  _OutcomeOption(
    label: 'Busy',
    status: 'busy',
    durationSeconds: 0,
  ),
  _OutcomeOption(
    label: 'Missed',
    status: 'missed',
    durationSeconds: 0,
  ),
  _OutcomeOption(
    label: 'Rejected',
    status: 'rejected',
    durationSeconds: 0,
  ),
];
