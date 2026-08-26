import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:odoocrm/core/error/failures.dart';
import 'package:odoocrm/core/theme/app_theme.dart';
import 'package:odoocrm/core/theme/stage_colors.dart';
import 'package:odoocrm/core/utils/date_formatters.dart';
import 'package:odoocrm/core/utils/initials.dart';
import 'package:odoocrm/core/widgets/empty_view.dart';
import 'package:odoocrm/core/widgets/error_view.dart';
import 'package:odoocrm/core/widgets/loading_view.dart';
import 'package:odoocrm/features/auth/presentation/providers/auth_notifier.dart';
import 'package:odoocrm/features/chatter/presentation/providers/chatter_notifier.dart';
import 'package:odoocrm/features/chatter/presentation/widgets/chatter_message_body.dart';
import 'package:odoocrm/features/chatter/presentation/widgets/chatter_tracking_values.dart';
import 'package:odoocrm/features/chatter/presentation/widgets/log_note_sheet.dart';
import 'package:odoocrm/features/leads/domain/entities/lead_detail_entity.dart';
import 'package:odoocrm/features/leads/presentation/providers/internal_note_notifier.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_detail_notifier.dart';
import 'package:odoocrm/features/leads/presentation/providers/lead_notifier.dart';
import 'package:odoocrm/features/leads/presentation/widgets/assign_lead_sheet.dart';
import 'package:odoocrm/features/leads/presentation/widgets/whatsapp_actions_sheet.dart';
import 'package:odoocrm/features/leads/presentation/widgets/whatsapp_fab.dart';
import 'package:odoocrm/core/services/whatsapp_service.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_log.dart';
import 'package:odoocrm/features/call_log/presentation/providers/call_log_providers.dart';
import 'package:odoocrm/features/call_log/presentation/widgets/call_log_dialogs.dart';
import 'package:odoocrm/features/call_log/presentation/widgets/last_call_card.dart';
import 'package:odoocrm/features/quotations/presentation/providers/quotation_notifier.dart';
import 'package:odoocrm/features/stages/domain/entities/stage_entity.dart';
import 'package:odoocrm/features/stages/presentation/providers/stage_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

enum _DetailTab { info, internalNote, remarks }

class _PendingDial {
  const _PendingDial({required this.phone, required this.dialedAt});

  final String phone;
  final DateTime dialedAt;
}

class LeadDetailPage extends HookConsumerWidget {
  const LeadDetailPage({super.key, required this.leadId});

  final int leadId;

  bool _isWonName(String? name) {
    final n = name?.toLowerCase() ?? '';
    return n.contains('won');
  }

  bool _isLostName(String? name) {
    final n = name?.toLowerCase() ?? '';
    return n == 'lost' || n.contains('closed lost') || n.endsWith(' lost');
  }

