# FAMKA App Icons - Design Guide & Spezifikationen

## 🎨 App Icon Design Konzept für FAMKA

### Design-Philosophie
- **Familie im Mittelpunkt:** Warme, einladende Farbpalette
- **Modern & Clean:** Minimalistisches Design ohne Überladung
- **Erkennbar:** Auch in kleinen Größen gut lesbar
- **Plattformübergreifend:** Funktioniert auf iOS, Android und Web

## 🎯 Logo-Konzept Vorschlag

### Hauptelement: Stilisiertes "F" + Familiensymbol
```
Design-Idee:
┌─────────────────┐
│  ╭─╮    ╭─╮    │  Familie (4 Kreise)
│ ╱   ╲  ╱   ╲   │  + 
│╱  F  ╲╱  A  ╲  │  FAMKA Typography
│╲_____╱╲_____╱  │
│                │
└─────────────────┘
```

### Farbpalette
```css
Primärfarben:
- Warmblau: #4A90E2 (Vertrauen, Familie)
- Warmgrün: #7ED321 (Wachstum, Harmonie)  
- Warmrot: #D0021B (Liebe, Verbindung)
- Warmorange: #F5A623 (Freude, Energie)

Akzentfarben:
- Dunkelblau: #2C5282 (Text/Kontrast)
- Hellgrau: #F7FAFC (Background)
- Weiß: #FFFFFF (Clean Background)
```

## 📱 Erforderliche Icon-Größen

### iOS App Icons (alle erforderlichen Größen):
```
iPhone App:
- 180x180px (@3x) - iPhone 6 Plus/X/11/12/13/14/15
- 120x120px (@2x) - iPhone 6/7/8/SE
- 60x60px (@1x) - iPhone (Legacy)

iPad App:
- 152x152px (@2x) - iPad Pro/Air/Mini
- 76x76px (@1x) - iPad (Legacy)

App Store:
- 1024x1024px - App Store Connect

Settings/Spotlight:
- 87x87px (@3x) - Settings iPhone
- 58x58px (@2x) - Settings iPhone
- 80x80px (@2x) - Spotlight iPhone
- 40x40px (@1x) - Spotlight iPhone
```

### Android App Icons:
```
Launcher Icons:
- 192x192px (XXXHDPI) - High-end Android
- 144x144px (XXHDPI) - Standard high-res
- 96x96px (XHDPI) - Medium-high res  
- 72x72px (HDPI) - Medium res
- 48x48px (MDPI) - Baseline

Google Play Store:
- 512x512px - Play Store Listing

Adaptive Icons (Android 8+):
- 108x108dp foreground
- 108x108dp background
- 72x72dp safe zone
```

### Web Icons:
```
Favicon:
- 32x32px - Standard Favicon
- 16x16px - Browser Tab

Progressive Web App:
- 192x192px - Android Chrome
- 512x512px - Splash Screen
- 180x180px - iOS Safari
```

## 🛠️ Icon-Generator Tools

### Empfohlene Tools (kostenlos):
1. **App Icon Generator** (appicon.co)
   - Upload 1024x1024px Masterfile
   - Generiert alle iOS/Android Größen automatisch
   
2. **Figma** (figma.com)
   - Professionelle Design-Tools
   - Icon-Templates verfügbar
   - Export in alle Größen

3. **Canva** (canva.com)
   - App Icon Templates
   - Einfache Bedienung
   - Direkter Export

### Flutter Icon-Generator Package:
```yaml
# In pubspec.yaml hinzufügen
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

# Konfiguration
flutter_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icon/famka_icon.png"
  min_sdk_android: 21
  web:
    generate: true
    image_path: "assets/icon/famka_icon.png"
    background_color: "#hexcode"
    theme_color: "#hexcode"
  windows:
    generate: true
    image_path: "assets/icon/famka_icon.png"
    icon_size: 48
```

## 🎨 Design-Spezifikationen erstellt

### Ich erstelle dir ein konkretes Icon-Design:

**FAMKA Logo Konzept:**
```
┌─────────────────────┐
│                     │
│    ┌─┐   ┌─┐       │  
│   ╱   ╲ ╱   ╲      │  Stilisierte Familie
│  │  👨 │ 👩  │     │  (4 Personen/Kreise)
│   ╲___╱ ╲___╱      │  
│     │     │        │
│    ┌─┐   ┌─┐       │
│   ╱   ╲ ╱   ╲      │
│  │ 👧  │ 👦 │     │
│   ╲___╱ ╲___╱      │
│                     │
│      F A M K A      │  Typography unten
│                     │
└─────────────────────┘
```