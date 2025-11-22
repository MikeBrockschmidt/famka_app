# 👨‍👩‍👧‍👦 FAMKA - Familienkalender & Chat App

[![Flutter](https://img.shields.io/badge/Flutter-2.0.0-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Integrated-orange.svg)](https://firebase.google.com/)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey.svg)](https://flutter.dev/multi-platform)

**PREMIUM FAMILIENAPP** - Eine werbefreie, sichere Familien-App, die Kalender, Chat und Fotogalerie in einer professionellen Oberfläche vereint. Entwickelt exklusiv für Familien, die Wert auf Privatsphäre und Qualität legen.

## 🌟 Features

### 🗓️ Gemeinsamer Familienkalender
- Terminverwaltung für die ganze Familie
- Echtzeit-Synchronisation zwischen allen Geräten
- Kategorien für Arbeit, Schule, Freizeit
- Push-Benachrichtigungen für wichtige Termine

### 👥 Familiengruppen & Chat
- Private Familiengruppen erstellen
- Sichere, verschlüsselte Kommunikation
- Nachrichten, Fotos und Informationen teilen
- Gruppenchats für verschiedene Familienzweige

### 📸 Private Fotogalerie
- Sichere Fotofreigabe innerhalb der Familie
- Organisation nach Events und Zeiträumen
- Hochauflösende Bildqualität
- Cloud-Speicherung mit automatischer Synchronisation

### 🔐 Sicherheit & Datenschutz
- Ende-zu-Ende-Verschlüsselung
- DSGVO-konforme Datenspeicherung
- **100% werbefrei** - keine Tracking-Partner
- **Premium-Qualität** ohne versteckte Kosten

### 💎 Premium-Features
- **Unbegrenzte Familienmitglieder** in Gruppen
- **Vollständige Kalenderfunktionen** mit Zeitraum-Bearbeitung
- **Hochauflösende Fotogalerie** ohne Speicherlimits
- **Priority Support** bei Fragen und Problemen
- Keine Werbung, kein Datenverkauf
- Sichere Authentifizierung (Google, Apple, E-Mail)

## 🚀 Technologie-Stack

- **Framework:** Flutter 3.x
- **Backend:** Firebase (Firestore, Auth, Storage, Hosting)
- **Plattformen:** iOS, Android, Web
- **Internationalisierung:** Deutsch, Englisch
- **Authentifizierung:** Firebase Auth, Google Sign-In, Apple Sign-In
- **State Management:** Provider Pattern
- **Cloud Storage:** Firebase Storage

## 📱 Installation

### Entwicklungsumgebung einrichten

```bash
# Repository klonen
git clone https://github.com/MikeBrockschmidt/famka_app.git
cd famka_app

# Dependencies installieren
flutter pub get

# Firebase konfigurieren
flutterfire configure --project=famka-app-free-storage
```

### App ausführen

```bash
# Debug-Modus (alle Plattformen)
flutter run

# Spezifische Plattform
flutter run -d chrome     # Web
flutter run -d ios        # iOS Simulator
flutter run -d android    # Android Emulator
```

### Release Builds

```bash
# Android APK
flutter build apk --release

# iOS (benötigt Xcode)
flutter build ios --release

# Web
flutter build web --release
```

## 🌐 Live Demo

Die Web-Version ist verfügbar unter: [https://famka.web.app](https://famka.web.app)

## 📋 Projektstruktur

```
lib/
├── main.dart                    # App-Einstiegspunkt
├── firebase_options.dart       # Firebase-Konfiguration
├── src/
│   ├── data/                   # Datenquellen & Repositories
│   │   ├── firestore_repository.dart
│   │   └── firebase_auth_repository.dart
│   ├── features/               # Feature-Module
│   │   ├── login/             # Authentifizierung
│   │   ├── calendar/          # Kalender-Funktionalität
│   │   ├── chat/              # Chat-System
│   │   ├── gallery/           # Fotogalerie
│   │   └── profile/           # Benutzerprofil
│   ├── shared/                # Geteilte Komponenten
│   │   ├── widgets/           # UI-Komponenten
│   │   └── utils/             # Hilfsfunktionen
│   └── l10n/                  # Internationalisierung
├── gen_l10n/                  # Generierte Lokalisierungen
└── assets/                    # Statische Ressourcen
```

## 🔧 Konfiguration

### Firebase Setup

1. Firebase-Projekt erstellen: [Firebase Console](https://console.firebase.google.com/)
2. Plattformen hinzufügen (iOS, Android, Web)
3. Konfigurationsdateien herunterladen:
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
   - Android: `google-services.json` → `android/app/`
   - Web: Automatisch über `flutterfire configure`

### Umgebungsvariablen

```bash
# .env (optional für zusätzliche Konfiguration)
FIREBASE_PROJECT_ID=famka-app-free-storage
FIREBASE_STORAGE_BUCKET=famka-app-free-storage.appspot.com
```

## 🧪 Testing

```bash
# Unit Tests ausführen
flutter test

# Integration Tests
flutter test integration_test/

# Widget Tests
flutter test test/widget_test.dart
```

## 🚀 Deployment

### Web (Firebase Hosting)

```bash
# Build erstellen
flutter build web --release

# Deploy zu Firebase
firebase deploy --only hosting
```

### Mobile App Stores

1. **iOS App Store:**
   - Xcode öffnen: `open ios/Runner.xcworkspace`
   - Archive erstellen und zu App Store Connect hochladen

2. **Google Play Store:**
   - AAB erstellen: `flutter build appbundle --release`
   - Upload über Google Play Console

## 📄 Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe [LICENSE](LICENSE) Datei für Details.

## 👨‍💻 Entwickler

**Mike Brockschmidt**
- GitHub: [@MikeBrockschmidt](https://github.com/MikeBrockschmidt)
- Email: [support@famka.app](mailto:support@famka.app)

## 🤝 Mitwirken

Beiträge sind willkommen! Bitte lies die [CONTRIBUTING.md](CONTRIBUTING.md) für Details zum Entwicklungsprozess.

1. Fork das Repository
2. Erstelle einen Feature-Branch (`git checkout -b feature/AmazingFeature`)
3. Committe deine Änderungen (`git commit -m 'Add some AmazingFeature'`)
4. Push zum Branch (`git push origin feature/AmazingFeature`)
5. Erstelle einen Pull Request

## 📊 Roadmap

- [ ] Push-Benachrichtigungen für Termine
- [ ] Offline-Modus mit lokaler Synchronisation
- [ ] Erweiterte Kalender-Integration (Google Calendar, iCal)
- [ ] Video-Chat Integration
- [ ] Erweiterte Foto-Organisationsfeatures
- [ ] Multi-Sprach-Support (Französisch, Spanisch)
- [ ] Desktop-Apps (Windows, macOS, Linux)

## 📞 Support

Bei Fragen oder Problemen:

- **GitHub Issues:** [Erstelle ein Issue](https://github.com/MikeBrockschmidt/famka_app/issues)
- **Email:** support@famka.app
- **Website:** [famka.web.app](https://famka.web.app)

## 🙏 Danksagungen

- Flutter Team für das großartige Framework
- Firebase Team für die Backend-Services
- Open Source Community für die verwendeten Packages

---

**Made with ❤️ für Familien weltweit**
