import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/utils/date_formatters.dart';
import 'package:odoocrm/core/widgets/app_card.dart';
import 'package:odoocrm/core/widgets/error_view.dart';
import 'package:odoocrm/core/widgets/loading_view.dart';
import 'package:odoocrm/core/widgets/section_header.dart';
import 'package:odoocrm/features/activities/presentation/providers/activity_notifier.dart';
import 'package:odoocrm/features/activities/presentation/widgets/recent_activities_section.dart';
import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_detail_entity.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_detail_notifier.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';
import 'package:odoocrm/features/stages/presentation/providers/stage_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadDetailPage extends HookConsumerWidget {
  const LeadDetailPage({super.key, required this.leadId});

  final int leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadAsync = ref.watch(leadDetailNotifierProvider(leadId));
    final currentUser = ref.watch(authNotifierProvider).valueOrNull;
    final isActing = useState(false);

    Future<void> showMessage(String message) async {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    Future<void> callCustomer(LeadDetailEntity lead) async {
      final number = lead.phone ?? lead.mobile;
      if (number == null || number.isEmpty) {
        await showMessage('No phone number available');
        return;
      }
      final uri = Uri(scheme: 'tel', path: number);
      final launched = await launchUrl(uri);
      if (!launched) {
        await showMessage('Unable to open dialer');
      }
    }

    Future<void> assignToMe() async {
      if (currentUser == null) {
        await showMessage('User session not found');
        return;
      }
      isActing.value = true;
      final error = await ref
          .read(leadDetailNotifierProvider(leadId).notifier)
          .assignToMe(currentUser.id);
      isActing.value = false;
      ref.invalidate(leadNotifierProvider);
      await showMessage(error ?? 'Lead assigned to you');
    }

    Future<void> updateStage() async {
      final stagesAsync = ref.read(stageNotifierProvider);
      final stages = stagesAsync.valueOrNull;
      if (stages == null || stages.isEmpty) {
        await ref.read(stageNotifierProvider.future);
      }
      final available = ref.read(stageNotifierProvider).valueOrNull ?? [];
      if (!context.mounted) return;

      final selected = await showModalBottomSheet<int>(
        context: context,
        builder: (context) {
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                const ListTile(title: Text('Update Stage')),
                ...available.map(
                  (stage) => ListTile(
                    title: Text(stage.name),
                    onTap: () => Navigator.pop(context, stage.id),
                  ),
                ),
              ],
            ),
          );
        },
      );

      if (selected == null) return;
      isActing.value = true;
      final error = await ref
          .read(leadDetailNotifierProvider(leadId).notifier)
          .updateStage(selected);
      isActing.value = false;
      ref.invalidate(leadNotifierProvider);
      await showMessage(error ?? 'Stage updated');
    }

    Future<void> updateRemark(LeadDetailEntity lead) async {
      final controller = TextEditingController(text: lead.description ?? '');
      final saved = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Update Remark'),
            content: TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter description / remark',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, controller.text),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );

      if (saved == null) return;
      isActing.value = true;
      final error = await ref
          .read(leadDetailNotifierProvider(leadId).notifier)
          .updateRemark(saved);
      isActing.value = false;
      await showMessage(error ?? 'Remark updated');
    }

    Future<void> addActivity() async {
      final summaryController = TextEditingController();
      final noteController = TextEditingController();

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Create Activity'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: summaryController,
                  decoration: const InputDecoration(labelText: 'Summary'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Create'),
              ),
            ],
          );
        },
      );

      if (confirmed != true || summaryController.text.trim().isEmpty) return;

      isActing.value = true;
      final error =
          await ref.read(activityNotifierProvider(leadId).notifier).createActivity(
                summary: summaryController.text.trim(),
                note: noteController.text.trim().isEmpty
                    ? null
                    : noteController.text.trim(),
                dateDeadline: DateTime.now().add(const Duration(days: 1)),
              );
      isActing.value = false;
      await showMessage(error ?? 'Activity created');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Update stage',
            onPressed: isActing.value ? null : updateStage,
            icon: const Icon(Icons.swap_horiz_rounded),
          ),
          IconButton(
            tooltip: 'Update remark',
            onPressed: leadAsync.valueOrNull == null || isActing.value
                ? null
                : () => updateRemark(leadAsync.valueOrNull!),
            icon: const Icon(Icons.edit_note_rounded),
          ),
        ],
      ),
      body: leadAsync.when(
        loading: () => const LoadingView(message: 'Loading lead...'),
        error: (error, _) => ErrorView(
          message: error is Failure ? error.message : error.toString(),
          onRetry: () =>
              ref.read(leadDetailNotifierProvider(leadId).notifier).refresh(),
        ),
        data: (lead) {
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ref
                        .read(leadDetailNotifierProvider(leadId).notifier)
                        .refresh();
                    await ref
                        .read(activityNotifierProvider(leadId).notifier)
                        .refresh();
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      _HeaderCard(lead: lead),
                      const Divider(),
                      const SectionHeader(title: 'Customer Address'),
                      const SizedBox(height: 8),
                      AppCard(
                        child: Text(
                          _formatAddress(lead),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SectionHeader(title: 'Description'),
                      const SizedBox(height: 8),
                      AppCard(
                        child: Text(
                          lead.description?.isNotEmpty == true
                              ? lead.description!
                              : 'No description',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppCard(
                              child: _Metric(
                                label: 'Revenue',
                                value: lead.expectedRevenue == null
                                    ? '—'
                                    : lead.expectedRevenue!
                                        .toStringAsFixed(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppCard(
                              child: _Metric(
                                label: 'Probability',
                                value: lead.probability == null
                                    ? '—'
                                    : '${lead.probability!.toStringAsFixed(0)}%',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      RecentActivitiesSection(
                        leadId: leadId,
                        onAdd: addActivity,
                      ),
                    ],
                  ),
                ),
              ),
              _StickyBottomBar(
                isLoading: isActing.value,
                onCall: () => callCustomer(lead),
                onAssign: assignToMe,
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatAddress(LeadDetailEntity lead) {
    final parts = [
      lead.street,
      lead.city,
      lead.state?.name,
      lead.zip,
      lead.country?.name,
    ].whereType<String>().where((e) => e.trim().isNotEmpty).toList();

    if (parts.isEmpty) return 'No address available';
    return parts.join(', ');
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.lead});

  final LeadDetailEntity lead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lead.partnerName?.isNotEmpty == true
                ? lead.partnerName!
                : lead.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (lead.partnerName != null && lead.partnerName != lead.name) ...[
            const SizedBox(height: 4),
            Text(
              lead.name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            children: [
              if (lead.phone != null || lead.mobile != null)
                _InfoChip(
                  icon: Icons.phone_outlined,
                  label: lead.phone ?? lead.mobile!,
                ),
              if (lead.email != null)
                _InfoChip(
                  icon: Icons.email_outlined,
                  label: lead.email!,
                ),
              if (lead.stage != null)
                Chip(
                  avatar: const Icon(Icons.flag_outlined, size: 16),
                  label: Text(lead.stage!.name),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Assigned: ${lead.assignedUser?.name ?? 'Unassigned'}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Created: ${DateFormatters.formatDateTime(lead.createdDate)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StickyBottomBar extends StatelessWidget {
  const _StickyBottomBar({
    required this.onCall,
    required this.onAssign,
    required this.isLoading,
  });

  final VoidCallback onCall;
  final VoidCallback onAssign;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onCall,
                  icon: const Icon(Icons.call_outlined),
                  label: const Text('Call Customer'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: isLoading ? null : onAssign,
                  icon: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text('Assign To Me'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
