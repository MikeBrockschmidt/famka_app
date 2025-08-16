import 'package:flutter/material.dart';

/// Mixin für automatisches Unfocus von TextFields bei onTapOutside
mixin TextFieldUnfocusMixin<T extends StatefulWidget> on State<T> {
  /// Standard onTapOutside Handler für alle TextFields
  void unfocusOnTapOutside(PointerDownEvent event) {
    FocusScope.of(context).unfocus();
  }
}

/// Utility-Funktion für einheitliches onTapOutside Verhalten
void handleTapOutside(BuildContext context, PointerDownEvent event) {
  FocusScope.of(context).unfocus();
}
