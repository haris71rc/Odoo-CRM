import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odoocrm/core/services/call_recording_service.dart';
import 'package:odoocrm/features/call_log/presentation/providers/call_transcription_notifier.dart';
import 'package:odoocrm/router/app_router.dart';

final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// App-level listener for native recording detection, import, and share events.
///
/// Kept out of Lead Detail so ACTION_SEND can be handled from any screen.
final callRecordingCoordinatorProvider = Provider<void>((ref) {
  final service = ref.watch(callRecordingServiceProvider);
  if (!service.isSupported) return;

  service.setListener((result) {
    _handleRecordingResult(ref, result);
  });

  ref.onDispose(() {
    service.setListener(null);
  });
});

void _handleRecordingResult(Ref ref, CallRecordingResult result) {
  final leadId = result.leadId;

  if (!result.success) {
    _handleError(ref, result);
    return;
  }

  if (leadId <= 0 || result.uri == null) return;

  ref.read(callTranscriptionNotifierProvider(leadId).notifier).onRecordingFound(result);
  _openLead(ref, leadId);
  _showMessage(_successMessage(result.source));
}

void _handleError(Ref ref, CallRecordingResult result) {
  final code = result.code;
  final leadId = result.leadId;
  final message = result.message;

  if (code == 'NO_PENDING_LEAD' || (leadId <= 0 && code != 'RECORDING_NOT_FOUND')) {
    _showMessage(
      message ??
          'Please open a lead and start the call from the CRM before importing a recording.',
    );
    return;
  }

  if (code == 'MULTIPLE_FILES_SELECTED') {
    _showMessage('Please share one call recording at a time.');
    if (leadId > 0) {
      ref.read(callTranscriptionNotifierProvider(leadId).notifier).onRecordingError(
            code: code!,
            message: message,
          );
    }
    return;
  }

  if (leadId <= 0) {
    if (message != null && message.isNotEmpty) {
      _showMessage(message);
    }
    return;
  }

  ref.read(callTranscriptionNotifierProvider(leadId).notifier).onRecordingError(
        code: code ?? 'RECORDING_ERROR',
        message: message,
      );

  if (code == 'RECORDING_NOT_FOUND') {
    _openLead(ref, leadId);
  }
}

String _successMessage(String? source) {
  return switch (source) {
    'share' => 'Call recording received.',
    'import' => 'Recording imported',
    _ => 'Recording detected',
  };
}

void _openLead(Ref ref, int leadId) {
  final router = ref.read(appRouterProvider);
  final path = router.routerDelegate.currentConfiguration.uri.path;
  if (path == '/leads/$leadId') return;
  router.push('/leads/$leadId');
}

void _showMessage(String message) {
  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
