# Apple Sign-In Konfiguration für Famka App

## ❌ Problem
Apple Sign-In Fehler: "Ungültige Anmeldedaten. Möglicherweise ein Konfigurationsproblem."

## 📋 Aktuelle App-Konfiguration
- **Bundle ID**: `com.brockschmidt.famka.app`
- **Team ID**: `NT849NJASZ`
- **Display Name**: `Famka App`

## ✅ Apple Developer Console Setup (Erforderlich)

### 1. App ID Konfiguration
1. Gehe zu: https://developer.apple.com/account/resources/identifiers/list
2. Finde App ID: `com.brockschmidt.famka.app`
3. Klicke auf "Edit"
4. Aktiviere "Sign In with Apple" ✅
5. Speichere die Änderungen

### 2. Entitlements Prüfen (✅ Bereits korrekt)
```xml
<key>com.apple.developer.applesignin</key>
<array>
    <string>Default</string>
</array>
```

### 3. Info.plist Prüfen (✅ Bereits korrekt)
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>apple-login</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        </array>
    </dict>
</array>
```

### 4. Provisioning Profile Update
Nach Aktivierung von Apple Sign-In:
1. Erstelle neues Provisioning Profile oder
2. Lade bestehendes Profile neu herunter
3. Installiere in Xcode

## 🔧 Nächste Schritte
1. ✅ Apple Sign-In in App ID aktivieren
2. ✅ Provisioning Profile aktualisieren  
3. ✅ App neu builden und testen
4. ✅ Firebase Console: Apple Sign-In Provider aktivieren (falls nicht bereits geschehen)

## 🧪 Test nach Konfiguration
Nach der Apple Developer Console Konfiguration sollte Apple Sign-In funktionieren.