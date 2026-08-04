import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/core/theme/stage_colors.dart';
import 'package:odoocrm/core/utils/date_formatters.dart';
import 'package:odoocrm/core/utils/html_text_utils.dart';
import 'package:odoocrm/core/widgets/app_card.dart';
import 'package:odoocrm/core/widgets/error_view.dart';
import 'package:odoocrm/core/widgets/html_content.dart';
import 'package:odoocrm/core/widgets/loading_view.dart';
import 'package:odoocrm/core/widgets/section_header.dart';
import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';
import 'package:odoocrm/features/chatter/presentation/providers/chatter_notifier.dart';
import 'package:odoocrm/features/chatter/presentation/widgets/timeline_section.dart';
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
      try {
        final available = await ref.read(stageNotifierProvider.future);
        if (!context.mounted) return;

        if (available.isEmpty) {
          await showMessage('No stages available');
          return;
        }

        // Keep the bottom-sheet order aligned with Odoo UX:
        // "Won" and "Lost" at the top, everything else after (by sequence).
        bool isWonStage(dynamic stage) {
          final name = (stage.name as String?)?.toLowerCase() ?? '';
          return stage.isWon == true ||
              name == 'won' ||
              name.contains('closed won');
        }

        bool isLostStage(dynamic stage) {
          final name = (stage.name as String?)?.toLowerCase() ?? '';
          return name == 'lost' || name.contains('closed lost') || name.endsWith('lost');
        }

        final sortedStages = [...available]
          ..sort((a, b) {
            final pa = isWonStage(a) ? 0 : (isLostStage(a) ? 1 : 2);
            final pb = isWonStage(b) ? 0 : (isLostStage(b) ? 1 : 2);
            if (pa != pb) return pa.compareTo(pb);

            // Preserve existing Odoo ordering for non-terminal stages.
            final sa = a.sequence ?? 1 << 30;
            final sb = b.sequence ?? 1 << 30;
            final seq = sa.compareTo(sb);
            if (seq != 0) return seq;

            return a.name.compareTo(b.name);
          });

        final selected = await showModalBottomSheet<int>(
          context: context,
          showDragHandle: false,
          builder: (context) {
            final theme = Theme.of(context);
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 4, 4),
                    child: SizedBox(
                      height: 48,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            'Update Stage',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              tooltip: 'Close',
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: sortedStages.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final stage = sortedStages[index];
                        return ListTile(
                          title: Text(stage.name),
                          onTap: () => Navigator.pop(context, stage.id),
                        );
                      },
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
      } catch (e) {
        isActing.value = false;
        final message = e is Failure ? e.message : e.toString();
        await showMessage(message);
      }
    }

    Future<void> updateRemark(LeadDetailEntity lead) async {
      final controller = TextEditingController(
        text: HtmlTextUtils.toPlainText(lead.description),
      );
      final saved = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Update Remark'),
            content: SizedBox(
              width: double.maxFinite,
              child: TextField(
                controller: controller,
                maxLines: 8,
                minLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Enter description / remark',
                  alignLabelWithHint: true,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  HtmlTextUtils.toHtml(controller.text),
                ),
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
                        .read(chatterNotifierProvider(leadId).notifier)
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
                        child: HtmlContent(html: lead.description),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppCard(
                              accentColor: AppTheme.primary,
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
                              accentColor: AppTheme.secondary,
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
                      const SizedBox(height: 8),
                      const Divider(),
                      TimelineSection(leadId: leadId),
                    ],
                  ),
                ),
              ),
              _StickyBottomBar(
                isLoading: isActing.value,
                showAssign: lead.assignedUser?.id != currentUser?.id,
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
    final stageName = lead.stage?.name;
    final stageColor = StageColors.forName(stageName);

    return AppCard(
      accentColor: stageColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lead.partnerName?.isNotEmpty == true
                ? lead.partnerName!
                : lead.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          if (lead.partnerName != null && lead.partnerName != lead.name) ...[
            const SizedBox(height: 4),
            Text(
              lead.name,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textMuted,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
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
              if (stageName != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: StageColors.backgroundFor(stageName),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: stageColor.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flag_outlined, size: 14, color: stageColor),
                      const SizedBox(width: 6),
                      Text(
                        stageName,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: stageColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Assigned: ${lead.assignedUser?.name ?? 'Unassigned'}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Created: ${DateFormatters.formatDateTime(lead.createdDate)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textMuted,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.elevated,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.secondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textPrimary,
                ),
          ),
        ],
      ),
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
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
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
    required this.showAssign,
  });

  final VoidCallback onCall;
  final VoidCallback onAssign;
  final bool isLoading;
  final bool showAssign;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
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
                if (showAssign) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: isLoading ? null : onAssign,
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF042F2E),
                              ),
                            )
                          : const Icon(Icons.person_add_alt_1_outlined),
                      label: const Text('Assign To Me'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
