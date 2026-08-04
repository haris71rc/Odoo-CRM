import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/core/widgets/empty_view.dart';
import 'package:odoocrm/core/widgets/error_view.dart';
import 'package:odoocrm/core/widgets/loading_view.dart';
import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_entity.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';
import 'package:odoocrm/features/leads/presentation/widgets/lead_card.dart';
import 'package:odoocrm/features/leads/presentation/widgets/lead_filter_sheet.dart';

enum LeadSegment { all, assignedToMe }

class LeadListPage extends HookConsumerWidget {
  const LeadListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(leadNotifierProvider);
    final filter = ref.watch(leadFilterNotifierProvider);
    final currentUser = ref.watch(authNotifierProvider).valueOrNull;
    final searchController = useTextEditingController(text: filter.searchQuery);
    final segment = useState(
      filter.assignedToMeOnly ? LeadSegment.assignedToMe : LeadSegment.all,
    );

    useEffect(() {
      void listener() {
        ref
            .read(leadFilterNotifierProvider.notifier)
            .setSearch(searchController.text);
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    Future<void> openFilter() async {
      await showLeadFilterSheet(context: context);
    }

    List<LeadEntity> applyLocalFilters(List<LeadEntity> leads) {
      var filtered = leads;

      if (segment.value == LeadSegment.assignedToMe && currentUser != null) {
        filtered = filtered
            .where((lead) => lead.assignedUser?.id == currentUser.id)
            .toList();
      }

      final query = filter.searchQuery.trim().toLowerCase();
      if (query.isNotEmpty) {
        filtered = filtered
            .where((lead) => lead.name.toLowerCase().contains(query))
            .toList();
      }

      return filtered;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(
              children: [
                SegmentedButton<LeadSegment>(
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    textStyle: WidgetStatePropertyAll(
                      Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                    ),
                  ),
                  segments: const [
                    ButtonSegment(
                      value: LeadSegment.all,
                      label: Text(
                        'All',
                        maxLines: 1,
                        softWrap: false,
                      ),
                      icon: Icon(Icons.list_alt_rounded, size: 18),
                    ),
                    ButtonSegment(
                      value: LeadSegment.assignedToMe,
                      label: Text(
                        'Assigned To Me',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                      icon: Icon(Icons.person_outline, size: 18),
                    ),
                  ],
                  selected: {segment.value},
                  onSelectionChanged: (selection) {
                    final value = selection.first;
                    segment.value = value;
                    ref
                        .read(leadFilterNotifierProvider.notifier)
                        .setAssignedToMe(value == LeadSegment.assignedToMe);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search by lead name',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Badge(
                      isLabelVisible: filter.hasActiveServerFilters,
                      backgroundColor: AppTheme.primary,
                      child: IconButton.filled(
                        tooltip: 'Filter leads',
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.elevated,
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.border),
                          fixedSize: const Size(52, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: openFilter,
                        icon: const Icon(Icons.tune_rounded),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: leadsAsync.when(
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
                  final filtered = applyLocalFilters(leads);
                  if (filtered.isEmpty) {
                    return const EmptyView(
                      key: ValueKey('empty'),
                      message: 'No leads match your filters',
                      icon: Icons.handshake_outlined,
                    );
                  }

                  return RefreshIndicator(
                    key: ValueKey('list-${filtered.length}'),
                    color: AppTheme.primary,
                    backgroundColor: AppTheme.elevated,
                    onRefresh: () =>
                        ref.read(leadNotifierProvider.notifier).refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final lead = filtered[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(
                            milliseconds: 220 + (index.clamp(0, 8) * 30),
                          ),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 10 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: LeadCard(
                            lead: lead,
                            onTap: () => context.push('/leads/${lead.id}'),
                          ),
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
    );
  }
}
