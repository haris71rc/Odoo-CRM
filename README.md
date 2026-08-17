## Odoo CRM Flutter App

Production-ready Flutter CRM client for Odoo JSON-RPC with clean architecture.

### Architecture

```
Presentation → Riverpod Notifier → Repository → Datasource → DTO → Mapper → Entity
```

- UI never depends on DTOs, JSON, or Dio
- Repositories return `Result<T>` (`Success` / `Error`)
- Session cookie handled by `CookieInterceptor`

### Stack

Flutter, Riverpod + Generator, GoRouter, Dio, Freezed, Json Serializable, Flutter Hooks, Material 3, url_launcher

### Backend

- Base URL: `https://crmdigi.digilawyer.ai`
- Database: `crmdigi`

### Call recording (Android MVP)

Supported OEMs for native dialer recording detection and on-device transcription:

- Samsung
- OnePlus
- Realme

Requirements:

- Android 12+ (API 31+) for ML Kit speech recognition
- User must press the native dialer **Record** button during the call
- Recordings are discovered via MediaStore (not filesystem paths)

Test on Realme: open a lead → Call → Record in the Realme dialer → end call → verify the **Call Recording** card shows the transcript.

### Run

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Features

- Login via `/web/session/authenticate`
- Leads list with All / Assigned To Me, search, date filter
- Lead detail with call, assign, stage update, remark update, activities
- Analytics placeholder tab
