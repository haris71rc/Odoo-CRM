import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/features/call_log/domain/entities/call_transcription_state.dart';

/// Result of native call recording detection after a tracked call ends.
class CallRecordingResult {
  const CallRecordingResult({
    required this.success,
    required this.leadId,
    this.uri,
    this.name,
    this.mimeType,
    this.duration,
    this.dateAdded,
    this.size,
    this.relativePath,
    this.source,
    this.code,
    this.message,
  });

  final bool success;
  final int leadId;
  final String? uri;
  final String? name;
  final String? mimeType;
  final int? duration;
  final int? dateAdded;
  final int? size;
  final String? relativePath;
  final String? source;
  final String? code;
  final String? message;

  factory CallRecordingResult.fromMap(Map<dynamic, dynamic> map) {
    return CallRecordingResult(
      success: map['success'] == true,
      leadId: (map['leadId'] as num?)?.toInt() ?? 0,
      uri: map['uri'] as String?,
      name: map['name'] as String?,
      mimeType: map['mimeType'] as String?,
      duration: (map['duration'] as num?)?.toInt(),
      dateAdded: (map['dateAdded'] as num?)?.toInt(),
      size: (map['size'] as num?)?.toInt(),
      relativePath: map['relativePath'] as String?,
      source: map['source'] as String?,
      code: map['code'] as String?,
      message: map['message'] as String?,
    );
  }
}

typedef CallRecordingListener = void Function(CallRecordingResult result);
typedef CallTranscriptionListener = void Function(CallTranscriptionEvent event);

/// Android-only: tracks outbound calls, detects dialer recordings, and
/// transcribes them locally via ML Kit GenAI Speech Recognition.
class CallRecordingService {
  CallRecordingService({MethodChannel? channel})
      : _channel = channel ??
            const MethodChannel('com.bigoh.odoocrm/call_recording') {
    _channel.setMethodCallHandler(_handleNativeCallback);
  }

  static const String _logTag = 'CallRecordingService';

  final MethodChannel _channel;
  CallRecordingListener? _listener;
  CallTranscriptionListener? _transcriptionListener;

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  /// Registers a callback for recording detection events from the native layer.
  void setListener(CallRecordingListener? listener) {
    _listener = listener;
  }

  /// Registers a callback for transcription streaming events.
  void setTranscriptionListener(CallTranscriptionListener? listener) {
    _transcriptionListener = listener;
  }

  /// Starts native call tracking before launching the phone dialer.
  Future<bool> startCallTracking({
    required int leadId,
    required String phoneNumber,
    required DateTime callStartedAt,
  }) async {
    if (!isSupported) return false;

    try {
      final started = await _channel.invokeMethod<bool>(
        'startCallTracking',
        <String, dynamic>{
          'leadId': leadId,
          'phoneNumber': phoneNumber,
          'callStartedAt': callStartedAt.millisecondsSinceEpoch,
        },
      );
      _log('Call tracking started for lead $leadId ($phoneNumber)');
      return started ?? false;
    } on PlatformException catch (e) {
      _log('startCallTracking failed: ${e.code} ${e.message}');
      return false;
    } catch (e) {
      _log('startCallTracking failed: $e');
      return false;
    }
  }

  /// Stops native call tracking and clears pending call state.
  Future<void> stopCallTracking() async {
    if (!isSupported) return;

    try {
      await _channel.invokeMethod<void>('stopCallTracking');
      _log('Call tracking stopped');
    } on PlatformException catch (e) {
      _log('stopCallTracking failed: ${e.code} ${e.message}');
    } catch (e) {
      _log('stopCallTracking failed: $e');
    }
  }

