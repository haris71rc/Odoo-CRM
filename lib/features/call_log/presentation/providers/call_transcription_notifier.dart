import 'dart:async';
import 'dart:io';

import 'package:odoocrm/core/services/call_recording_service.dart';
import 'package:odoocrm/core/utils/html_text_utils.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_transcription_state.dart';
import 'package:odoocrm/features/chatter/presentation/providers/chatter_notifier.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'call_transcription_notifier.g.dart';

@riverpod
class CallTranscriptionNotifier extends _$CallTranscriptionNotifier {
  Timer? _busyTimeout;
  void Function()? _releaseKeepAlive;

  @override
  CallTranscriptionState build(int leadId) {
    final service = ref.read(callRecordingServiceProvider);
    if (service.isSupported) {
      service.setTranscriptionListener(_onTranscriptionEvent);
    }

    ref.onDispose(() {
      _busyTimeout?.cancel();
      _releaseKeepAlive = null;
      if (service.isSupported) {
        service.setTranscriptionListener(null);
      }
    });

    return CallTranscriptionState(
      status: CallTranscriptionStatus.idle,
      leadId: leadId,
    );
  }

  void _retain() {
    _releaseKeepAlive ??= ref.keepAlive().close;
  }

  void _release() {
    _releaseKeepAlive?.call();
    _releaseKeepAlive = null;
  }

  void onRecordingFound(CallRecordingResult recording) {
    if (recording.uri == null) return;
    _retain();
    state = state.copyWith(
      recordingName: recording.name,
      recordingUri: recording.uri,
      clearError: true,
      clearTranscript: true,
    );
    startTranscription(
      uri: recording.uri!,
      name: recording.name,
      mimeType: recording.mimeType,
    );
  }

  void onRecordingNotFound() {
    _retain();
    state = state.copyWith(
      status: CallTranscriptionStatus.recordingNotFound,
      errorCode: 'RECORDING_NOT_FOUND',
      errorMessage:
          "We couldn't automatically find the call recording. Please import it manually.",
    );
  }

  void onImportCancelled() {
    state = state.copyWith(
      status: CallTranscriptionStatus.recordingNotFound,
      errorCode: 'RECORDING_NOT_FOUND',
      errorMessage:
          "We couldn't automatically find the recording for this call.",
      clearError: false,
    );
  }

  void onRecordingError({
    required String code,
    String? message,
  }) {
    _retain();
    if (code == 'IMPORT_CANCELLED') {
      onImportCancelled();
      return;
    }
    if (code == 'RECORDING_NOT_FOUND') {
      onRecordingNotFound();
      return;
    }
    state = state.copyWith(
      status: CallTranscriptionStatus.error,
      errorCode: code,
      errorMessage: _userMessage(code, message),
    );
  }

  Future<void> importRecording() async {
    final service = ref.read(callRecordingServiceProvider);
    if (!service.isSupported) return;

    _retain();

    state = state.copyWith(
      status: CallTranscriptionStatus.importing,
      clearError: true,
    );

    final started = await service.importCallRecording();
    if (!started && state.status == CallTranscriptionStatus.importing) {
      state = state.copyWith(
        status: CallTranscriptionStatus.recordingNotFound,
        errorCode: 'RECORDING_NOT_FOUND',
        errorMessage:
            "We couldn't automatically find the recording for this call.",
      );
    }
  }

  Future<void> startTranscription({
    required String uri,
    String? name,
    String? mimeType,
    String languageTag = 'en-US',
  }) async {
    final service = ref.read(callRecordingServiceProvider);
    if (!service.isSupported) return;

    state = state.copyWith(
      status: CallTranscriptionStatus.awaitingPermission,
      recordingName: name ?? state.recordingName,
      recordingUri: uri,
      clearError: true,
      clearTranscript: true,
    );

    final micGranted = await _ensureMicrophonePermission();
    if (!micGranted) {
      state = state.copyWith(
        status: CallTranscriptionStatus.error,
        errorCode: 'SPEECH_RECOGNITION_PERMISSION_DENIED',
        errorMessage:
            'Microphone permission is required for on-device speech recognition. '
            'Enable it in Settings, then tap Retry.',
      );
      return;
    }

    state = state.copyWith(status: CallTranscriptionStatus.preparingAudio);
    _startBusyTimeout();

    final started = await service.transcribeRecording(
      leadId: leadId,
      uri: uri,
      name: name,
      mimeType: mimeType,
      languageTag: languageTag,
    );

    if (!started) {
      _busyTimeout?.cancel();
      state = state.copyWith(
        status: CallTranscriptionStatus.error,
        errorCode: 'TRANSCRIPTION_START_FAILED',
        errorMessage: 'Could not start transcription. Tap Retry to try again.',
      );
    }
  }

  Future<void> retry() async {
    if (state.errorCode == 'ODOO_SAVE_ERROR' &&
        state.displayTranscript.isNotEmpty) {
      await _saveTranscriptNote(state.displayTranscript);
      return;
    }

    final uri = state.recordingUri;
    if (uri == null || uri.isEmpty) {
      if (state.canImport) {
        await importRecording();
      }
      return;
    }

    await startTranscription(
      uri: uri,
      name: state.recordingName,
    );
  }

  Future<void> cancel() async {
    _busyTimeout?.cancel();
    await ref.read(callRecordingServiceProvider).cancelTranscription();
    state = state.copyWith(
      status: CallTranscriptionStatus.idle,
      clearTranscript: true,
      clearError: true,
    );
  }

