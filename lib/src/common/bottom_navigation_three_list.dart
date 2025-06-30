import 'package:flutter/material.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/menu/presentation/widgets/menu_screen.dart';
import 'package:famka_app/src/features/calendar/presentation/calendar_screen.dart';
import 'package:famka_app/src/features/appointment/presentation/widgets/appointment1.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:famka_app/src/features/calendar/presentation/event_list_page.dart';

class BottomNavigationThreeList extends StatefulWidget {
  final DatabaseRepository db;
  final AppUser? currentUser;
  final Group? initialGroup;
  final int initialIndex;

  final Color backgroundColor;
  final Color selectedItemColor;
  final Color unselectedItemColor;
  final bool showLabel;

  const BottomNavigationThreeList(
    this.db, {
    super.key,
    this.currentUser,
    this.initialGroup,
    this.initialIndex = 0,
    this.backgroundColor = AppColors.famkaYellow,
    this.selectedItemColor = Colors.black,
    this.unselectedItemColor = Colors.black,
    this.showLabel = true,
  });

  @override
  State<BottomNavigationThreeList> createState() =>
      _BottomNavigationThreeCalendarState();
}

class _BottomNavigationThreeCalendarState
    extends State<BottomNavigationThreeList> {
  int _selectedIndex = 0;
  Group? _currentActiveGroup;
  bool _isLoadingGroup = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _currentActiveGroup = widget.initialGroup;
    _loadActiveGroup();
  }

  @override
  void didUpdateWidget(covariant BottomNavigationThreeList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUser != oldWidget.currentUser ||
        widget.initialGroup != oldWidget.initialGroup) {
      _selectedIndex = widget.initialIndex;
      _currentActiveGroup = widget.initialGroup;
      _loadActiveGroup();
    }
  }

  Future<void> _loadActiveGroup() async {
    setState(() {
      _isLoadingGroup = true;
    });

    if (widget.currentUser == null) {
      if (mounted) {
        setState(() {
          _currentActiveGroup = null;
          _isLoadingGroup = false;
        });
      }
      return;
    }

    try {
      final List<Group> userGroups =
          await widget.db.getGroupsForUser(widget.currentUser!.profilId);

      if (mounted) {
        setState(() {
          if (userGroups.isNotEmpty) {
            final foundInitialGroup = widget.initialGroup != null
                ? userGroups.firstWhere(
                    (g) => g.groupId == widget.initialGroup!.groupId,
                    orElse: () => userGroups.first,
                  )
                : userGroups.first;

            _currentActiveGroup = foundInitialGroup;
          } else {
            _currentActiveGroup = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentActiveGroup = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGroup = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    if (widget.currentUser == null || _currentActiveGroup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.famkaRed,
          content: Text(
            'Fehler: Benutzer- oder Gruppendaten nicht verfügbar.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: '/menuScreen'),
            builder: (context) => MenuScreen(
              widget.db,
              currentGroup: _currentActiveGroup!,
              currentUser: widget.currentUser!,
            ),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            settings: const RouteSettings(name: '/eventListPage'),
            builder: (context) => EventListPage(
              db: widget.db,
              currentGroup: _currentActiveGroup!,
              currentUser: widget.currentUser!,
            ),
          ),
        );
        break;
      case 2:
        _navigateToAppointment();
        break;
    }
  }

  Future<void> _navigateToAppointment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/appointmentScreen'),
        builder: (context) => Appointment(
          widget.db,
          currentUser: widget.currentUser!,
          currentGroup: _currentActiveGroup!,
        ),
      ),
    );

    if (result == true) {
      if (!mounted) return;

      setState(() {
        _selectedIndex = 1;
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: '/calendarScreen'),
          builder: (context) => CalendarScreen(
            widget.db,
            currentGroup: _currentActiveGroup!,
            currentUser: widget.currentUser!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingGroup) {
      return Container(
        height: 90,
        color: widget.backgroundColor,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.famkaCyan,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (widget.currentUser == null || _currentActiveGroup == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 90,
      color: widget.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context,
            icon: Icons.menu,
            label: 'Menü',
            isActive: _selectedIndex == 0,
            onTap: () => _onItemTapped(0),
            selectedItemColor: widget.selectedItemColor,
            unselectedItemColor: widget.unselectedItemColor,
            showLabel: widget.showLabel,
          ),
          _buildNavItem(
            context,
            icon: Icons.list_outlined,
            label: 'Liste',
            isActive: _selectedIndex == 1,
            onTap: () => _onItemTapped(1),
            selectedItemColor: widget.selectedItemColor,
            unselectedItemColor: widget.unselectedItemColor,
            showLabel: widget.showLabel,
          ),
          _buildNavItem(
            context,
            icon: Icons.add_box_outlined,
            label: 'Termin',
            isActive: _selectedIndex == 2,
            onTap: () => _onItemTapped(2),
            selectedItemColor: widget.selectedItemColor,
            unselectedItemColor: widget.unselectedItemColor,
            showLabel: widget.showLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color selectedItemColor,
    required Color unselectedItemColor,
    required bool showLabel,
    bool isActive = false,
  }) {
    final itemColor = isActive ? selectedItemColor : unselectedItemColor;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: itemColor),
          if (showLabel) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(color: itemColor),
            ),
          ],
        ],
      ),
    );
  }
}
