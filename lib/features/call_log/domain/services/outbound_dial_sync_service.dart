import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:odoocrm/features/call_log/data/datasource/pending_outbound_dial_store.dart';
import 'package:odoocrm/features/call_log/data/services/device_call_reader.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';
import 'package:odoocrm/features/call_log/domain/entities/pending_outbound_dial.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_duration.dart';
import 'package:odoocrm/features/call_log/domain/utils/outbound_dial_sync_policy.dart';

class OutboundPersistRequest {
  const OutboundPersistRequest({
    required this.leadId,
    required this.callLog,
    required this.dialedAt,
  });

  final int leadId;
  final CallLog callLog;
  final DateTime dialedAt;
}

class OutboundPersistResult {
  const OutboundPersistResult({required this.saved, this.message});

  final bool saved;
  final String? message;
}

class OutboundDialNotice {
  const OutboundDialNotice({required this.leadId, required this.message});

  final int leadId;
  final String message;
}

/// Finishes a CRM dial from the Android call log once the app is foregrounded.
///
/// Pending state is durable. Background time does not clear it, and a manual
/// dismiss does not either — the next foreground resume tries again.
class OutboundDialSyncService {
  OutboundDialSyncService({
    required PendingOutboundDialStore store,
    required DeviceCallReader reader,
    required Future<OutboundPersistResult> Function(OutboundPersistRequest request)
        persist,
    required Future<List<CallStatusOption>> Function(int leadId) statusOptions,
    required bool Function() isResumed,
  })  : _store = store,
        _reader = reader,
        _persist = persist,
        _statusOptions = statusOptions,
        _isResumed = isResumed;

  final PendingOutboundDialStore _store;
  final DeviceCallReader _reader;
  final Future<OutboundPersistResult> Function(OutboundPersistRequest request)
      _persist;
  final Future<List<CallStatusOption>> Function(int leadId) _statusOptions;
  final bool Function() _isResumed;

  final pending = ValueNotifier<PendingOutboundDial?>(null);
  final promptLeadId = ValueNotifier<int?>(null);
  final notice = ValueNotifier<OutboundDialNotice?>(null);

  Timer? _timer;
  Future<void>? _inFlight;
  var _rerun = false;
  var _foregroundMisses = 0;
  var _zeroDurationChecks = 0;
  var _promptOpen = false;
  DateTime? _suppressPromptUntil;

  Future<void> hydrate({bool sync = false}) async {
    final loaded = await _store.load();
    // A dial started while this load was in flight must not be cleared.
    pending.value ??= loaded;
    if (sync && pending.value != null && _isResumed()) {
      await syncIfForeground();
    }
  }

  Future<void> begin({
    required int leadId,
    required String phone,
    required DateTime dialedAt,
  }) async {
    _timer?.cancel();
    _foregroundMisses = 0;
    _zeroDurationChecks = 0;
    _suppressPromptUntil = null;
    _promptOpen = false;
    promptLeadId.value = null;
    final dial = PendingOutboundDial(
      leadId: leadId,
      phone: phone,
      dialedAt: dialedAt,
    );
    pending.value = dial;
    await _store.save(dial);
  }

  /// Dialer failed to open. Nothing to sync.
  Future<void> abandon() async {
    _timer?.cancel();
    _promptOpen = false;
    promptLeadId.value = null;
    pending.value = null;
    await _store.clear();
  }

  /// User closed the manual sheet. Keep watching for the dialer row.
  Future<void> deferPrompt() async {
    _promptOpen = false;
    promptLeadId.value = null;
    _suppressPromptUntil = DateTime.now().add(const Duration(minutes: 2));
    final current = pending.value ?? await _store.load();
    if (current == null) return;
    final passive = current.copyWith(passive: true);
    pending.value = passive;
    await _store.save(passive);
  }

  bool claimPrompt(int leadId) {
    if (promptLeadId.value != leadId) return false;
    _promptOpen = true;
    promptLeadId.value = null;
    return true;
  }

  /// The lead screen went away before the manual sheet opened.
  void releasePrompt(int leadId) {
    _promptOpen = false;
    final current = pending.value;
    if (current != null && current.leadId == leadId) {
      promptLeadId.value = leadId;
    }
  }

  void claimNotice(int leadId) {
    if (notice.value?.leadId != leadId) return;
    notice.value = null;
  }

  void onLifecycle({required bool resumed}) {
    if (!resumed) {
      _timer?.cancel();
      _foregroundMisses = 0;
      _zeroDurationChecks = 0;
      return;
    }
    unawaited(syncIfForeground());
  }

  Future<void> commitManual(CallLog callLog) async {
    _promptOpen = false;
    final dial = pending.value ?? await _store.load();
    if (dial == null) return;
    await _commit(dial, callLog, forceFinal: true);
  }

