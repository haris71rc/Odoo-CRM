import 'package:flutter/material.dart';
import 'package:odoocrm/core/utils/date_formatters.dart';
import 'package:odoocrm/core/widgets/empty_view.dart';
import 'package:odoocrm/core/widgets/error_view.dart';
import 'package:odoocrm/core/widgets/loading_view.dart';
import 'package:odoocrm/features/activities/domain/entities/activity_entity.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/error/failures.dart';
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
                message: 'No activities yet',
                icon: Icons.event_note_outlined,
              );
            }
            return Column(
              children: activities
                  .map((activity) => _ActivityTile(activity: activity))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final ActivityEntity activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.event_available_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(activity.summary),
        subtitle: Text(
          [
            if (activity.activityType != null) activity.activityType!,
            if (activity.dateDeadline != null)
              DateFormatters.formatDate(activity.dateDeadline),
            if (activity.userName != null) activity.userName!,
          ].join(' • '),
        ),
      ),
    );
  }
}
