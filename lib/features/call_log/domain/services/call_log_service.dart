import 'dart:async';

import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/call_log/data/services/follow_up_stage_resolver.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';
import 'package:odoocrm/features/call_log/domain/entities/device_call_event.dart';
import 'package:odoocrm/features/call_log/domain/repository/call_log_repository.dart';
import 'package:odoocrm/features/call_log/domain/services/growth_call_log_service.dart';
import 'package:odoocrm/features/call_log/domain/entities/lead_call_sync_cursor.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_catch_up.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_duration.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_updater.dart';
import 'package:odoocrm/features/chatter/domain/repository/chatter_repository.dart';
import 'package:odoocrm/features/leads/presentation/utils/lead_list_filters.dart';

/// Business rules for call logs and CRM stage transitions.
class CallLogService {
  CallLogService({
    required CallLogRepository repository,
    required ChatterRepository chatterRepository,
    GrowthCallLogService? growthCallLogService,
    FollowUpStageResolver followUpResolver = const FollowUpStageResolver(),
  })  : _repository = repository,
        _chatterRepository = chatterRepository,
        _growthCallLogService = growthCallLogService,
        _followUpResolver = followUpResolver;

  final CallLogRepository _repository;
  final ChatterRepository _chatterRepository;
  final GrowthCallLogService? _growthCallLogService;
  final FollowUpStageResolver _followUpResolver;

  static const rule1Message =
      'Please call the customer before changing the stage.';

  static const rule2Message =
      'Please complete a call before moving this lead from Follow-Up.';

  Future<Result<CallLog>> getCallLog(int leadId) {
    return _repository.getCallLog(leadId);
  }

  Future<Result<List<CallStatusOption>>> getCallStatusOptions(int leadId) {
    return _repository.getCallStatusOptions(leadId);
  }

  Future<Result<void>> saveCallLog({
    required int leadId,
    required CallLog callLog,
  }) {
    return _repository.saveCallLog(leadId: leadId, callLog: callLog);
  }

  /// Merges an outbound call event into existing properties and saves.
  ///
  /// On success, also posts to Growth BI (`/api/v1/calls/log`) best-effort.
  Future<Result<void>> recordOutboundCall({
    required int leadId,
    required CallLog callEvent,
    required DateTime? leadCreatedAt,
    String? salesperson,
  }) async {
    final existingResult = await getCallLog(leadId);
    if (existingResult.isFailure) {
      return Error(existingResult.failureOrNull!);
    }

    final merged = CallLogUpdater.repairIncomplete(
      existing: CallLogUpdater.applyOutboundCall(
        existing: existingResult.valueOrNull ?? const CallLog(),
        callEvent: callEvent,
        leadCreatedAt: leadCreatedAt,
      ),
      leadCreatedAt: leadCreatedAt,
    );

    final saveResult = await saveCallLog(leadId: leadId, callLog: merged);
    if (saveResult.isSuccess) {
      _enqueueGrowthOutbound(
        leadId: leadId,
        callEvent: callEvent,
        salesperson: salesperson,
      );
    }
    return saveResult;
  }

