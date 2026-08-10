import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/presentation/providers/call_log_providers.dart';

class LastCallCard extends ConsumerWidget {
  const LastCallCard({super.key, required this.leadId});

  final int leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callLogAsync = ref.watch(leadCallLogProvider(leadId));

    return callLogAsync.when(
      loading: () => const _CallLogShell(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => const _CallLogShell(
        child: Text(
          'Unable to load call information.',
          style: TextStyle(color: AppTheme.textBody, fontSize: 13.5),
        ),
      ),
      data: (callLog) => _CallLogShell(
        child: callLog.hasAnyCallData
            ? _CallDetails(callLog: callLog)
            : const Text(
                'No call has been made yet.',
                style: TextStyle(
                  color: AppTheme.textBody,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}

class _CallLogShell extends StatelessWidget {
  const _CallLogShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CALL LOG',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 0.12,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _CallDetails extends StatelessWidget {
  const _CallDetails({required this.callLog});

  final CallLog callLog;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('First call', _formatCallDate(callLog.firstCallDate)),
      ('Last call', _formatCallDate(callLog.lastCallDate)),
      ('Status', _formatStatus(callLog.status)),
      ('Total duration', callLog.totalDuration ?? callLog.duration ?? '—'),
      ('Inbound calls', _formatCount(callLog.totalInboundCalls)),
      ('Outbound calls', _formatCount(callLog.totalOutboundCalls)),
      ('Response time', _formatResponseTime(callLog.responseTimeMinutes)),
    ];

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 112,
                child: Text(
                  rows[i].$1,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textBody,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  rows[i].$2,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatCallDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
  }

  String _formatStatus(String? status) {
    if (status == null || status.isEmpty) return '—';
    return status.replaceAll('_', ' ');
  }

  String _formatCount(int? count) => count?.toString() ?? '0';

  String _formatResponseTime(double? minutes) {
    if (minutes == null) return '—';
    return '${minutes.toStringAsFixed(2)} min';
  }
}
