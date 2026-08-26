import 'package:odoocrm/core/error/result.dart';
import 'package:odoocrm/features/call_log/data/services/follow_up_stage_resolver.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_status_option.dart';
import 'package:odoocrm/features/call_log/domain/entities/device_call_event.dart';
import 'package:odoocrm/features/call_log/domain/repository/call_log_repository.dart';
import 'package:odoocrm/features/call_log/domain/utils/call_log_updater.dart';
import 'package:odoocrm/features/chatter/domain/repository/chatter_repository.dart';
import 'package:odoocrm/features/leads/presentation/utils/lead_list_filters.dart';

/// Business rules for call logs and CRM stage transitions.
class CallLogService {
  CallLogService({
    required CallLogRepository repository,
    required ChatterRepository chatterRepository,
    FollowUpStageResolver followUpResolver = const FollowUpStageResolver(),
  })  : _repository = repository,
        _chatterRepository = chatterRepository,
        _followUpResolver = followUpResolver;

  final CallLogRepository _repository;
  final ChatterRepository _chatterRepository;
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
  Future<Result<void>> recordOutboundCall({
    required int leadId,
    required CallLog callEvent,
    required DateTime? leadCreatedAt,
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

    return saveCallLog(leadId: leadId, callLog: merged);
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

  /// Merges dialer-made device calls into Odoo when Lead Detail opens.
  ///
  /// Only outbound calls newer than the stored last call (outside the
  /// duplicate window) are applied. Inbound totals are raised to match device.
  Future<Result<CallLog>> syncFromDevice({
    required int leadId,
    required List<DeviceCallEvent> deviceCalls,
    required DateTime? leadCreatedAt,
  }) async {
    final existingResult = await getCallLog(leadId);
    if (existingResult.isFailure) {
      return Error(existingResult.failureOrNull!);
    }

    final existing = existingResult.valueOrNull ?? const CallLog();
    final synced = CallLogUpdater.applyDeviceSync(
      existing: existing,
      deviceCalls: deviceCalls,
      leadCreatedAt: leadCreatedAt,
    );

    if (CallLogUpdater.metricsChanged(existing, synced)) {
      final saveResult = await saveCallLog(leadId: leadId, callLog: synced);
      if (saveResult.isFailure) return Error(saveResult.failureOrNull!);
    }

    return Success(synced);
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

  /// `true` only when last call time is strictly greater than Follow-Up entry.
  bool _hasCallAfterFollowUp({
    required CallLog callLog,
    required DateTime? followUpEnteredAt,
  }) {
    final lastCall = callLog.lastCallDate;
    if (lastCall == null || followUpEnteredAt == null) return false;

    // Call Date in lead_properties is local wall-clock (IST).
    // Chatter stage-change `date` is UTC → converted to local by the resolver.
    // Compare local wall-clock values so timezone cannot invert the result.
    return lastCall.toLocal().isAfter(followUpEnteredAt.toLocal());
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