  /// Saves a dialer row for a CRM-initiated call.
  ///
  /// A row already stored for this dial (including a `00:00` placeholder whose
  /// dialer timestamp is hangup time) is updated in place. A genuinely new
  /// call increments the outbound count.
  Future<Result<CallLog>> saveRecognizedOutbound({
    required int leadId,
    required CallLog callEvent,
    required DateTime? leadCreatedAt,
    String? salesperson,
  }) async {
    final existingResult = await getCallLog(leadId);
    if (existingResult.isFailure) {
      return Error(existingResult.failureOrNull!);
    }

    final existing = existingResult.valueOrNull ?? const CallLog();
    final eventTime = callEvent.lastCallDate ?? DateTime.now();
    final deviceSeconds = CallLogDuration.parseToSeconds(callEvent.duration);
    final storedSeconds = CallLogDuration.parseToSeconds(existing.duration);
    final isNew = CallLogUpdater.shouldApplyDeviceOutbound(
      deviceAt: eventTime,
      lastCallDate: existing.lastCallDate,
      firstCallDate: existing.firstCallDate,
      storedDurationSeconds: storedSeconds,
      deviceDurationSeconds: deviceSeconds,
    );

    if (!isNew) {
      final upgraded = CallLogUpdater.overlayDialerDetails(
        existing: existing,
        event: DeviceCallEvent(
          at: eventTime,
          duration: callEvent.duration ?? CallLogDuration.formatFromSeconds(0),
          status: callEvent.status ?? existing.status ?? '',
          isOutbound: true,
          isInbound: false,
        ),
      );
      if (!CallLogUpdater.metricsChanged(existing, upgraded)) {
        return Success(upgraded);
      }
      final saveResult = await saveCallLog(leadId: leadId, callLog: upgraded);
      if (saveResult.isFailure) return Error(saveResult.failureOrNull!);
      _enqueueGrowthOutbound(
        leadId: leadId,
        callEvent: callEvent,
        salesperson: salesperson,
      );
      return Success(upgraded);
    }

    final recorded = await recordOutboundCall(
      leadId: leadId,
      callEvent: callEvent,
      leadCreatedAt: leadCreatedAt,
      salesperson: salesperson,
    );
    if (recorded.isFailure) return Error(recorded.failureOrNull!);
    return Success(callEvent);
  }

  /// Syncs inbound call count from the device when it exceeds stored value.
  Future<Result<CallLog>> syncInboundCalls({
    required int leadId,
    required int deviceInboundCount,
  }) async {
    final existingResult = await getCallLog(leadId);
    if (existingResult.isFailure) {
      return Error(existingResult.failureOrNull!);
    }

    final existing = existingResult.valueOrNull ?? const CallLog();
    final synced = CallLogUpdater.applyInboundSync(
      existing: existing,
      deviceInboundCount: deviceInboundCount,
    );

    if (synced.totalInboundCalls != existing.totalInboundCalls) {
      final saveResult = await saveCallLog(leadId: leadId, callLog: synced);
      if (saveResult.isFailure) return Error(saveResult.failureOrNull!);
    }

    return Success(synced);
  }

  /// Catches Odoo up to the Android dialer.
  ///
  /// Outbound rows after the saved last call are all applied. The saved call
  /// itself is only refreshed. [remembered] stops a later Sync from applying
  /// the same Android row again. [persistCursor] runs only after a successful
  /// Odoo write, or immediately when nothing changed.
  Future<Result<CallLog>> syncFromDevice({
    required int leadId,
    required List<DeviceCallEvent> deviceCalls,
    required DateTime? leadCreatedAt,
    String? salesperson,
    LeadCallSyncCursor remembered = LeadCallSyncCursor.empty,
    Future<void> Function(LeadCallSyncCursor cursor)? persistCursor,
  }) async {
    final existingResult = await getCallLog(leadId);
    if (existingResult.isFailure) {
      return Error(existingResult.failureOrNull!);
    }

    final existing = existingResult.valueOrNull ?? const CallLog();
    final catchUp = CallLogCatchUp.apply(
      existing: existing,
      deviceCalls: deviceCalls,
      leadCreatedAt: leadCreatedAt,
      remembered: remembered,
    );

    if (CallLogUpdater.metricsChanged(existing, catchUp.log)) {
      final saveResult = await saveCallLog(leadId: leadId, callLog: catchUp.log);
      if (saveResult.isFailure) return Error(saveResult.failureOrNull!);

      for (final event in catchUp.newOutbound) {
        _enqueueGrowthOutbound(
          leadId: leadId,
          callEvent: CallLog(
            lastCallDate: event.at,
            duration: event.duration,
            status: event.status,
          ),
          salesperson: salesperson,
        );
      }
    }

    if (persistCursor != null &&
        (deviceCalls.isNotEmpty || remembered.seeded)) {
      await persistCursor(catchUp.cursor);
    }
    return Success(catchUp.log);
  }