  /// Transcribes a previously detected recording using on-device ML Kit.
  Future<bool> transcribeRecording({
    required int leadId,
    required String uri,
    String? name,
    String? mimeType,
    String languageTag = 'en-US',
  }) async {
    if (!isSupported) return false;

    try {
      final started = await _channel.invokeMethod<bool>(
        'transcribeRecording',
        <String, dynamic>{
          'leadId': leadId,
          'uri': uri,
          'name': name,
          'mimeType': mimeType,
          'languageTag': languageTag,
        },
      );
      _log('Transcription started for lead $leadId');
      return started ?? false;
    } on PlatformException catch (e) {
      _log('transcribeRecording failed: ${e.code} ${e.message}');
      _transcriptionListener?.call(
        CallTranscriptionEvent(
          leadId: leadId,
          type: CallTranscriptionEventType.error,
          code: e.code,
          message: e.message,
        ),
      );
      return false;
    } catch (e) {
      _log('transcribeRecording failed: $e');
      return false;
    }
  }

  /// Cancels an in-progress transcription pipeline.
  Future<void> cancelTranscription() async {
    if (!isSupported) return;

    try {
      await _channel.invokeMethod<void>('cancelTranscription');
      _log('Transcription cancelled');
    } on PlatformException catch (e) {
      _log('cancelTranscription failed: ${e.code} ${e.message}');
    } catch (e) {
      _log('cancelTranscription failed: $e');
    }
  }

  /// Opens the system audio document picker. Does not start picking by itself.
  Future<bool> importCallRecording() async {
    if (!isSupported) return false;

    try {
      final started = await _channel.invokeMethod<bool>('importCallRecording');
      _log('Import picker launched');
      return started ?? false;
    } on PlatformException catch (e) {
      _log('importCallRecording failed: ${e.code} ${e.message}');
      _listener?.call(
        CallRecordingResult(
          success: false,
          leadId: 0,
          code: e.code,
          message: e.message,
        ),
      );
      return false;
    } catch (e) {
      _log('importCallRecording failed: $e');
      return false;
    }
  }

  /// Clears native pending-call import context.
  Future<void> cancelPendingImport() async {
    if (!isSupported) return;

    try {
      await _channel.invokeMethod<void>('cancelPendingImport');
      _log('Pending import cancelled');
    } on PlatformException catch (e) {
      _log('cancelPendingImport failed: ${e.code} ${e.message}');
    } catch (e) {
      _log('cancelPendingImport failed: $e');
    }
  }

  Future<void> _handleNativeCallback(MethodCall call) async {
    switch (call.method) {
      case 'onCallTrackingStarted':
        final args = _asMap(call.arguments);
        _log(
          'Call started: leadId=${args['leadId']} '
          'phone=${args['phoneNumber']} '
          'at=${args['callStartedAt']}',
        );
      case 'onCallEnded':
        final args = _asMap(call.arguments);
        _log(
          'Call ended: leadId=${args['leadId']} '
          'started=${args['callStartedAt']} '
          'ended=${args['callEndedAt']}',
        );
      case 'onSearchingMediaStore':
        final args = _asMap(call.arguments);
        _log('Searching MediaStore... attempt=${args['attempt']}');
      case 'onRecordingCandidates':
        _logCandidates(_asMap(call.arguments));
      case 'onRecordingFound':
        final result = CallRecordingResult.fromMap(_asMap(call.arguments));
        _logFoundRecording(result);
        _listener?.call(result);
      case 'onRecordingError':
        final result = CallRecordingResult.fromMap(_asMap(call.arguments));
        _logError(result);
        _listener?.call(result);
      case 'onTranscriptionStatus':
        _handleTranscriptionStatus(_asMap(call.arguments));
      case 'onPartialTranscript':
        _handlePartialTranscript(_asMap(call.arguments));
      case 'onFinalTranscript':
        _handleFinalTranscript(_asMap(call.arguments));
      case 'onTranscriptionComplete':
        _handleTranscriptionComplete(_asMap(call.arguments));
      case 'onTranscriptionError':
        _handleTranscriptionError(_asMap(call.arguments));
      default:
        break;
    }
  }

  void _handleTranscriptionStatus(Map<dynamic, dynamic> args) {
    final leadId = (args['leadId'] as num?)?.toInt() ?? 0;
    final statusName = args['status'] as String? ?? '';
    final status = _mapTranscriptionStatus(statusName);
    _log('Transcription status: $statusName');
    _transcriptionListener?.call(
      CallTranscriptionEvent(
        leadId: leadId,
        type: CallTranscriptionEventType.status,
        status: status,
      ),
    );
  }

