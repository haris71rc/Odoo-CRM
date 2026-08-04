import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/error/failures.dart';
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
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent Activities',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
                message: 'No Activities Scheduled',
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
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.event_available_outlined,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.summary,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (activity.activityType != null)
                        Text(
                          'Type: ${activity.activityType}',
                          style: theme.textTheme.bodySmall,
                        ),
                      if (activity.dateDeadline != null)
                        Text(
                          'Due: ${DateFormatters.formatDate(activity.dateDeadline)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      if (activity.userName != null)
                        Text(
                          'Assigned: ${activity.userName}',
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onMarkDone,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Mark Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
