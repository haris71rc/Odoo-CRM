import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/features/leads/domain/entities/lost_reason.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';

class LostSelection {
  const LostSelection(this.reasonId, this.feedback);
  final int reasonId;
  final String feedback;
}

Future<LostSelection?> showMarkLostSheet(BuildContext context, int leadId) =>
    showModalBottomSheet<LostSelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MarkLostSheet(leadId: leadId),
    );

class _MarkLostSheet extends ConsumerStatefulWidget {
  const _MarkLostSheet({required this.leadId});
  final int leadId;

  @override
  ConsumerState<_MarkLostSheet> createState() => _MarkLostSheetState();
}

class _MarkLostSheetState extends ConsumerState<_MarkLostSheet> {
  final _search = TextEditingController();
  final _feedback = TextEditingController();
  List<LostReason> _reasons = [];
  LostReason? _selected;
  String? _error;
  bool _loading = false;
  bool _browseAll = false;
  int _offset = 0;
  int _total = 0;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _loadSearch();
  }

  @override
  void dispose() {
    _search.dispose();
    _feedback.dispose();
    super.dispose();
  }

  Future<void> _loadSearch() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
      _browseAll = false;
    });
    final result = await ref
        .read(leadRepositoryProvider)
        .searchLostReasons(widget.leadId, _search.text.trim());
    if (!mounted || generation != _generation) return;
    setState(() {
      _loading = false;
      _reasons = result.valueOrNull ?? [];
      _error = result.failureOrNull?.message;
    });
  }

  Future<void> _loadPage({bool reset = false}) async {
    if (_loading) return;
    final generation = ++_generation;
    final offset = reset ? 0 : _offset;
    setState(() {
      _loading = true;
      _error = null;
      _browseAll = true;
    });
    final result = await ref
        .read(leadRepositoryProvider)
        .getLostReasons(widget.leadId, offset: offset);
    if (!mounted || generation != _generation) return;
    setState(() {
      _loading = false;
      _error = result.failureOrNull?.message;
      final page = result.valueOrNull;
      if (page != null) {
        _reasons = reset ? page.records : [..._reasons, ...page.records];
        _offset = offset + page.records.length;
        _total = page.total;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final availableHeight =
        media.size.height -
        media.padding.top -
        media.padding.bottom -
        media.viewInsets.bottom -
        32;
    final sheetHeight = availableHeight.clamp(0.0, 620.0);

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Material(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: sheetHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: AppTheme.navy,
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mark lead as lost',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Choose a reason to continue',
                                style: TextStyle(
                                  color: AppTheme.textOnNavy,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => _loadSearch(),
                      decoration: const InputDecoration(
                        labelText: 'Lost reason',
                        hintText: 'Search reasons',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  if (_selected != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          backgroundColor: AppTheme.lostBg,
                          side: const BorderSide(color: AppTheme.lostBorder),
                          labelStyle: const TextStyle(
                            color: AppTheme.lostFg,
                            fontWeight: FontWeight.w700,
                          ),
                          label: Text(_selected!.name),
                          onDeleted: () => setState(() => _selected = null),
                        ),
                      ),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppTheme.error),
                      ),
                    ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        for (final reason in _reasons)
                          ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            title: Text(reason.name),
                            selected: _selected?.id == reason.id,
                            selectedTileColor: AppTheme.navyTint,
                            trailing: _selected?.id == reason.id
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppTheme.navy,
                                  )
                                : null,
                            onTap: () => setState(() => _selected = reason),
                          ),
                        if (_loading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        if (!_loading && _reasons.isEmpty && _error == null)
                          const ListTile(title: Text('No reasons found')),
                        if (!_loading &&
                            !_browseAll &&
                            _search.text.trim().isEmpty)
                          TextButton(
                            onPressed: () => _loadPage(reset: true),
                            child: const Text('Browse all reasons'),
                          ),
                        if (!_loading && _browseAll && _offset < _total)
                          TextButton(
                            onPressed: _loadPage,
                            child: const Text('Load more'),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: AppTheme.border)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _feedback,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Feedback (optional)',
                            hintText: 'Add a short note',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.lostFg,
                                ),
                                onPressed: _selected == null
                                    ? null
                                    : () => Navigator.of(context).pop(
                                        LostSelection(
                                          _selected!.id,
                                          _feedback.text.trim(),
                                        ),
                                      ),
                                child: const Text('Mark Lost'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
