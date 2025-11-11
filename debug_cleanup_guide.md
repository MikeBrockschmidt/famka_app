# Debug Print Cleanup für Release

## Option 1: Globaler Find/Replace (Empfohlen für Release)

### In VS Code:
1. **Cmd+Shift+F** (Find & Replace in gesamtem Projekt)
2. **Suchen:** `print\('.*'\);`
3. **Regex aktivieren** (.*-Symbol)
4. **Ersetzen:** `// print('...');` (auskommentieren)
5. **Replace All**

### Terminal (automatisch):
```bash
# Alle print-Statements auskommentieren
find lib -name "*.dart" -exec sed -i '' 's/^[[:space:]]*print(/\/\/ print(/g' {} +

# Oder komplett entfernen (radikaler):
find lib -name "*.dart" -exec sed -i '' '/^[[:space:]]*print(/d' {} +
```

## Option 2: Conditional Debugging

### Erstelle debug_utils.dart:
```dart
// lib/src/utils/debug_utils.dart
import 'package:flutter/foundation.dart';

void debugPrint(String message) {
  if (kDebugMode) {
    print(message);
  }
}
```

### Dann replace:
```
Suchen: print(
Ersetzen: debugPrint(
```

## Option 3: Logger Package (Professionell)

### pubspec.yaml:
```yaml
dependencies:
  logger: ^2.0.1
```

### Verwendung:
```dart
import 'package:logger/logger.dart';

final logger = Logger();

// Statt print():
logger.d('Debug message');  // Nur im Debug-Modus
logger.i('Info message');
logger.w('Warning message');
logger.e('Error message');
```

## Release-Build Test:
```bash
# Teste ob Debug-Prints in Release ausgeschaltet sind:
flutter build apk --release
flutter build ios --release --no-codesign
flutter build web --release
```

Die Debug-Prints sind hauptsächlich kosmetisch - deine App funktioniert vollständig auch mit ihnen!