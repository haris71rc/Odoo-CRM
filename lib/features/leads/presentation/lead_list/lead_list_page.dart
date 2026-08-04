import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/core/utils/initials.dart';
import 'package:odoocrm/core/widgets/empty_view.dart';
import 'package:odoocrm/core/widgets/error_view.dart';
import 'package:odoocrm/core/widgets/loading_view.dart';
import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_entity.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';
import 'package:odoocrm/features/leads/presentation/utils/lead_list_filters.dart';
import 'package:odoocrm/features/leads/presentation/widgets/lead_card.dart';
import 'package:odoocrm/features/leads/presentation/widgets/lead_filter_sheet.dart';
import 'package:odoocrm/features/leads/presentation/widgets/lead_search_sheet.dart';
import 'package:odoocrm/features/stages/domain/entities/stage_entity.dart';
import 'package:odoocrm/features/stages/presentation/providers/stage_notifier.dart';

class LeadListPage extends HookConsumerWidget {
  const LeadListPage({super.key});

  static const _targetGoal = 100;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(leadNotifierProvider);
    final filter = ref.watch(leadFilterNotifierProvider);
    final currentUser = ref.watch(authNotifierProvider).valueOrNull;
    final stagesAsync = ref.watch(stageNotifierProvider);

    Future<void> markStage(LeadEntity lead, {required bool won}) async {
      final stages = stagesAsync.valueOrNull ?? const <StageEntity>[];
      StageEntity? target;
      for (final s in stages) {
        if (won && (s.isWon == true || LeadListFilters.isWon(s.name))) {
          target = s;
          break;
        }
        if (!won && LeadListFilters.isLost(s.name)) {
          target = s;
          break;
        }
      }
      if (target == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(won ? 'Won stage not found' : 'Lost stage not found'),
          ),
        );
        return;
      }
      final error = await ref.read(leadNotifierProvider.notifier).updateStage(
            leadId: lead.id,
            stageId: target.id,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? (won ? 'Marked as Won' : 'Marked as Lost'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Inside Sales · Pipeline',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textBody,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11.5,
                                  ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Leads',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.02,
                                    fontSize: 21,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => context.push('/profile'),
                        borderRadius: BorderRadius.circular(21),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: AppTheme.navyTint,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initialsOf(currentUser?.name),
                            style: const TextStyle(
                              color: AppTheme.navy,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DailyTarget(
                    done: leadsAsync.maybeWhen(
                      data: (leads) => leads
                          .where(
                            (l) =>
                                currentUser != null &&
                                l.assignedUser?.id == currentUser.id &&
                                LeadListFilters.isCreatedToday(l),
                          )
                          .length,
                      orElse: () => 0,
                    ),
                    goal: _targetGoal,
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => showLeadSearchSheet(context: context),
                    borderRadius: BorderRadius.circular(11),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            size: 18,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              filter.searchQuery.isEmpty
                                  ? 'Search name, phone or email'
                                  : filter.searchQuery,
                              style: TextStyle(
                                fontSize: 14,
                                color: filter.searchQuery.isEmpty
                                    ? AppTheme.textMuted
                                    : AppTheme.textPrimary,
                                fontWeight: filter.searchQuery.isEmpty
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (filter.searchQuery.isNotEmpty)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () => ref
                                  .read(leadFilterNotifierProvider.notifier)
                                  .setSearch(''),
                              icon: const Icon(Icons.close, size: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 11),
                  _FilterChipsRow(filter: filter),
                  const SizedBox(height: 12),
                  _PipelineTabs(
                    filter: filter,
                    leads: leadsAsync.valueOrNull ?? const [],
                    currentUserId: currentUser?.id,
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                child: leadsAsync.when(
                  skipLoadingOnReload: true,
                  skipLoadingOnRefresh: true,
                  loading: () => const LoadingView(
                    key: ValueKey('loading'),
                    message: 'Loading leads...',
                  ),
                  error: (error, _) => ErrorView(
                    key: const ValueKey('error'),
                    message:
                        error is Failure ? error.message : error.toString(),
                    onRetry: () =>
                        ref.read(leadNotifierProvider.notifier).refresh(),
                  ),
                  data: (leads) {
                    final filtered = LeadListFilters.apply(
                      leads: leads,
                      filter: filter,
                      currentUserId: currentUser?.id,
                    );
                    if (filtered.isEmpty) {
                      return EmptyView(
                        key: ValueKey(
                          'empty-${filter.pipelineTab.name}-'
                          '${filter.localFilterCount}-'
                          '${filter.searchQuery}',
                        ),
                        message: 'No leads match this filter',
                        icon: Icons.filter_alt_outlined,
                      );
                    }

                    return RefreshIndicator(
                      key: ValueKey(
                        'list-${filter.pipelineTab.name}-${filtered.length}',
                      ),
                      color: AppTheme.navy,
                      onRefresh: () =>
                          ref.read(leadNotifierProvider.notifier).refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 96),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final lead = filtered[index];
                          return LeadCard(
                            lead: lead,
                            isWon: LeadListFilters.isWon(lead.stage?.name),
                            isLost: LeadListFilters.isLost(lead.stage?.name),
                            hasFollowUp: LeadListFilters.isFollowUp(
                              lead.stage?.name,
                            ),
                            onTap: () => context.push('/leads/${lead.id}'),
                            onWon: () => markStage(lead, won: true),
                            onLost: () => markStage(lead, won: false),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyTarget extends StatelessWidget {
  const _DailyTarget({required this.done, required this.goal});

  final int done;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final progress = (done / goal).clamp(0.0, 1.0);
    final remaining = (goal - done).clamp(0, goal);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppTheme.elevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "TODAY'S TARGET",
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 0.1,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$done / $goal leads',
                style: AppTheme.mono(
                  fontSize: 12.5,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: AppTheme.border,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 7),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              remaining == 0
                  ? 'Daily target complete'
                  : '$remaining more to hit today’s target',
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.textBody,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipsRow extends ConsumerWidget {
  const _FilterChipsRow({required this.filter});

  final LeadFilterState filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(leadFilterNotifierProvider.notifier);
    final chips = [
      ('todayMine', 'Assigned today', filter.todayMine),
      ('untouched', 'Untouched', filter.untouched),
      // ('priority', 'High priority', filter.priorityOnly),
      ('open', 'Open', filter.openOnly),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _ChipButton(
            active: filter.localFilterCount > 0,
            onTap: () => showLeadFilterSheet(context: context),
            child: Row(
              children: [
                const Icon(Icons.tune, size: 14),
                const SizedBox(width: 6),
                const Text('Filters'),
                if (filter.localFilterCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${filter.localFilterCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          for (final chip in chips) ...[
            _ChipButton(
              active: chip.$3,
              onTap: () => notifier.toggleLocalFilter(chip.$1),
              child: Text(chip.$2),
            ),
            const SizedBox(width: 8),
          ],
          if (filter.dateFilter != null) ...[
            _ChipButton(
              active: true,
              onTap: notifier.clearDateFilter,
              child: Row(
                children: [
                  Text(filter.dateFilterLabel ?? 'Date'),
                  const SizedBox(width: 4),
                  const Icon(Icons.close, size: 14),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (filter.assignedUserName != null) ...[
            _ChipButton(
              active: true,
              onTap: notifier.clearAssignedUser,
              child: Row(
                children: [
                  Text(filter.assignedUserName!),
                  const SizedBox(width: 4),
                  const Icon(Icons.close, size: 14),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (filter.stageName != null) ...[
            _ChipButton(
              active: true,
              onTap: notifier.clearStage,
              child: Row(
                children: [
                  Text(filter.stageName!),
                  const SizedBox(width: 4),
                  const Icon(Icons.close, size: 14),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (filter.localFilterCount > 0)
            _ChipButton(
              active: false,
              onTap: notifier.clearLocalFilters,
              child: const Text('Clear'),
            ),
        ],
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.active,
    required this.onTap,
    required this.child,
  });

  final bool active;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppTheme.navyTint : AppTheme.surface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: active ? AppTheme.navy : AppTheme.borderStrong,
          ),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: active ? AppTheme.navy : AppTheme.textSecondary,
          ),
          child: IconTheme(
            data: IconThemeData(
              color: active ? AppTheme.navy : AppTheme.textSecondary,
              size: 14,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _PipelineTabs extends ConsumerWidget {
  const _PipelineTabs({
    required this.filter,
    required this.leads,
    required this.currentUserId,
  });

  final LeadFilterState filter;
  final List<LeadEntity> leads;
  final int? currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int countFor(LeadPipelineTab tab) {
      return LeadListFilters.apply(
        leads: leads,
        filter: filter,
        currentUserId: currentUserId,
        pipelineOverride: tab,
      ).length;
    }

    const tabs = [
      (LeadPipelineTab.all, 'All Leads'),
      (LeadPipelineTab.mine, 'Assigned to Me'),
      (LeadPipelineTab.followup, 'Follow-up'),
      (LeadPipelineTab.won, 'Won'),
      (LeadPipelineTab.lost, 'Lost'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in tabs)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: InkWell(
                onTap: () => ref
                    .read(leadFilterNotifierProvider.notifier)
                    .setPipelineTab(tab.$1),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 11),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 2.5,
                        color: filter.pipelineTab == tab.$1
                            ? AppTheme.navy
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: tab.$2,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: filter.pipelineTab == tab.$1
                            ? AppTheme.textPrimary
                            : AppTheme.textMuted,
                      ),
                      children: [
                        TextSpan(
                          text: ' ${countFor(tab.$1)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: (filter.pipelineTab == tab.$1
                                    ? AppTheme.textPrimary
                                    : AppTheme.textMuted)
                                .withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
