enum CallTranscriptionStatus {
  idle,
  recordingNotFound,
  importing,
  awaitingPermission,
  preparingAudio,
  convertingAudio,
  transcribing,
  savingNote,
  completed,
  error,
}

class CallTranscriptionState {
  const CallTranscriptionState({
    required this.status,
    required this.leadId,
    this.recordingName,
    this.recordingUri,
    this.partialTranscript = '',
    this.finalTranscript = '',
    this.errorCode,
    this.errorMessage,
  });

  final CallTranscriptionStatus status;
  final int leadId;
  final String? recordingName;
  final String? recordingUri;
  final String partialTranscript;
  final String finalTranscript;
  final String? errorCode;
  final String? errorMessage;

  bool get isBusy =>
      status == CallTranscriptionStatus.importing ||
      status == CallTranscriptionStatus.awaitingPermission ||
      status == CallTranscriptionStatus.preparingAudio ||
      status == CallTranscriptionStatus.convertingAudio ||
      status == CallTranscriptionStatus.transcribing ||
      status == CallTranscriptionStatus.savingNote;

  bool get canImport =>
      status == CallTranscriptionStatus.recordingNotFound ||
      status == CallTranscriptionStatus.error;

  String get displayTranscript {
    final finalized = finalTranscript.trim();
    final partial = partialTranscript.trim();
    if (finalized.isNotEmpty && partial.isNotEmpty) {
      if (partial.startsWith(finalized) || finalized.endsWith(partial)) {
        return partial.length >= finalized.length ? partial : finalized;
      }
      return '$finalized $partial';
    }
    if (finalized.isNotEmpty) return finalized;
    return partial;
  }

  String get statusLabel => switch (status) {
        CallTranscriptionStatus.idle => 'Idle',
        CallTranscriptionStatus.recordingNotFound =>
          "We couldn't automatically find the recording for this call.",
        CallTranscriptionStatus.importing => 'Opening recording picker...',
        CallTranscriptionStatus.awaitingPermission =>
          'Waiting for microphone permission...',
        CallTranscriptionStatus.preparingAudio => 'Preparing recording...',
        CallTranscriptionStatus.convertingAudio => 'Converting audio...',
        CallTranscriptionStatus.transcribing => 'Transcribing...',
        CallTranscriptionStatus.savingNote => 'Saving transcript...',
        CallTranscriptionStatus.completed => 'Call transcript saved successfully.',
        CallTranscriptionStatus.error => errorMessage ?? 'Transcription failed.',
      };

  CallTranscriptionState copyWith({
    CallTranscriptionStatus? status,
    int? leadId,
    String? recordingName,
    String? recordingUri,
    String? partialTranscript,
    String? finalTranscript,
    String? errorCode,
    String? errorMessage,
    bool clearError = false,
    bool clearTranscript = false,
  }) {
    return CallTranscriptionState(
      status: status ?? this.status,
      leadId: leadId ?? this.leadId,
      recordingName: recordingName ?? this.recordingName,
      recordingUri: recordingUri ?? this.recordingUri,
      partialTranscript:
          clearTranscript ? '' : (partialTranscript ?? this.partialTranscript),
      finalTranscript:
          clearTranscript ? '' : (finalTranscript ?? this.finalTranscript),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class CallTranscriptionEvent {
  const CallTranscriptionEvent({
    required this.leadId,
    required this.type,
    this.status,
    this.text,
    this.transcript,
    this.code,
    this.message,
  });

  final int leadId;
  final CallTranscriptionEventType type;
  final CallTranscriptionStatus? status;
  final String? text;
  final String? transcript;
  final String? code;
  final String? message;
}

enum CallTranscriptionEventType {
  status,
  partial,
  finalSegment,
  complete,
  error,
}
