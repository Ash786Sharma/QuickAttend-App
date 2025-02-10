# 📌 QuickAttend - A Quick Attendance

## QuickAttend Flutter App Documentation

## 📌 Project Overview

QuickAttend is a Flutter-based mobile application designed for employee attendance management with features like biometric authentication, daily reminder notifications, and report generation.

---

It integrates **Flutter, Socket.IO and Node.js (backend)**.

## 📂 Folder Structure

```json
/flutter-app
│── android/                # Android App Platform Files
│── ios/                    # Ios App Platform Files
│── web/                    # Web App Platform Files
│── lib/                    # Flutter App files
│   ├── main.dart           # Entry point of the Flutter app
│   ├── routes.dart         # Handles app navigation
│   ├── screens/            # Contains UI screens
│   ├── services/           # Handles API calls & database operations
│   ├── utils/              # Helper functions and constants
│   ├── widgets/            # Reusable UI components
|   ├── Assets              # Images, icons and fonts
│── pubspec.yaml            # Project dependencies & metadata
│── test/                   # Unit and widget tests
```

## 📜 Main Files & Purpose

- **`main.dart`** → Initializes the app, loads providers, and handles themes.
- **`pubspec.yaml`** → Lists dependencies and assets.
- **`routes.dart`** → Defines named routes for navigation.
- **`screens/`** → Contains UI screens like login, home, and attendance.
- **`services/`** → HTTPS, SOCKET.IO API calls to the backend for authentication, attendance, and Local notifications Service.
- **`utils/`** → Helper functions, constants, and theme styles settings.
- **`widgets/`** → Reusable UI components like buttons and text fields.
- **`Assets/icon`** → Assets like Launcher & Notification Icons (images).
- **`android`** → Android platform files like build.gradle, MainActivity.kt, AndroidManifest.xml, proguard-rules.pro, res/Drawables & mipmap etc.
- **`ios`** → Ios platform files.
- **`web`** → Web App platform files.

## 🔗 Dependencies (from `pubspec.yaml`)

These are the Flutter packages used in the project:

### Core Dependencies

| Package             | Description                              |
|--------------------|----------------------------------|
| `http` | HTTP client for API calls |
| `flutter_local_notifications` | Push notifications |
| `flutter_timezone`, `timezone`, `flutter_native_timezone` | Time zone management |
| `intl` | Date & time formatting |
| `local_auth` | Biometric authentication |
| `shared_preferences` & `flutter_secure_storage` | Data storage |
| `socket_io_client` | Real-time communication |
| `path_provider` | File system paths |
| `permission_handler` | Managing app permissions |
| `jwt_decoder` | Decoding JWT tokens |
| `table_calendar` | Calendar UI |

### Dev Dependencies

| Package             | Description                              |
|--------------------|----------------------------------|
| `flutter_launcher_icons` | Custom app icons |
| `android_notification_icons` | Custom Android notification icons |
| `flutter_lints` | Best practices & linting |

## 🔀 Navigation & Routing

The app uses **Navigator 2.0** with **named routes** (`Navigator.push`). Example:

```dart
Navigator.pushNamed(context, '/attendance');
```

## 📡 API Integration

The app communicates with the **Node.js backend** via REST APIs & Socket.IO. Example:

```dart
// Login user
final response = await ApiService().post(
  'http://localhost:5000/api/auth/login',
  data: {'employeeId': 'EMP123'}
);
```

```dart
// Listen for calendar updates
SocketService().on('refresh_calendar', (_) {
  _fetchCalendarSettings();
});
```
