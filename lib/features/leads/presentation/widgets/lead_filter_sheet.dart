import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
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
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
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
  late bool _todayMine;
  late bool _untouched;
  late bool _priorityOnly;
  late bool _openOnly;

  final _dateFormat = DateFormat('dd/MM');

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
    _todayMine = current.todayMine;
    _untouched = current.untouched;
    _priorityOnly = current.priorityOnly;
    _openOnly = current.openOnly;
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

  String _rangeLabel(LeadDateFilter? filter) {
    final now = DateTime.now();
    switch (filter) {
      case LeadDateFilter.today:
        return _dateFormat.format(now);
      case LeadDateFilter.thisWeek:
        final start = now.subtract(Duration(days: now.weekday - 1));
        return '${_dateFormat.format(start)} – ${_dateFormat.format(now)}';
      case LeadDateFilter.thisMonth:
        return '${_dateFormat.format(DateTime(now.year, now.month, 1))} – ${_dateFormat.format(DateTime(now.year, now.month + 1, 0))}';
      case LeadDateFilter.thisQuarter:
        return 'Quarter';
      case LeadDateFilter.thisYear:
        return '${now.year}';
      case LeadDateFilter.custom:
        if (_customStart != null && _customEnd != null) {
          return '${_dateFormat.format(_customStart!)} – ${_dateFormat.format(_customEnd!)}';
        }
        return 'Pick range';
      case null:
        return '—';
    }
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
          todayMine: _todayMine,
          untouched: _untouched,
          priorityOnly: _priorityOnly,
          openOnly: _openOnly,
        );
    Navigator.of(context).pop();
  }

  void _reset() {
    ref.read(leadFilterNotifierProvider.notifier).resetFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final leadsCount =
        ref.watch(leadNotifierProvider).valueOrNull?.length ?? 0;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final filterDefs = [
      (
        'todayMine',
        'Assigned to me today',
        'Auto-assigned leads created today',
        _todayMine,
        () => setState(() => _todayMine = !_todayMine),
      ),
      (
        'untouched',
        'Untouched leads',
        'Salesperson not set',
        _untouched,
        () => setState(() => _untouched = !_untouched),
      ),
      (
        'priority',
        'High priority',
        'Starred opportunities',
        _priorityOnly,
        () => setState(() => _priorityOnly = !_priorityOnly),
      ),
      (
        'open',
        'Open opportunities',
        'Excludes Won and Lost',
        _openOnly,
        () => setState(() => _openOnly = !_openOnly),
      ),
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: maxHeight,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 34,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D5DD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 10),
              child: Row(
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Spacer(),
                  Text(
                    'Odoo domain filters',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 6, 20, 4),
                    child: Text(
                      'FILTERS',
                      style: TextStyle(
                        fontSize: 10.5,
                        letterSpacing: 0.12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  for (final f in filterDefs)
                    _SheetRow(
                      active: f.$4,
                      onTap: f.$5,
                      title: f.$2,
                      subtitle: f.$3,
                      trailing: _CheckBox(active: f.$4),
                    ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Text(
                      'CREATE DATE',
                      style: TextStyle(
                        fontSize: 10.5,
                        letterSpacing: 0.12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _SheetRow(
                    active: _dateFilter == null,
                    onTap: () => setState(() {
                      _dateFilter = null;
                      _customStart = null;
                      _customEnd = null;
                    }),
                    title: 'All time',
                    trailing: Text(
                      '—',
                      style: AppTheme.mono(
                        fontSize: 11.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                  for (final opt in LeadDateFilter.values)
                    _SheetRow(
                      active: _dateFilter == opt,
                      onTap: () async {
                        if (opt == LeadDateFilter.custom) {
                          setState(() => _dateFilter = opt);
                          await _pickCustomRange();
                          return;
                        }
                        setState(() {
                          _dateFilter = opt;
                          _customStart = null;
                          _customEnd = null;
                        });
                      },
                      title: opt.label,
                      trailing: Text(
                        _rangeLabel(opt),
                        style: AppTheme.mono(
                          fontSize: 11.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  _AssigneeStageSection(
                    userId: _userId,
                    stageId: _stageId,
                    onUserChanged: (id, name) => setState(() {
                      _userId = id;
                      _userName = name;
                    }),
                    onStageChanged: (id, name) => setState(() {
                      _stageId = id;
                      _stageName = name;
                    }),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 14,
                    child: FilledButton(
                      onPressed: _apply,
                      child: Text('Show $leadsCount leads'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssigneeStageSection extends ConsumerWidget {
  const _AssigneeStageSection({
    required this.userId,
    required this.stageId,
    required this.onUserChanged,
    required this.onStageChanged,
  });

  final int? userId;
  final int? stageId;
  final void Function(int? id, String? name) onUserChanged;
  final void Function(int? id, String? name) onStageChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersNotifierProvider);
    final stagesAsync = ref.watch(stageNotifierProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'ASSIGNED TO',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 0.12,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          usersAsync.when(
            loading: () => const LinearProgressIndicator(minHeight: 2),
            error: (_, _) => const Text('Unable to load users'),
            data: (users) {
              return DropdownButtonFormField<int?>(
                initialValue: users.any((u) => u.id == userId) ? userId : null,
                isExpanded: true,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Users')),
                  ...users.map(
                    (u) => DropdownMenuItem(value: u.id, child: Text(u.name)),
                  ),
                ],
                onChanged: (value) {
                  final name = value == null
                      ? null
                      : users.where((u) => u.id == value).firstOrNull?.name;
                  onUserChanged(value, name);
                },
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'STAGE',
            style: TextStyle(
              fontSize: 10.5,
              letterSpacing: 0.12,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          stagesAsync.when(
            loading: () => const LinearProgressIndicator(minHeight: 2),
            error: (_, _) => const Text('Unable to load stages'),
            data: (stages) {
              return DropdownButtonFormField<int?>(
                initialValue:
                    stages.any((s) => s.id == stageId) ? stageId : null,
                isExpanded: true,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Stages')),
                  ...stages.map(
                    (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                  ),
                ],
                onChanged: (value) {
                  final name = value == null
                      ? null
                      : stages.where((s) => s.id == value).firstOrNull?.name;
                  onStageChanged(value, name);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.active,
    required this.onTap,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  final bool active;
  final VoidCallback onTap;
  final String title;
  final String? subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: active ? const Color(0xFFF4F7FB) : AppTheme.surface,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppTheme.navy : AppTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: active ? AppTheme.navy : AppTheme.borderStrong,
          width: 1.5,
        ),
      ),
      child: active
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
