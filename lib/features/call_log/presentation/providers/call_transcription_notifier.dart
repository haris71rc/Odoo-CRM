import 'dart:async';
import 'dart:io';

import 'package:odoocrm/core/services/call_recording_service.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_transcription_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'call_transcription_notifier.g.dart';

@riverpod
class CallTranscriptionNotifier extends _$CallTranscriptionNotifier {
  Timer? _busyTimeout;

  @override
  CallTranscriptionState build(int leadId) {
    final service = ref.read(callRecordingServiceProvider);
    if (service.isSupported) {
      service.setTranscriptionListener(_onTranscriptionEvent);
    }

    ref.onDispose(() {
      _busyTimeout?.cancel();
      if (service.isSupported) {
        service.setTranscriptionListener(null);
      }
    });

    return CallTranscriptionState(
      status: CallTranscriptionStatus.idle,
      leadId: leadId,
    );
  }

  void onRecordingFound(CallRecordingResult recording) {
    if (recording.uri == null) return;
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
    final uri = state.recordingUri;
    if (uri == null || uri.isEmpty) return;

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
          status: CallTranscriptionStatus.completed,
          finalTranscript: kept,
          partialTranscript: '',
        );
      case CallTranscriptionEventType.error:
        _busyTimeout?.cancel();
        if (_isBenignCancellation(event.message)) return;
        if (_isEndOfSpeech(event.message) && state.displayTranscript.isNotEmpty) {
          state = state.copyWith(
            status: CallTranscriptionStatus.completed,
            finalTranscript: state.displayTranscript,
            partialTranscript: '',
          );
          return;
        }
        state = state.copyWith(
          status: CallTranscriptionStatus.error,
          errorCode: event.code,
          errorMessage: event.message,
        );
    }
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
