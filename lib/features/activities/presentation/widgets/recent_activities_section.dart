import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/core/utils/date_formatters.dart';
import 'package:odoocrm/core/widgets/empty_view.dart';
import 'package:odoocrm/core/widgets/error_view.dart';
import 'package:odoocrm/core/widgets/loading_view.dart';
import 'package:odoocrm/features/activities/domain/entities/activity_entity.dart';
import 'package:odoocrm/features/activities/presentation/providers/activity_notifier.dart';

class RecentActivitiesSection extends ConsumerWidget {
  const RecentActivitiesSection({
    super.key,
    required this.leadId,
    required this.onAdd,
  });

  final int leadId;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activityNotifierProvider(leadId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 15),
          label: const Text('Schedule activity'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        ),
        const SizedBox(height: 10),
        activitiesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LoadingView(),
          ),
          error: (error, _) => ErrorView(
            message: error is Failure ? error.message : error.toString(),
            onRetry: () =>
                ref.read(activityNotifierProvider(leadId).notifier).refresh(),
          ),
          data: (activities) {
            if (activities.isEmpty) {
              return const EmptyView(
                message: 'No activities scheduled',
                icon: Icons.event_note_outlined,
              );
            }
            return Column(
              children: activities
                  .map(
                    (activity) => _ActivityTile(
                      activity: activity,
                      onMarkDone: () => _markDone(context, ref, activity),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Future<void> _markDone(
    BuildContext context,
    WidgetRef ref,
    ActivityEntity activity,
  ) async {
    final error = await ref
        .read(activityNotifierProvider(leadId).notifier)
        .completeActivity(activity.id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Activity marked as done'),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
    required this.onMarkDone,
  });

  final ActivityEntity activity;
  final VoidCallback onMarkDone;

  @override
  Widget build(BuildContext context) {
    final overdue = activity.dateDeadline != null &&
        activity.dateDeadline!.isBefore(DateTime.now()) &&
        activity.state != 'done';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.navyTint,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              () {
                final type = activity.activityType ?? 'T';
                return type.isEmpty ? 'T' : type[0].toUpperCase();
              }(),
              style: const TextStyle(
                color: AppTheme.navy,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        activity.activityType ?? 'Activity',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      activity.dateDeadline == null
                          ? '—'
                          : DateFormatters.formatDate(activity.dateDeadline),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: overdue
                            ? AppTheme.lostFg
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  activity.summary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF344054),
                    height: 1.55,
                  ),
                ),
                if (activity.userName != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Assigned to ${activity.userName}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onMarkDone,
                    child: const Text('Mark done'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
