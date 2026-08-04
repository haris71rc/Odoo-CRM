import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_date_filter.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';
import 'package:odoocrm/features/stages/presentation/providers/stage_notifier.dart';
import 'package:odoocrm/features/users/presentation/providers/users_notifier.dart';

Future<void> showLeadFilterSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const LeadFilterSheet(),
  );
}

class LeadFilterSheet extends ConsumerStatefulWidget {
  const LeadFilterSheet({super.key});

  @override
  ConsumerState<LeadFilterSheet> createState() => _LeadFilterSheetState();
}

class _LeadFilterSheetState extends ConsumerState<LeadFilterSheet> {
  late LeadDateFilter? _dateFilter;
  late DateTime? _customStart;
  late DateTime? _customEnd;
  late int? _userId;
  late String? _userName;
  late int? _stageId;
  late String? _stageName;

  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    final current = ref.read(leadFilterNotifierProvider);
    _dateFilter = current.dateFilter;
    _customStart = current.customStartDate;
    _customEnd = current.customEndDate;
    _userId = current.assignedUserId;
    _userName = current.assignedUserName;
    _stageId = current.stageId;
    _stageName = current.stageName;
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _customStart != null && _customEnd != null
          ? DateTimeRange(start: _customStart!, end: _customEnd!)
          : null,
    );
    if (range == null) return;
    setState(() {
      _customStart = range.start;
      _customEnd = range.end;
      _dateFilter = LeadDateFilter.custom;
    });
  }

  void _apply() {
    if (_dateFilter == LeadDateFilter.custom &&
        (_customStart == null || _customEnd == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a custom date range')),
      );
      return;
    }

    ref.read(leadFilterNotifierProvider.notifier).applyFilters(
          dateFilter: _dateFilter,
          customStartDate: _dateFilter == LeadDateFilter.custom
              ? _customStart
              : null,
          customEndDate:
              _dateFilter == LeadDateFilter.custom ? _customEnd : null,
          assignedUserId: _userId,
          assignedUserName: _userName,
          stageId: _stageId,
          stageName: _stageName,
        );
    Navigator.of(context).pop();
  }

  void _reset() {
    ref.read(leadFilterNotifierProvider.notifier).resetFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usersAsync = ref.watch(usersNotifierProvider);
    final stagesAsync = ref.watch(stageNotifierProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filter Leads',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FilterSectionCard(
                        title: 'Date',
                        child: Column(
                          children: [
                            RadioGroup<LeadDateFilter>(
                              groupValue: _dateFilter,
                              onChanged: (value) async {
                                if (value == null) return;
                                if (value == LeadDateFilter.custom) {
                                  setState(() => _dateFilter = value);
                                  await _pickCustomRange();
                                  return;
                                }
                                setState(() {
                                  _dateFilter = value;
                                  _customStart = null;
                                  _customEnd = null;
                                });
                              },
                              child: Column(
                                children: [
                                  for (final option in LeadDateFilter.values)
                                    RadioListTile<LeadDateFilter>(
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      value: option,
                                      title: Text(option.label),
                                    ),
                                ],
                              ),
                            ),
                            if (_dateFilter == LeadDateFilter.custom) ...[
                              const SizedBox(height: 4),
                              OutlinedButton.icon(
                                onPressed: _pickCustomRange,
                                icon: const Icon(Icons.date_range_rounded),
                                label: Text(
                                  _customStart != null && _customEnd != null
                                      ? '${_dateFormat.format(_customStart!)} – ${_dateFormat.format(_customEnd!)}'
                                      : 'Select date range',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _FilterSectionCard(
                        title: 'Assigned To',
                        child: usersAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          error: (error, _) => Text(
                            'Unable to load users',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          data: (users) {
                            final selectedUserId = users.any((u) => u.id == _userId)
                                ? _userId
                                : null;
                            return DropdownButtonFormField<int?>(
                              key: ValueKey('user-$selectedUserId'),
                              initialValue: selectedUserId,
                              isExpanded: true,
                              menuMaxHeight: 280,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('All Users'),
                                ),
                                ...users.map(
                                  (user) => DropdownMenuItem<int?>(
                                    value: user.id,
                                    child: Text(
                                      user.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _userId = value;
                                  if (value == null) {
                                    _userName = null;
                                  } else {
                                    _userName = users
                                        .where((u) => u.id == value)
                                        .map((u) => u.name)
                                        .cast<String>()
                                        .firstOrNull;
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _FilterSectionCard(
                        title: 'Stage',
                        child: stagesAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          error: (error, _) => Text(
                            'Unable to load stages',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                          data: (stages) {
                            final selectedStageId =
                                stages.any((s) => s.id == _stageId)
                                    ? _stageId
                                    : null;
                            return DropdownButtonFormField<int?>(
                              key: ValueKey('stage-$selectedStageId'),
                              initialValue: selectedStageId,
                              isExpanded: true,
                              menuMaxHeight: 280,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('All Stages'),
                                ),
                                ...stages.map(
                                  (stage) => DropdownMenuItem<int?>(
                                    value: stage.id,
                                    child: Text(
                                      stage.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _stageId = value;
                                  if (value == null) {
                                    _stageName = null;
                                  } else {
                                    _stageName = stages
                                        .where((s) => s.id == value)
                                        .map((s) => s.name)
                                        .cast<String>()
                                        .firstOrNull;
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _reset,
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _apply,
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSectionCard extends StatelessWidget {
  const _FilterSectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