  void _handlePartialTranscript(Map<dynamic, dynamic> args) {
    final leadId = (args['leadId'] as num?)?.toInt() ?? 0;
    final text = args['text'] as String? ?? '';
    _log('Partial transcript received (${text.length} chars)');
    _transcriptionListener?.call(
      CallTranscriptionEvent(
        leadId: leadId,
        type: CallTranscriptionEventType.partial,
        text: text,
      ),
    );
  }

  void _handleFinalTranscript(Map<dynamic, dynamic> args) {
    final leadId = (args['leadId'] as num?)?.toInt() ?? 0;
    final text = args['text'] as String? ?? '';
    _log('Final transcript segment received');
    _transcriptionListener?.call(
      CallTranscriptionEvent(
        leadId: leadId,
        type: CallTranscriptionEventType.finalSegment,
        text: text,
      ),
    );
  }

  void _handleTranscriptionComplete(Map<dynamic, dynamic> args) {
    final leadId = (args['leadId'] as num?)?.toInt() ?? 0;
    final transcript = args['transcript'] as String? ?? '';
    _log('Transcription complete');
    _transcriptionListener?.call(
      CallTranscriptionEvent(
        leadId: leadId,
        type: CallTranscriptionEventType.complete,
        transcript: transcript,
      ),
    );
  }

  void _handleTranscriptionError(Map<dynamic, dynamic> args) {
    final leadId = (args['leadId'] as num?)?.toInt() ?? 0;
    final code = args['code'] as String?;
    final message = args['message'] as String?;
    _log('Transcription error: $code — $message');
    _transcriptionListener?.call(
      CallTranscriptionEvent(
        leadId: leadId,
        type: CallTranscriptionEventType.error,
        code: code,
        message: message,
      ),
    );
  }

  CallTranscriptionStatus _mapTranscriptionStatus(String value) {
    return switch (value) {
      'preparingAudio' => CallTranscriptionStatus.preparingAudio,
      'awaitingPermission' => CallTranscriptionStatus.awaitingPermission,
      'convertingAudio' => CallTranscriptionStatus.convertingAudio,
      'transcribing' => CallTranscriptionStatus.transcribing,
      _ => CallTranscriptionStatus.idle,
    };
  }

  void _logFoundRecording(CallRecordingResult result) {
    _log('Found recording: ${result.name ?? 'unknown'}');
    _log('Recording URI: ${result.uri}');
    _log('Recording duration: ${result.duration}');
    _log('Recording size: ${result.size}');
    if (result.relativePath != null && result.relativePath!.isNotEmpty) {
      _log('Recording relative path: ${result.relativePath}');
    }
  }

  void _logCandidates(Map<dynamic, dynamic> args) {
    final raw = args['candidates'];
    if (raw is! List) {
      _log('Candidates found: 0');
      return;
    }

    _log('Candidates found: ${raw.length}');
    for (final item in raw) {
      if (item is! Map) continue;
      _log(
        'Candidate: name=${item['name']} uri=${item['uri']} '
        'duration=${item['duration']} dateAdded=${item['dateAdded']} '
        'relativePath=${item['relativePath']} score=${item['score']}',
      );
    }
  }

  void _logError(CallRecordingResult result) {
    if (result.code == 'RECORDING_NOT_FOUND') {
      _log('No recording found.');
      return;
    }
    if (result.code == 'IMPORT_CANCELLED') {
      _log('Import cancelled');
      return;
    }
    _log('Recording error: ${result.code} — ${result.message}');
  }

  Map<dynamic, dynamic> _asMap(dynamic arguments) {
    if (arguments is Map) return arguments;
    return const {};
  }

  void _log(String message) {
    assert(() {
      // ignore: avoid_print
      print('[$_logTag] $message');
      return true;
    }());
  }
}

final callRecordingServiceProvider = Provider<CallRecordingService>((ref) {
  return CallRecordingService();
});
