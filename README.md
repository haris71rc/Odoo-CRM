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
