import 'package:flutter/material.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';

Future<CallLog?> showCallOutcomeSheet({
  required BuildContext context,
  required DateTime dialedAt,
  required List<CallStatusOption> statusOptions,
}) {
  final options = statusOptions.isNotEmpty ? statusOptions : _fallbackOptions;

  return showModalBottomSheet<CallLog>(
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
                'Duration, time and status are read from the Android call log when available.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textBody,
                ),
              ),
              const SizedBox(height: 12),
              for (final option in options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    option.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                      CallLog(
                        lastCallDate: dialedAt,
                        status: option.key,
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

const _fallbackOptions = [
  CallStatusOption(key: 'picked', label: 'Picked'),
  CallStatusOption(key: 'dnp', label: 'DNP'),
  CallStatusOption(key: 'busy', label: 'Busy'),
  CallStatusOption(key: 'hanged_up', label: 'Hanged Up'),
  CallStatusOption(key: 'missed', label: 'Missed'),
  CallStatusOption(key: 'call_failed', label: 'Call Failed'),
];

Future<void> showCallValidationDialog(
  BuildContext context,
  String message,
) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Stage change blocked'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
