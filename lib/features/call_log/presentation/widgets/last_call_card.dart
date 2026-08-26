import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/presentation/providers/call_log_providers.dart';

class LastCallCard extends ConsumerStatefulWidget {
  const LastCallCard({super.key, required this.leadId});

  final int leadId;

  @override
  ConsumerState<LastCallCard> createState() => _LastCallCardState();
}

class _LastCallCardState extends ConsumerState<LastCallCard> {
  CallLog? _cached;
  var _isSyncing = false;

  Future<void> _sync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    ref.invalidate(leadCallLogProvider(widget.leadId));
    try {
      await ref.read(leadCallLogProvider(widget.leadId).future);
    } catch (_) {
      // Keep cached data; error UI handled below when no cache.
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final callLogAsync = ref.watch(leadCallLogProvider(widget.leadId));
    final reader = ref.watch(deviceCallReaderProvider);

    ref.listen(leadCallLogProvider(widget.leadId), (previous, next) {
      final value = next.valueOrNull;
      if (value != null && mounted) {
        setState(() => _cached = value);
      }
    });

    final callLog = callLogAsync.valueOrNull ?? _cached;
    final showSync = reader.isSupported;
    final isInitialLoading = callLog == null && callLogAsync.isLoading;

    Widget body;
    if (isInitialLoading) {
      body = const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (callLog == null && callLogAsync.hasError) {
      body = const Text(
        'Unable to load call information.',
        style: TextStyle(color: AppTheme.textBody, fontSize: 13.5),
      );
    } else if (callLog == null || !callLog.hasAnyCallData) {
      body = const Text(
        'No call has been made yet.',
        style: TextStyle(
          color: AppTheme.textBody,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
      );
    } else {
      body = _CallDetails(callLog: callLog);
    }

    return _CallLogShell(
      isSyncing: _isSyncing,
      onSync: showSync ? _sync : null,
      child: body,
    );
  }
}

class _CallLogShell extends StatelessWidget {
  const _CallLogShell({
    required this.child,
    this.onSync,
    this.isSyncing = false,
  });

  final Widget child;
  final VoidCallback? onSync;
  final bool isSyncing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'CALL LOG',
                  style: TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 0.12,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onSync != null)
                _SyncButton(
                  isSyncing: isSyncing,
                  onTap: isSyncing ? null : onSync,
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _SyncButton extends StatefulWidget {
  const _SyncButton({
    required this.isSyncing,
    required this.onTap,
  });

  final bool isSyncing;
  final VoidCallback? onTap;

  @override
  State<_SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<_SyncButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isSyncing) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant _SyncButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSyncing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isSyncing && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          children: [
            RotationTransition(
              turns: _controller,
              child: Icon(
                Icons.sync,
                size: 14,
                color: widget.isSyncing
                    ? AppTheme.navy.withValues(alpha: 0.7)
                    : AppTheme.navy,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              widget.isSyncing ? 'Syncing' : 'Sync',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: widget.isSyncing
                    ? AppTheme.navy.withValues(alpha: 0.7)
                    : AppTheme.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallDetails extends StatelessWidget {
  const _CallDetails({required this.callLog});

  final CallLog callLog;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('First call', _formatCallDate(callLog.firstCallDate)),
      (
        'Last call',
        _formatCallDate(callLog.lastCallDate ?? callLog.firstCallDate),
      ),
      ('Status', _formatStatus(callLog.status)),
      ('Total duration', callLog.totalDuration ?? callLog.duration ?? '—'),
      ('Inbound calls', _formatCount(callLog.totalInboundCalls)),
      ('Outbound calls', _formatCount(callLog.totalOutboundCalls)),
      ('Response time', _formatResponseTime(callLog.responseTimeMinutes)),
    ];

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 112,
                child: Text(
                  rows[i].$1,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textBody,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  rows[i].$2,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatCallDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('dd MMM yyyy, hh:mm a').format(date.toLocal());
  }

  String _formatStatus(String? status) {
    if (status == null || status.isEmpty) return '—';
    return status.replaceAll('_', ' ');
  }

  String _formatCount(int? count) => count?.toString() ?? '0';

  String _formatResponseTime(double? minutes) {
    if (minutes == null) return '—';
    return '${minutes.toStringAsFixed(2)} min';
  }
}