  String _formatInr(double? value) {
    if (value == null) return '—';
    final fmt = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return fmt.format(value);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadAsync = ref.watch(leadDetailNotifierProvider(leadId));
    final currentUser = ref.watch(authNotifierProvider).valueOrNull;
    final stagesAsync = ref.watch(stageNotifierProvider);
    ref.watch(leadCallLogProvider(leadId));
    final isActing = useState(false);
    final isCreatingQuotation = useState(false);
    final tab = useState(_DetailTab.info);
    final pendingDial = useState<_PendingDial?>(null);
    final isLoggingCall = useState(false);

    Future<void> showMessage(String message) async {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    Future<void> showStageValidationError(String message) async {
      if (!context.mounted) return;
      await showCallValidationDialog(context, message);
    }

    Future<void> persistCallLog(
      CallLog callEvent, {
      bool fromAndroidDevice = false,
    }) async {
      isLoggingCall.value = true;

      final lead = leadAsync.valueOrNull;
      final result = await ref.read(callLogServiceProvider).recordOutboundCall(
            leadId: leadId,
            callEvent: callEvent,
            leadCreatedAt: lead?.createdDate,
          );
      isLoggingCall.value = false;

      ref.invalidate(leadCallLogProvider(leadId));

      if (result.isFailure) {
        await showMessage(result.failureOrNull!.message);
        return;
      }

      final assigned = await ref
          .read(leadDetailNotifierProvider(leadId).notifier)
          .autoAssignCaller(currentUser?.id);

      var movedToConnected = false;
      if (fromAndroidDevice) {
        movedToConnected = await ref
            .read(leadDetailNotifierProvider(leadId).notifier)
            .autoMoveToConnected(callEvent);
      }

      if (movedToConnected) {
        await showMessage('Call connected — stage set to Connected');
        return;
      }
      await showMessage(
        assigned ? 'Call saved and assigned to you' : 'Call saved to lead',
      );
    }

    Future<void> completePendingDial(_PendingDial pending) async {
      if (isLoggingCall.value) return;

      final statusOptions =
          await ref.read(callStatusOptionsProvider(leadId).future);
      final reader = ref.read(deviceCallReaderProvider);
      CallLog? callLog;
      if (reader.isSupported) {
        callLog = await reader.findRecentCall(
          phone: pending.phone,
          dialedAt: pending.dialedAt,
          statusOptions: statusOptions,
        );
      }

      if (!context.mounted) return;

      if (callLog != null) {
        await persistCallLog(
          callLog,
          fromAndroidDevice: reader.isSupported,
        );
        return;
      }

      if (reader.isSupported) {
        await showMessage(
          'Android call log is not ready yet. Open this lead again to sync duration from the dialer.',
        );
        return;
      }

      callLog = await showCallOutcomeSheet(
        context: context,
        dialedAt: pending.dialedAt,
        statusOptions: statusOptions,
      );

      if (callLog == null || !context.mounted) return;
      await persistCallLog(callLog);
    }

    useOnAppLifecycleStateChange((previous, current) {
      if (current != AppLifecycleState.resumed) return;
      final pending = pendingDial.value;
      if (pending == null) return;
      pendingDial.value = null;
      Future.microtask(() => completePendingDial(pending));
    });

    Future<void> callCustomer(LeadDetailEntity lead) async {
      final number = lead.phone ?? lead.mobile;
      if (number == null || number.isEmpty) {
        await showMessage('No phone number available');
        return;
      }

      final reader = ref.read(deviceCallReaderProvider);
      if (reader.isSupported) {
        await reader.ensurePermission();
      }

      final dialedAt = DateTime.now();
      pendingDial.value = _PendingDial(phone: number, dialedAt: dialedAt);

      final uri = Uri(scheme: 'tel', path: number);
      final launched = await launchUrl(uri);
      if (!launched) {
        pendingDial.value = null;
        await showMessage('Unable to open dialer');
      }
    }

    Future<void> assignToMe() async {
      if (currentUser == null) {
        await showMessage('User session not found');
        return;
      }
      isActing.value = true;
      final error = await ref
          .read(leadDetailNotifierProvider(leadId).notifier)
          .assignToMe(currentUser.id);
      isActing.value = false;
      ref.invalidate(leadNotifierProvider);
      await showMessage(error ?? 'Assigned to you');
    }

    Future<void> openAssignSheet() async {
      await showAssignLeadSheet(
        context: context,
        ref: ref,
        leadId: leadId,
        currentAssigneeId: leadAsync.valueOrNull?.assignedUser?.id,
      );
    }

    Future<void> setWonLost({required bool won}) async {
      final stages = stagesAsync.valueOrNull ?? const <StageEntity>[];
      StageEntity? target;
      for (final s in stages) {
        if (won && (s.isWon == true || _isWonName(s.name))) {
          target = s;
          break;
        }
        if (!won && _isLostName(s.name)) {
          target = s;
          break;
        }
      }
      if (target == null) {
        await showMessage(won ? 'Won stage not found' : 'Lost stage not found');
        return;
      }
      isActing.value = true;
      final error = await ref
          .read(leadDetailNotifierProvider(leadId).notifier)
          .updateStage(target.id, targetStageName: target.name);
      isActing.value = false;
      ref.invalidate(leadNotifierProvider);
      if (error != null) {
        await showStageValidationError(error);
        return;
      }
      await showMessage(won ? 'Marked as Won' : 'Marked as Lost');
    }

    Future<void> createQuotation() async {
      if (isActing.value || isCreatingQuotation.value) return;

      isActing.value = true;
      isCreatingQuotation.value = true;
      try {
        final error = await ref
            .read(quotationNotifierProvider(leadId).notifier)
            .createQuotation();

        if (error != null) {
          await showMessage(error);
          return;
        }

        // Ensure stage refresh is visible on this screen.
        await ref.read(leadDetailNotifierProvider(leadId).future);
        ref.invalidate(leadNotifierProvider);

        final result = ref.read(quotationNotifierProvider(leadId)).valueOrNull;
        if (result?.alreadyExisted == true) {
          final number = result?.quotationNumber;
          await showMessage(
            number == null || number.isEmpty
                ? 'Quotation already exists.'
                : 'Quotation already exists ($number).',
          );
          return;
        }

        await showMessage('Quotation created successfully.');
      } finally {
        isCreatingQuotation.value = false;
        isActing.value = false;
      }
    }

    Future<void> openStageSheet(LeadDetailEntity lead) async {
      try {
        final available = await ref.read(stageNotifierProvider.future);
        if (!context.mounted) return;
        if (available.isEmpty) {
          await showMessage('No stages available');
          return;
        }

        final sorted = [...available]
          ..sort((a, b) {
            final sa = a.sequence ?? 1 << 30;
            final sb = b.sequence ?? 1 << 30;
            return sa.compareTo(sb);
          });

        final selected = await showModalBottomSheet<StageEntity>(
          context: context,
          backgroundColor: AppTheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Move to stage',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sorted.length,
                      itemBuilder: (context, index) {
                        final stage = sorted[index];
                        final active = stage.id == lead.stage?.id;
                        return InkWell(
                          onTap: () => Navigator.pop(context, stage),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            color: active
                                ? const Color(0xFFF4F7FB)
                                : AppTheme.surface,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: StageColors.forName(stage.name),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    stage.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (active)
                                  const Text(
                                    '✓',
                                    style: TextStyle(
                                      color: AppTheme.navy,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            );
          },
        );

        if (selected == null) return;
        isActing.value = true;
        final error = await ref
            .read(leadDetailNotifierProvider(leadId).notifier)
            .updateStage(selected.id, targetStageName: selected.name);
        isActing.value = false;
        ref.invalidate(leadNotifierProvider);
        if (error != null) {
          await showStageValidationError(error);
          return;
        }
        await showMessage('Stage updated');
      } catch (e) {
        isActing.value = false;
        await showMessage(e is Failure ? e.message : e.toString());
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: leadAsync.when(
        loading: () => const LoadingView(message: 'Loading lead...'),
        error: (error, _) => ErrorView(
          message: error is Failure ? error.message : error.toString(),
          onRetry: () =>
              ref.read(leadDetailNotifierProvider(leadId).notifier).refresh(),
        ),
        data: (lead) {
          final stages = stagesAsync.valueOrNull ?? const <StageEntity>[];
          final sortedStages = [...stages]
            ..sort((a, b) => (a.sequence ?? 0).compareTo(b.sequence ?? 0));
          final stageIndex = sortedStages.indexWhere(
            (s) => s.id == lead.stage?.id,
          );
          final isMine = lead.assignedUser?.id == currentUser?.id;
          final isWon = _isWonName(lead.stage?.name);
          final isLost = _isLostName(lead.stage?.name);
          final phone = lead.phone ?? lead.mobile ?? '';
          final noteState = ref.watch(internalNoteNotifierProvider(leadId));
          final editingNote =
              tab.value == _DetailTab.internalNote && noteState.isEditing;

          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    color: AppTheme.navy,
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 4, 14, 0),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => context.pop(),
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                Text(
                                  'Opportunity #${lead.id}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textOnNavy,
                                    letterSpacing: 0.02,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lead.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.02,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      _formatInr(lead.expectedRevenue),
                                      style: AppTheme.mono(
                                        fontSize: 13,
                                        color: AppTheme.goldSoft,
                                      ),
                                    ),
                                    Text(
                                      '${lead.probability?.toStringAsFixed(0) ?? '—'}% probability',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textOnNavy,
                                      ),
                                    ),
                                    if (lead.partnerName != null)
                                      Text(
                                        '· ${lead.partnerName}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textOnNavy,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _HeaderAction(
                                        label: isWon ? 'Won' : 'Mark Won',
                                        icon: Icons.check,
                                        active: isWon,
                                        onTap: isActing.value
                                            ? null
                                            : () => setWonLost(won: true),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _HeaderAction(
                                        label: isLost ? 'Lost' : 'Mark Lost',
                                        icon: Icons.close,
                                        active: isLost,
                                        danger: true,
                                        onTap: isActing.value
                                            ? null
                                            : () => setWonLost(won: false),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _HeaderAction(
                                  label: isCreatingQuotation.value
                                      ? 'Creating…'
                                      : 'Quotation',
                                  icon: Icons.request_quote_outlined,
                                  active: false,
                                  loading: isCreatingQuotation.value,
                                  onTap: isActing.value ||
                                          isCreatingQuotation.value
                                      ? null
                                      : createQuotation,
                                ),
                                const SizedBox(height: 14),
                                InkWell(
                                  onTap: isActing.value
                                      ? null
                                      : () => openStageSheet(lead),
                                  borderRadius: BorderRadius.circular(11),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 13,
                                      vertical: 11,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(11),
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.18),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'STAGE',
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  letterSpacing: 0.12,
                                                  color: AppTheme.textOnNavy,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                lead.stage?.name ?? '—',
                                                style: const TextStyle(
                                                  fontSize: 14.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            for (var i = 0;
                                                i < sortedStages.length && i < 6;
                                                i++) ...[
                                              if (i > 0) const SizedBox(width: 4),
                                              Container(
                                                width: 7,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                  color: i <= stageIndex
                                                      ? AppTheme.goldSoft
                                                      : Colors.white
                                                          .withValues(alpha: 0.25),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ],
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            _DetailTabBtn(
                                              label: 'Details',
                                              selected:
                                                  tab.value == _DetailTab.info,
                                              onTap: () =>
                                                  tab.value = _DetailTab.info,
                                            ),
                                            const SizedBox(width: 20),
                                            _DetailTabBtn(
                                              label: 'Internal Note',
                                              selected: tab.value ==
                                                  _DetailTab.internalNote,
                                              onTap: () => tab.value =
                                                  _DetailTab.internalNote,
                                            ),
                                            const SizedBox(width: 20),
                                            _DetailTabBtn(
                                              label: 'Remarks',
                                              selected: tab.value ==
                                                  _DetailTab.remarks,
                                              onTap: () => tab.value =
                                                  _DetailTab.remarks,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _AssignToBtn(
                                      onTap: isActing.value
                                          ? null
                                          : openAssignSheet,
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
                  Expanded(
                    child: RefreshIndicator(
                      color: AppTheme.navy,
                      onRefresh: () async {
                        await ref
                            .read(leadDetailNotifierProvider(leadId).notifier)
                            .refresh();
                        await ref
                            .read(chatterNotifierProvider(leadId).notifier)
                            .refresh();
                        ref.invalidate(leadCallLogProvider(leadId));
                      },
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 168),
                        children: [
                          if (tab.value == _DetailTab.info)
                            _DetailsTab(
                              lead: lead,
                              leadId: leadId,
                              isMine: isMine,
                              isActing: isActing.value,
                              onAssign: assignToMe,
                              formatInr: _formatInr,
                            ),
                          if (tab.value == _DetailTab.internalNote)
                            _InternalNoteTab(leadId: leadId),
                          if (tab.value == _DetailTab.remarks)
                            _RemarksTab(leadId: leadId),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    14,
                    12,
                    14,
                    16 + MediaQuery.paddingOf(context).bottom,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppTheme.scaffold,
                        Color(0x00F6F7F9),
                      ],
                      stops: [0.68, 1],
                    ),
                  ),
                  child: editingNote
                      ? Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: noteState.isSaving
                                    ? null
                                    : () => ref
                                        .read(
                                          internalNoteNotifierProvider(
                                            leadId,
                                          ).notifier,
                                        )
                                        .cancel(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.textSecondary,
                                  side: const BorderSide(
                                    color: AppTheme.borderStrong,
                                  ),
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(27),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: noteState.isSaving
                                    ? null
                                    : () async {
                                        final error = await ref
                                            .read(
                                              internalNoteNotifierProvider(
                                                leadId,
                                              ).notifier,
                                            )
                                            .save();
                                        if (!context.mounted) return;
                                        await showMessage(
                                          error ??
                                              'Internal notes updated successfully.',
                                        );
                                      },
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.navy,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(27),
                                  ),
                                ),
                                child: noteState.isSaving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Save',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        )
                      : SizedBox(
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: isActing.value
                                ? null
                                : () => callCustomer(lead),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.callGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(27),
                              ),
                              elevation: 0,
                              shadowColor:
                                  AppTheme.callGreen.withValues(alpha: 0.32),
                            ),
                            icon: const Icon(Icons.phone, size: 19),
                            label: Text(
                              phone.isEmpty ? 'Call' : 'Call $phone',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              // WhatsApp FAB — 16dp from right, 24dp above the Call bar.
              Positioned(
                right: 16,
                bottom: 16 +
                    MediaQuery.paddingOf(context).bottom +
                    54 +
                    24,
                child: WhatsAppFab(
                  onPressed: () {
                    showWhatsAppActionsSheet(
                      context: context,
                      phone: phone,
                      service: ref.read(whatsAppServiceProvider),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.label,
    required this.icon,
    required this.active,
    this.danger = false,
    this.loading = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final bool danger;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = danger ? AppTheme.lostFg : AppTheme.wonFg;
    final bg = danger ? AppTheme.lostBg : AppTheme.wonBg;
    final br = danger ? AppTheme.lostBorder : AppTheme.wonBorder;
    final color = active ? fg : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? bg : Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? br : Colors.white.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: color,
                ),
              )
            else
              Icon(
                icon,
                size: 14,
                color: color,
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTabBtn extends StatelessWidget {
  const _DetailTabBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 11),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 2.5,
              color: selected ? AppTheme.goldSoft : Colors.transparent,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppTheme.textOnNavy,
          ),
        ),
      ),
    );
  }
}

class _AssignToBtn extends StatelessWidget {
  const _AssignToBtn({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.goldSoft.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.goldSoft.withValues(alpha: 0.7)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_add_alt_1_rounded,
                size: 14,
                color: AppTheme.goldSoft,
              ),
              SizedBox(width: 5),
              Text(
                'Assign To',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.goldSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({
    required this.lead,
    required this.leadId,
    required this.isMine,
    required this.isActing,
    required this.onAssign,
    required this.formatInr,
  });

  final LeadDetailEntity lead;
  final int leadId;
  final bool isMine;
  final bool isActing;
  final VoidCallback onAssign;
  final String Function(double?) formatInr;

  @override
  Widget build(BuildContext context) {
    final owner = lead.assignedUser?.name ?? 'Unassigned';
    final contactRows = [
      ('Contact', lead.partnerName ?? '—'),
      ('Phone', lead.phone ?? lead.mobile ?? '—'),
      ('Email', lead.email ?? '—'),
      (
        'City',
        [
          lead.city,
          lead.state?.name,
        ].whereType<String>().where((e) => e.isNotEmpty).join(', ').ifEmpty('—'),
      ),
    ];
    final crmRows = [
      ('Expected revenue', formatInr(lead.expectedRevenue)),
      (
        'Probability',
        lead.probability == null
            ? '—'
            : '${lead.probability!.toStringAsFixed(0)}%',
      ),
      ('Priority', lead.priority ?? '—'),
      ('Team', lead.team?.name ?? 'Inside Sales'),
      ('Created', DateFormatters.formatDateTime(lead.createdDate)),
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isMine ? const Color(0xFFF4F7FB) : AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isMine ? AppTheme.navy.withValues(alpha: 0.25) : AppTheme.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: owner == 'Unassigned'
                      ? const Color(0xFFF2F4F7)
                      : AppTheme.navy,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initialsOf(owner),
                  style: TextStyle(
                    color: owner == 'Unassigned'
                        ? AppTheme.textMuted
                        : Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SALESPERSON',
                      style: TextStyle(
                        fontSize: 10.5,
                        letterSpacing: 0.12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      owner,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: owner == 'Unassigned'
                            ? AppTheme.textMuted
                            : AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Sales Team: ${lead.team?.name ?? 'Inside Sales'}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.textBody,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMine)
                TextButton(
                  onPressed: isActing ? null : onAssign,
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.navyTint,
                    foregroundColor: AppTheme.navy,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Assign to me',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        LastCallCard(leadId: leadId),
        const SizedBox(height: 12),
        _KeyValueCard(title: 'Contact', rows: contactRows),
        const SizedBox(height: 12),
        _KeyValueCard(title: 'CRM details', rows: crmRows, monoValues: true),
      ],
    );
  }
}

class _InternalNoteTab extends HookConsumerWidget {
  const _InternalNoteTab({required this.leadId});

  final int leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteState = ref.watch(internalNoteNotifierProvider(leadId));
    final notifier = ref.read(internalNoteNotifierProvider(leadId).notifier);
    final controller = useTextEditingController(text: noteState.currentNote);
    final focusNode = useFocusNode();

    useEffect(() {
      if (controller.text != noteState.currentNote) {
        controller.value = TextEditingValue(
          text: noteState.currentNote,
          selection: TextSelection.collapsed(
            offset: noteState.currentNote.length,
          ),
        );
      }
      return null;
    }, [noteState.originalNote, noteState.isEditing, noteState.isSaving]);

    useEffect(() {
      if (noteState.isEditing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (focusNode.canRequestFocus) {
            focusNode.requestFocus();
          }
        });
      }
      return null;
    }, [noteState.isEditing]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Internal Notes',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                focusNode: focusNode,
                readOnly: !noteState.isEditing || noteState.isSaving,
                minLines: 12,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textAlignVertical: TextAlignVertical.top,
                onChanged: notifier.updateNote,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Write internal notes...',
                  hintStyle: const TextStyle(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: noteState.isEditing
                      ? AppTheme.surface
                      : AppTheme.elevated,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderStrong),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.borderStrong),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.navy,
                      width: 1.5,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.border),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!noteState.isEditing) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: notifier.startEditing,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text(
                'Edit Internal Note',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _KeyValueCard extends StatelessWidget {
  const _KeyValueCard({
    required this.title,
    required this.rows,
    this.monoValues = false,
  });

  final String title;
  final List<(String, String)> rows;
  final bool monoValues;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 13, 15, 4),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10.5,
                letterSpacing: 0.12,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFF2F4F7)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Row(
                children: [
                  Text(
                    rows[i].$1,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textBody,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rows[i].$2,
                      textAlign: TextAlign.right,
                      style: monoValues
                          ? AppTheme.mono(
                              fontSize: 12.5,
                              color: AppTheme.textPrimary,
                            )
                          : const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RemarksTab extends ConsumerWidget {
  const _RemarksTab({required this.leadId});

  final int leadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(chatterNotifierProvider(leadId));

    return Column(
      children: [
        InkWell(
          onTap: () => showLogNoteSheet(
            context: context,
            ref: ref,
            leadId: leadId,
          ),
          borderRadius: BorderRadius.circular(13),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: const Color(0xFFC6D0DF),
                width: 1.5,
              ),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: AppTheme.navyTint,
                  child: Icon(Icons.add, size: 15, color: AppTheme.navy),
                ),
                SizedBox(width: 10),
                Text(
                  'Add remark',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.navy,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        messagesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: LoadingView(),
          ),
          error: (error, _) => ErrorView(
            message: error is Failure ? error.message : error.toString(),
            onRetry: () =>
                ref.read(chatterNotifierProvider(leadId).notifier).refresh(),
          ),
          data: (messages) {
            final notes = messages
                .where(
                  (m) =>
                      m.isNote ||
                      m.hasBody ||
                      m.hasTracking ||
                      (m.subtypeDescription?.trim().isNotEmpty ?? false),
                )
                .toList();
            if (notes.isEmpty) {
              return const EmptyView(
                message: 'No remarks yet',
                icon: Icons.sticky_note_2_outlined,
              );
            }
            return Column(
              children: [
                for (final note in notes) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                note.authorName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              DateFormatters.formatChatterDateTime(note.date),
                              style: AppTheme.mono(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        if (note.subtypeDescription?.trim().isNotEmpty ??
                            false) ...[
                          const SizedBox(height: 6),
                          Text(
                            note.subtypeDescription!.trim(),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                        if (note.hasTracking) ...[
                          const SizedBox(height: 6),
                          ChatterTrackingValues(values: note.trackingValues),
                        ],
                        if (note.hasBody) ...[
                          const SizedBox(height: 6),
                          ChatterMessageBody(html: note.body),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
