// lib/src/common/bottom_navigation_three.dart
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart'; // KORREKTUR: Korrekter Import für AppUser
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/menu/presentation/menu.dart'; // KORREKTUR: menu.dart statt menu_screen.dart, da Ihre Klasse 'Menu' heißt
import 'package:flutter/material.dart';
import 'package:famka_app/src/features/calendar/presentation/calendar_screen.dart';
import 'package:famka_app/src/data/auth_repository.dart'; // NEU: AuthRepository muss importiert werden, da es benötigt wird

class BottomNavigationThree extends StatefulWidget {
  final DatabaseRepository db;
  final Group? currentGroup;
  final AppUser? currentUser;
  final AuthRepository auth; // NEU: auth muss übergeben werden

  const BottomNavigationThree(
    this.db, {
    super.key,
    this.currentGroup,
    required this.currentUser,
    required this.auth, // NEU: auth als required Parameter
  });

  @override
  State<BottomNavigationThree> createState() => _BottomNavigationThreeState();
}

class _BottomNavigationThreeState extends State<BottomNavigationThree> {
  int _selectedIndex = 1;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _initializeWidgetOptions();
  }

  @override
  void didUpdateWidget(covariant BottomNavigationThree oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUser != oldWidget.currentUser ||
        widget.currentGroup != oldWidget.currentGroup) {
      _initializeWidgetOptions();
    }
  }

  void _initializeWidgetOptions() {
    if (widget.currentUser == null) {
      _widgetOptions = [
        const Center(child: Text('Fehler: Benutzerdaten fehlen.')),
        const Center(child: Text('Fehler: Benutzerdaten fehlen.')),
        const Center(child: Text('Fehler: Benutzerdaten fehlen.')),
      ];
      return;
    }

    // Sicherstellen, dass currentGroup nicht null ist, bevor es an andere Widgets übergeben wird,
    // die einen nicht-nullbaren Group-Parameter erwarten.
    // Falls currentGroup tatsächlich null sein kann und die Widgets es benötigen,
    // muss die Logik zur Handhabung eines fehlenden currentGroup in den Ziel-Widgets implementiert werden.
    // Für jetzt nehmen wir an, dass es entweder vorhanden ist oder wir einen Fehler anzeigen.
    // Besser wäre es, hier zu prüfen und ggf. eine Ladeanzeige oder Fehlermeldung zu zeigen.
    if (widget.currentGroup == null) {
      _widgetOptions = [
        const Center(child: Text('Fehler: Keine Gruppe ausgewählt.')),
        const Center(child: Text('Fehler: Keine Gruppe ausgewählt.')),
        const Center(child: Text('Fehler: Keine Gruppe ausgewählt.')),
      ];
      return;
    }

    _widgetOptions = <Widget>[
      Menu(
        // KORREKTUR: Klasse heißt 'Menu', nicht 'MenuScreen'
        widget.db,
        currentGroup: widget
            .currentGroup!, // KORREKTUR: ! Operator, da oben auf null geprüft
        currentUser: widget.currentUser!,
        auth: widget.auth, // KORREKTUR: 'auth' Parameter hinzugefügt
      ),
      CalendarScreen(
        widget.db,
        currentGroup: widget
            .currentGroup!, // KORREKTUR: ! Operator, da oben auf null geprüft
        currentUser: widget.currentUser!,
        auth: widget.auth, // KORREKTUR: 'auth' Parameter hinzugefügt
      ),
      Container(
        color: Colors.grey[200],
        child: Center(
          child: Text(
            'Andere Inhalte hier\nBenutzer-ID: ${widget.currentUser!.profilId}',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentUser == null || widget.currentGroup == null) {
      // Prüfen, ob Initialisierung fehlgeschlagen ist
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Oder eine Fehlermeldung
        ),
      );
    }

    // Die _widgetOptions werden in _initializeWidgetOptions gesetzt.
    // Wenn currentUser oder currentGroup null sind, wird _widgetOptions gesetzt
    // und sollte nicht leer sein, es sei denn, _initializeWidgetOptions wird nicht aufgerufen.
    // Die isEmpty Prüfung sollte nach der Initialisierung erfolgen.
    // Die Widgets werden nur geladen, wenn currentUser und currentGroup da sind.

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menü',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Kalender',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Mehr',
          ),
        ],
        currentIndex: _selectedIndex,
        // Hier wurde 'Theme.of(context).primaryColor' verwendet.
        // Falls Sie eine bestimmte Farbe haben möchten:
        selectedItemColor: Colors.blue, // Beispiel: Oder AppColors.famkaBlue
        unselectedItemColor:
            Colors.grey, // Optional: Farbe für nicht ausgewählte Items
        onTap: _onItemTapped,
      ),
    );
  }
}
