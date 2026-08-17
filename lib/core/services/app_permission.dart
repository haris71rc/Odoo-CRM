import 'package:permission_handler/permission_handler.dart';

/// App permissions requested for CRM call / WhatsApp features.
enum AppPermissionKind {
  contacts(
    title: 'Contacts',
    subtitle: 'Needed for WhatsApp call contact sync',
  ),
  phone(
    title: 'Phone & Call Log',
    subtitle: 'Needed to place calls and save call duration / status',
  ),
  microphone(
    title: 'Microphone',
    subtitle: 'Needed for on-device call recording transcription',
  );

  const AppPermissionKind({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  Permission get permission {
    switch (this) {
      case AppPermissionKind.contacts:
        return Permission.contacts;
      case AppPermissionKind.phone:
        return Permission.phone;
      case AppPermissionKind.microphone:
        return Permission.microphone;
    }
  }
}

/// Snapshot of a single permission for the Profile toggles.
class AppPermissionStatus {
  const AppPermissionStatus({
    required this.kind,
    required this.granted,
    required this.permanentlyDenied,
    required this.supported,
  });

  final AppPermissionKind kind;
  final bool granted;
  final bool permanentlyDenied;
  final bool supported;

  bool get canRequestInApp => supported && !granted && !permanentlyDenied;
}