  void _enqueueGrowthOutbound({
    required int leadId,
    required CallLog callEvent,
    String? salesperson,
  }) {
    final growth = _growthCallLogService;
    if (growth == null) return;
    // Local outbox write + background drain (HTTP is not awaited).
    unawaited(
      growth.enqueueOutboundCall(
        leadId: leadId,
        callEvent: callEvent,
        salesperson: salesperson,
      ),
    );
  }

  /// Returns an error message when the transition is blocked, otherwise null.
  ///
  /// Rule 2 (Follow-Up → Do Not Picked / any other stage) is checked first:
  /// allow only when `lastCallDate` is **strictly after** Follow-Up entry time.
  /// Call Status may be missing in Odoo when tag options are incomplete; the
  /// date check is the source of truth for leaving Follow-Up.
  String? canMoveToStage({
    required CallLog callLog,
    required String? currentStageName,
    required String? targetStageName,
    DateTime? followUpEnteredAt,
  }) {
    final currentFollowUp = LeadListFilters.isFollowUp(currentStageName);
    final targetFollowUp = LeadListFilters.isFollowUp(targetStageName);

    // Rule 2 — leaving Follow-Up (including → Do Not Picked).
    if (currentFollowUp && !targetFollowUp) {
      if (!_hasCallAfterFollowUp(
        callLog: callLog,
        followUpEnteredAt: followUpEnteredAt,
      )) {
        return rule2Message;
      }
      return null;
    }

    // Rule 1 — without a call date, only Follow-Up is allowed.
    if (callLog.lastCallDate == null && !targetFollowUp) {
      return rule1Message;
    }

    return null;
  }

  /// `true` when last call time is strictly after Follow-Up entry.
  ///
  /// Also allows a short grace window when Call Date is slightly before the
  /// Follow-Up timestamp: call-log saves bump `write_date`, which is used as a
  /// Follow-Up proxy when chatter is empty, and CRM dial time is set before
  /// that save.
  bool _hasCallAfterFollowUp({
    required CallLog callLog,
    required DateTime? followUpEnteredAt,
  }) {
    final lastCall = callLog.lastCallDate;
    if (lastCall == null || followUpEnteredAt == null) return false;

    final callLocal = lastCall.toLocal();
    final followLocal = followUpEnteredAt.toLocal();
    if (callLocal.isAfter(followLocal)) return true;

    // Dial-at can land a few seconds before write_date used as Follow-Up proxy.
    final ahead = followLocal.difference(callLocal);
    return ahead > Duration.zero && ahead <= const Duration(minutes: 2);
  }

  /// Loads call log + Follow-up entry time and validates a stage change.
  ///
  /// Prefers the stage name from Odoo over the UI snapshot so a stale
  /// "New Prospects" name cannot skip Rule 2 right after moving to Follow-Up.
  Future<Result<String?>> validateStageChange({
    required int leadId,
    required String? currentStageName,
    required String? targetStageName,
  }) async {
    final snapshotResult = await _repository.getValidationSnapshot(leadId);
    if (snapshotResult.isFailure) {
      return Error(snapshotResult.failureOrNull!);
    }

    final snapshot = snapshotResult.valueOrNull!;
    final effectiveCurrentStage =
        snapshot.stageName?.trim().isNotEmpty == true
            ? snapshot.stageName
            : currentStageName;

    final followUpAt = LeadListFilters.isFollowUp(effectiveCurrentStage)
        ? await _followUpResolver.resolve(
            _chatterRepository,
            leadId,
            leadWriteDate: snapshot.writeDate,
          )
        : null;

    final error = canMoveToStage(
      callLog: snapshot.callLog,
      currentStageName: effectiveCurrentStage,
      targetStageName: targetStageName,
      followUpEnteredAt: followUpAt,
    );

    return Success(error);
  }
}