  Future<void> syncIfForeground() {
    if (_inFlight != null) {
      _rerun = true;
      return _inFlight!;
    }
    final run = _sync();
    _inFlight = run.whenComplete(() {
      _inFlight = null;
      if (!_rerun) return;
      _rerun = false;
      if (_isResumed()) unawaited(syncIfForeground());
    });
    return run;
  }

  void dispose() {
    _timer?.cancel();
    pending.dispose();
    promptLeadId.dispose();
    notice.dispose();
  }

  Future<void> _sync() async {
    if (!_isResumed()) return;

    final dial = await _store.load();
    pending.value = dial;
    if (dial == null) return;
    if (!_isResumed()) return;

    if (!dial.awaitingDuration &&
        OutboundDialSyncPolicy.shouldDefer(dial.dialedAt, DateTime.now())) {
      final remaining = OutboundDialSyncPolicy.launchSettle -
          DateTime.now().difference(dial.dialedAt);
      _schedule(remaining.isNegative ? Duration.zero : remaining);
      return;
    }

    if (!_reader.isSupported) {
      _requestPrompt(dial);
      return;
    }

    final permitted = await _reader.ensurePermission();
    if (!_isResumed()) return;
    if (!permitted) {
      _notify(
        dial.leadId,
        'Phone & Call Log permission is required to sync call duration. '
        'You can log the outcome manually, or enable it in Profile.',
      );
      _requestPrompt(dial);
      return;
    }

    final options = await _statusOptions(dial.leadId);
    if (!_isResumed()) return;

    final callLog = await _reader.findRecentCall(
      phone: dial.phone,
      dialedAt: dial.dialedAt,
      statusOptions: options,
      maxAttempts: 3,
    );
    final seconds = CallLogDuration.parseToSeconds(callLog?.duration);

    if (callLog != null && seconds > 0) {
      await _commit(dial, callLog, forceFinal: true);
      return;
    }

    // No finished row yet. Do not give up while the app is backgrounded.
    if (!_isResumed()) return;

    if (dial.awaitingDuration) {
      if (!OutboundDialSyncPolicy.shouldKeepWatchingDuration(
        dial.dialedAt,
        DateTime.now(),
      )) {
        pending.value = null;
        await _store.clear();
        return;
      }
      _zeroDurationChecks++;
      if (_zeroDurationChecks < OutboundDialSyncPolicy.maxZeroDurationChecks) {
        _schedule(OutboundDialSyncPolicy.zeroRetry);
      }
      return;
    }

    if (callLog != null && seconds == 0) {
      _zeroDurationChecks++;
      if (_zeroDurationChecks < OutboundDialSyncPolicy.maxZeroDurationChecks) {
        _schedule(OutboundDialSyncPolicy.zeroRetry);
        return;
      }
      await _commit(dial, callLog, forceFinal: false);
      _zeroDurationChecks = 0;
      _schedule(OutboundDialSyncPolicy.zeroRetry);
      return;
    }

    _foregroundMisses++;
    if (_foregroundMisses < OutboundDialSyncPolicy.maxForegroundMisses) {
      _schedule(OutboundDialSyncPolicy.missRetry);
      return;
    }
    _requestPrompt(dial);
  }

  Future<void> _commit(
    PendingOutboundDial dial,
    CallLog callLog, {
    required bool forceFinal,
  }) async {
    final seconds = CallLogDuration.parseToSeconds(callLog.duration);
    final result = await _persist(
      OutboundPersistRequest(
        leadId: dial.leadId,
        callLog: callLog,
        dialedAt: dial.dialedAt,
      ),
    );
    if (!result.saved) {
      if (result.message != null) _notify(dial.leadId, result.message!);
      return;
    }

    promptLeadId.value = null;
    _promptOpen = false;
    if (!forceFinal && seconds == 0) {
      final watching = dial.copyWith(awaitingDuration: true, passive: true);
      pending.value = watching;
      await _store.save(watching);
    } else {
      pending.value = null;
      await _store.clear();
    }
    if (result.message != null) _notify(dial.leadId, result.message!);
  }

  void _requestPrompt(PendingOutboundDial dial) {
    if (!_isResumed() || _promptOpen) return;
    if (promptLeadId.value == dial.leadId) return;
    final suppress = _suppressPromptUntil;
    if (suppress != null && DateTime.now().isBefore(suppress)) return;
    _notify(
      dial.leadId,
      'Android call log is not ready yet. You can log the outcome manually. '
      'If you skip this, the call still syncs the next time you open the app.',
    );
    promptLeadId.value = dial.leadId;
  }

  void _notify(int leadId, String message) {
    notice.value = OutboundDialNotice(leadId: leadId, message: message);
  }

  void _schedule(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      if (!_isResumed()) return;
      unawaited(syncIfForeground());
    });
  }
}
