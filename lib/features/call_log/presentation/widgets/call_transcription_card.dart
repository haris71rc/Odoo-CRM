import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_transcription_state.dart';
import 'package:odoocrm/features/call_log/presentation/providers/call_transcription_notifier.dart';

class CallTranscriptionCard extends ConsumerWidget {
  const CallTranscriptionCard({super.key, required this.leadId});

  final int leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(callTranscriptionNotifierProvider(leadId));

    if (state.status == CallTranscriptionStatus.idle &&
        state.recordingName == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Call Recording',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (state.recordingName != null) ...[
            Text(
              'Recording:',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state.recordingName!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            'Status:',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            state.status == CallTranscriptionStatus.completed
                ? 'Completed'
                : state.statusLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: state.status == CallTranscriptionStatus.error
                  ? AppTheme.error
                  : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Transcript:',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            state.displayTranscript.isNotEmpty
                ? state.displayTranscript
                : (state.status == CallTranscriptionStatus.completed
                    ? 'No speech was detected in this recording.'
                    : state.isBusy
                        ? 'Waiting for speech...'
                        : '—'),
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: state.displayTranscript.isNotEmpty
                  ? AppTheme.textPrimary
                  : AppTheme.textSecondary,
            ),
          ),
          if (state.isBusy) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 3),
          ],
          if (state.status == CallTranscriptionStatus.error) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(callTranscriptionNotifierProvider(leadId).notifier)
                    .retry();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry transcription'),
            ),
          ],
        ],
      ),
    );
  }
}