  Future<bool> _ensureMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) return false;

    status = await Permission.microphone.request();
    return status.isGranted;
  }

  void _startBusyTimeout() {
    _busyTimeout?.cancel();
    _busyTimeout = Timer(const Duration(seconds: 90), () {
      if (!state.isBusy) return;
      state = state.copyWith(
        status: CallTranscriptionStatus.error,
        errorCode: 'TRANSCRIPTION_TIMEOUT',
        errorMessage:
            'Transcription is taking too long. Check microphone permission '
            'in Settings, then tap Retry.',
      );
    });
  }

  void _onTranscriptionEvent(CallTranscriptionEvent event) {
    if (event.leadId != leadId) return;

    switch (event.type) {
      case CallTranscriptionEventType.status:
        _busyTimeout?.cancel();
        if (event.status != null && event.status != CallTranscriptionStatus.idle) {
          _startBusyTimeout();
        }
        state = state.copyWith(status: event.status);
      case CallTranscriptionEventType.partial:
        _busyTimeout?.cancel();
        _startBusyTimeout();
        state = state.copyWith(
          status: CallTranscriptionStatus.transcribing,
          partialTranscript: event.text ?? '',
        );
      case CallTranscriptionEventType.finalSegment:
        final segment = event.text?.trim();
        if (segment == null || segment.isEmpty) return;
        final combined = state.finalTranscript.isEmpty
            ? segment
            : '${state.finalTranscript} $segment';
        state = state.copyWith(
          status: CallTranscriptionStatus.transcribing,
          finalTranscript: combined,
          partialTranscript: '',
        );
      case CallTranscriptionEventType.complete:
        _busyTimeout?.cancel();
        final incoming = event.transcript?.trim() ?? '';
        final kept = incoming.isNotEmpty ? incoming : state.displayTranscript;
        state = state.copyWith(
          status: CallTranscriptionStatus.savingNote,
          finalTranscript: kept,
          partialTranscript: '',
        );
        unawaited(_saveTranscriptNote(kept));
      case CallTranscriptionEventType.error:
        _busyTimeout?.cancel();
        if (_isBenignCancellation(event.message)) return;
        if (_isEndOfSpeech(event.message) && state.displayTranscript.isNotEmpty) {
          state = state.copyWith(
            status: CallTranscriptionStatus.savingNote,
            finalTranscript: state.displayTranscript,
            partialTranscript: '',
          );
          unawaited(_saveTranscriptNote(state.displayTranscript));
          return;
        }
        state = state.copyWith(
          status: CallTranscriptionStatus.error,
          errorCode: event.code,
          errorMessage: _userMessage(event.code, event.message),
        );
    }
  }

  Future<void> _saveTranscriptNote(String transcript) async {
    final trimmed = transcript.trim();
    if (trimmed.isEmpty) {
      _release();
      state = state.copyWith(
        status: CallTranscriptionStatus.completed,
        finalTranscript: '',
      );
      return;
    }

    state = state.copyWith(status: CallTranscriptionStatus.savingNote);
    final body = HtmlTextUtils.toHtml('Call transcript\n\n$trimmed');
    final error = await ref
        .read(chatterNotifierProvider(leadId).notifier)
        .logNote(body);

    if (error != null) {
      state = state.copyWith(
        status: CallTranscriptionStatus.error,
        errorCode: 'ODOO_SAVE_ERROR',
        errorMessage: 'Could not save the transcript to the lead. Tap Retry.',
      );
      return;
    }

    _release();
    state = state.copyWith(status: CallTranscriptionStatus.completed);
  }

  String _userMessage(String? code, String? message) {
    return switch (code) {
      'RECORDING_NOT_FOUND' =>
        "We couldn't automatically find the call recording. Please import it manually.",
      'NO_PENDING_LEAD' =>
        'Please start the call from a lead before importing a recording.',
      'INVALID_AUDIO' => 'The selected file is not a valid audio recording.',
      'URI_ACCESS_ERROR' => 'Unable to access the selected recording.',
      'MULTIPLE_FILES_SELECTED' =>
        'Please share one call recording at a time.',
      'IMPORT_CANCELLED' =>
        "We couldn't automatically find the recording for this call.",
      'MEDIA_PERMISSION_DENIED' =>
        'Audio access permission is required to detect call recordings.',
      'AUDIO_CONVERSION_ERROR' => 'Could not convert this recording for transcription.',
      'SPEECH_RECOGNITION_UNAVAILABLE' =>
        'On-device speech recognition is not available on this device.',
      'SPEECH_RECOGNITION_ERROR' =>
        message ?? 'Speech recognition failed. Tap Retry to try again.',
      'ODOO_SAVE_ERROR' => 'Could not save the transcript to the lead. Tap Retry.',
      _ => message ?? 'Something went wrong. Please try again.',
    };
  }

  bool _isBenignCancellation(String? message) {
    if (message == null || message.isEmpty) return false;
    final lower = message.toLowerCase();
    return lower.contains('cancelled') || lower.contains('canceled');
  }

  bool _isEndOfSpeech(String? message) {
    if (message == null || message.isEmpty) return false;
    final lower = message.toLowerCase();
    return lower.contains('no_speech_detected') ||
        lower.contains('no speech detected');
  }
}

/// Requests call-recording permissions before placing an outbound call.
Future<void> ensureCallRecordingPermissions() async {
  if (!Platform.isAndroid) return;

  await Permission.microphone.request();

  if (Platform.isAndroid) {
    final audio = await Permission.audio.request();
    if (!audio.isGranted) {
      await Permission.storage.request();
    }
  }
}
