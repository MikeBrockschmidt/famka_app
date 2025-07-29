import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/menu/presentation/menu.dart';
import 'package:flutter/material.dart';
import 'package:famka_app/src/features/calendar/presentation/calendar_screen.dart';
import 'package:famka_app/src/data/auth_repository.dart';

class BottomNavigationThree extends StatefulWidget {
  final DatabaseRepository db;
  final Group? currentGroup;
  final AppUser? currentUser;
  final AuthRepository auth;

  const BottomNavigationThree(
    this.db, {
    super.key,
    this.currentGroup,
    required this.currentUser,
    required this.auth,
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
        widget.db,
        currentGroup: widget.currentGroup!,
        currentUser: widget.currentUser!,
        auth: widget.auth,
      ),
      CalendarScreen(
        widget.db,
        currentGroup: widget.currentGroup!,
        currentUser: widget.currentUser!,
        auth: widget.auth,
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
