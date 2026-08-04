import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:odoocrm/core/error/failures.dart';
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
        title: const Text('CRM Leads'),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              children: [
                SegmentedButton<LeadSegment>(
                  segments: const [
                    ButtonSegment(
                      value: LeadSegment.all,
                      label: Text('All'),
                      icon: Icon(Icons.list_alt_rounded),
                    ),
                    ButtonSegment(
                      value: LeadSegment.assignedToMe,
                      label: Text('Assigned To Me'),
                      icon: Icon(Icons.person_outline),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: IconButton.filledTonal(
                        tooltip: 'Filter leads',
                        onPressed: openFilter,
                        icon: const Icon(Icons.filter_list_rounded),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: leadsAsync.when(
              loading: () => const LoadingView(message: 'Loading leads...'),
              error: (error, _) => ErrorView(
                message: error is Failure ? error.message : error.toString(),
                onRetry: () =>
                    ref.read(leadNotifierProvider.notifier).refresh(),
              ),
              data: (leads) {
                final filtered = applyLocalFilters(leads);
                if (filtered.isEmpty) {
                  return const EmptyView(
                    message: 'No leads match your filters',
                    icon: Icons.handshake_outlined,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(leadNotifierProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final lead = filtered[index];
                      return LeadCard(
                        lead: lead,
                        onTap: () => context.push('/leads/${lead.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
