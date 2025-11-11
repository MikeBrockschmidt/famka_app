import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/calendar_cell_icon.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/calendar_avatar_scroll_row.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/event_icon_widget.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/data/auth_repository.dart';

class CalendarGrid extends StatefulWidget {
  final DatabaseRepository db;
  final AuthRepository auth;
  final Group? currentGroup;
  final AppUser? currentUser;
  final List<SingleEvent> allEvents;
  final Function(String eventId)? onEventDeletedConfirmed;
  final Function()? onEventsRefreshed;
  final DateTimeRange? selectedDateRange;
  final Color? selectedRangeColor;
  final List<String>? selectedMemberIds;

  const CalendarGrid(
    this.db, {
    required this.auth,
    super.key,
    this.currentGroup,
    this.currentUser,
    required this.allEvents,
    this.onEventDeletedConfirmed,
    this.onEventsRefreshed,
    this.selectedDateRange,
    this.selectedRangeColor,
    this.selectedMemberIds,
  });

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  // Removed unused _getCellBackground method
  final double sideColumnWidth = 63;
  final double rowHeight = 80;
  final double personColumnWidth = 90;

  final DateTime currentDate = DateTime.now();

  // Limit backward viewing to 180 days (6 months) instead of 14 days
  static const int _daysBack = 180;
  static const int _monthsForward = 6;

  late final DateTime _actualStartDate;
  late int _totalDisplayDays;

  final ScrollController _leftColumnVerticalScrollController =
      ScrollController();
  final ScrollController _gridVerticalScrollController = ScrollController();

  final ScrollController _avatarHorizontalScrollController = ScrollController();
  final ScrollController _gridHorizontalScrollController = ScrollController();

  DateTime currentTopDate = DateTime.now();

  late Future<List<AppUser>> _groupMembersFuture;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('de_DE', null);

    _actualStartDate = currentDate.subtract(const Duration(days: _daysBack));

    final DateTime actualEndDate = DateTime(
      currentDate.year,
      currentDate.month + _monthsForward,
      currentDate.day,
    );

    _totalDisplayDays = actualEndDate.difference(_actualStartDate).inDays;

    if (_totalDisplayDays < 1) {
      _totalDisplayDays = 1;
    }

    _loadGroupMembers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.currentUser != null) {
        final double screenHeight = MediaQuery.of(context).size.height;
        final double maxScrollExtentLimit = screenHeight - 94 - 40;

        Future.delayed(const Duration(milliseconds: 50), () {
          if (_leftColumnVerticalScrollController.hasClients && mounted) {
            final initialDayOffset =
                currentDate.difference(_actualStartDate).inDays;
            final initialScrollOffset = initialDayOffset * rowHeight;
            final maxScrollExtent =
                (_totalDisplayDays * rowHeight) - maxScrollExtentLimit;
            final clampedInitialOffset = initialScrollOffset.clamp(
                0.0, maxScrollExtent < 0 ? 0.0 : maxScrollExtent);
            _leftColumnVerticalScrollController.jumpTo(clampedInitialOffset);
          }
        });
      }
    });

    _leftColumnVerticalScrollController.addListener(() {
      final scrollOffset = _leftColumnVerticalScrollController.offset;
      final visibleIndex = (scrollOffset / rowHeight).floor();
      final dateAtTop = _actualStartDate.add(Duration(days: visibleIndex));

      if (dateAtTop.month != currentTopDate.month ||
          dateAtTop.year != currentTopDate.year) {
        setState(() {
          currentTopDate = dateAtTop;
        });
      }

      if (_gridVerticalScrollController.hasClients &&
          _gridVerticalScrollController.offset != scrollOffset) {
        _gridVerticalScrollController.jumpTo(scrollOffset);
      }
    });

    _gridHorizontalScrollController.addListener(() {
      if (_avatarHorizontalScrollController.hasClients) {
        if (_avatarHorizontalScrollController.offset !=
            _gridHorizontalScrollController.offset) {
          _avatarHorizontalScrollController
              .jumpTo(_gridHorizontalScrollController.offset);
        }
      }
    });

    _gridVerticalScrollController.addListener(() {
      final scrollOffset = _gridVerticalScrollController.offset;
      if (_leftColumnVerticalScrollController.hasClients &&
          _leftColumnVerticalScrollController.offset != scrollOffset) {
        _leftColumnVerticalScrollController.jumpTo(scrollOffset);
      }
    });
  }

  void _loadGroupMembers() {
    if (widget.currentGroup != null) {
      _groupMembersFuture = Future.value(widget.currentGroup!.groupMembers);
    } else {
      _groupMembersFuture =
          widget.db.getGroupMembers('your_default_group_id_here');
    }
  }

  @override
  void didUpdateWidget(covariant CalendarGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentGroup?.groupId != oldWidget.currentGroup?.groupId) {
      _loadGroupMembers();
    }
  }

  void scrollToMonth(DateTime targetDate) {
    final dayOffset = targetDate.difference(_actualStartDate).inDays;
    final scrollOffset = dayOffset * rowHeight;
    if (!mounted) return;

    final double screenHeight = MediaQuery.of(context).size.height;
    final double maxScrollExtentLimit = screenHeight - 94 - 40;

    final maxScrollExtent =
        (_totalDisplayDays * rowHeight) - maxScrollExtentLimit;
    final clampedOffset =
        scrollOffset.clamp(0.0, maxScrollExtent < 0 ? 0.0 : maxScrollExtent);

    _leftColumnVerticalScrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  // Interaktive Monatsauswahl
  void _showMonthPicker(BuildContext context) async {
    final locale = Localizations.localeOf(context).toString();
    
    // Erstelle eine Liste von Monaten (3 Monate zurück bis 18 Monate voraus)
    final List<DateTime> months = [];
    final DateTime startMonth = DateTime(currentDate.year, currentDate.month - 3, 1);
    
    for (int i = 0; i < 22; i++) { // 3 + 1 + 18 = 22 Monate total
      final month = DateTime(startMonth.year, startMonth.month + i, 1);
      months.add(month);
    }

    final DateTime? selectedMonth = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Titel
              Text(
                AppLocalizations.of(context)?.calendarTitle ?? 'Monat wählen',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              // Monatsliste
              Expanded(
                child: ListView.builder(
                  itemCount: months.length,
                  itemBuilder: (context, index) {
                    final month = months[index];
                    final monthText = DateFormat('MMMM yyyy', locale).format(month);
                    final isCurrentMonth = month.month == currentTopDate.month && 
                                         month.year == currentTopDate.year;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isCurrentMonth ? Colors.blueAccent.withOpacity(0.1) : null,
                        borderRadius: BorderRadius.circular(12),
                        border: isCurrentMonth ? Border.all(color: Colors.blueAccent, width: 2) : null,
                      ),
                      child: ListTile(
                        title: Text(
                          monthText,
                          style: TextStyle(
                            fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
                            color: isCurrentMonth ? Colors.blueAccent : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        leading: Icon(
                          Icons.calendar_month,
                          color: isCurrentMonth ? Colors.blueAccent : Colors.grey,
                        ),
                        trailing: isCurrentMonth 
                          ? const Icon(Icons.check, color: Colors.blueAccent)
                          : null,
                        onTap: () {
                          Navigator.pop(context, month);
                        },
                      ),
                    );
                  },
                ),
              ),
              // Abbrechen Button
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Abbrechen', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // Wenn ein Monat ausgewählt wurde, scrolle zu diesem Monat
    if (selectedMonth != null && mounted) {
      setState(() {
        currentTopDate = selectedMonth;
      });
      scrollToMonth(selectedMonth);
    }
  }

  @override
  void dispose() {
    _leftColumnVerticalScrollController.dispose();
    _gridVerticalScrollController.dispose();
    _avatarHorizontalScrollController.dispose();
    _gridHorizontalScrollController.dispose();
    super.dispose();
  }

  Widget _buildEventContent(String? eventUrl, String eventName, double size) {
    return EventIconWidget(
      eventUrl: eventUrl,
      eventName: eventName,
      size: size,
      db: widget.db,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final monthName =
        DateFormat('MMMM y', locale).format(currentTopDate).toUpperCase();

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Divider(height: 0.4, thickness: 0.4, color: Colors.grey),
          FutureBuilder<List<AppUser>>(
            future: _groupMembersFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox(height: 94);
              }

              final List<AppUser> currentGroupMembers = snapshot.data!;
              return Row(
                children: [
                  Container(
                      width: sideColumnWidth,
                      height: 94,
                      color: AppColors.famkaYellow),
                  Expanded(
                    child: CalendarAvatarScrollRow(
                      widget.db,
                      auth: widget.auth,
                      horizontalScrollControllerTop:
                          _avatarHorizontalScrollController,
                      groupMembers: currentGroupMembers,
                      currentGroup: widget.currentGroup,
                      personColumnWidth: personColumnWidth,
                      scrollPhysics: const NeverScrollableScrollPhysics(),
                    ),
                  ),
                ],
              );
            },
          ),
          Container(
            width: double.infinity,
            height: 40,
            color: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Interaktive Monatsauswahl
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showMonthPicker(context),
                    child: Row(
                      children: [
                        Text(
                          monthName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: 'Aktualisieren',
                  onPressed: widget.onEventsRefreshed,
                  color: Colors.white,
                  iconSize: 20,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AppUser>>(
              future: _groupMembersFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child:
                          Text(AppLocalizations.of(context)!.noMembersFound));
                }

                final List<AppUser> currentGroupMembers = snapshot.data!;
                final int actualNumberOfPersons = currentGroupMembers.length;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: sideColumnWidth,
                      child: ListView.builder(
                        controller: _leftColumnVerticalScrollController,
                        itemCount: _totalDisplayDays,
                        itemExtent: rowHeight,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final date =
                              _actualStartDate.add(Duration(days: index));
                          final dayText =
                              DateFormat('dd. EEE', locale).format(date);
                          final dayParts = dayText.split('.');
                          final datePart = dayParts[0];
                          final weekDayPart = dayParts[1].trim().toUpperCase();

                          return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                                right: const BorderSide(
                                    color: Colors.black, width: 2),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  datePart,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                Text(
                                  weekDayPart,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _gridHorizontalScrollController,
                        physics: const ClampingScrollPhysics(),
                        child: SizedBox(
                          width: actualNumberOfPersons * personColumnWidth,
                          child: ListView.builder(
                            controller: _gridVerticalScrollController,
                            itemCount: _totalDisplayDays,
                            itemExtent: rowHeight,
                            physics: const ClampingScrollPhysics(),
                            itemBuilder: (context, dayIndex) {
                              final date = _actualStartDate
                                  .add(Duration(days: dayIndex));
                              final isWeekend =
                                  date.weekday == DateTime.saturday ||
                                      date.weekday == DateTime.sunday;
                              return Row(
                                children: List.generate(actualNumberOfPersons,
                                    (personIndex) {
                                  final users = currentGroupMembers;
                                  final userId = users[personIndex].profilId;
                                  // Bereichs-Termine aus Events prüfen
                                  Color? rangeColor;
                                  for (final event in widget.allEvents) {
                                    if (event.selectedDateRange != null &&
                                        event.selectedMemberIds != null &&
                                        event.selectedMemberIds!
                                            .contains(userId) &&
                                        !date.isBefore(
                                            event.selectedDateRange!.start) &&
                                        !date.isAfter(
                                            event.selectedDateRange!.end)) {
                                      if (event.selectedRangeColorValue !=
                                          null) {
                                        rangeColor = Color(
                                                event.selectedRangeColorValue!)
                                            .withOpacity(0.1);
                                      } else {
                                        rangeColor =
                                            Colors.blueAccent.withOpacity(0.1);
                                      }
                                      break;
                                    }
                                  }
                                  final isSelectedMember = widget
                                          .selectedMemberIds
                                          ?.contains(userId) ??
                                      false;
                                  final isInSelectedRange = widget
                                              .selectedDateRange !=
                                          null &&
                                      !date.isBefore(
                                          widget.selectedDateRange!.start) &&
                                      !date.isAfter(
                                          widget.selectedDateRange!.end);
                                  final cellColor = rangeColor ??
                                      ((isSelectedMember &&
                                              isInSelectedRange &&
                                              widget.selectedRangeColor != null)
                                          ? widget.selectedRangeColor!
                                              .withOpacity(0.1)
                                          : (isWeekend
                                              ? Colors.grey.shade100
                                              : Colors.white));
                                  return GestureDetector(
                                    onTap: () async {
                                      // ...existing tap logic...
                                    },
                                    child: Container(
                                      width: personColumnWidth,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: cellColor,
                                        border: Border(
                                          right: BorderSide(
                                              color: Colors.grey.shade300),
                                          bottom: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                      child: CalendarCellIcon(
                                        date: date,
                                        user: currentGroupMembers[personIndex],
                                        db: widget.db,
                                        buildEventContent: _buildEventContent,
                                        allEvents: widget.allEvents,
                                        currentGroupMembers:
                                            currentGroupMembers,
                                        onEventsRefreshed:
                                            widget.onEventsRefreshed,
                                        onEventDeletedConfirmed:
                                            widget.onEventDeletedConfirmed,
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Die neue CalendarCellIcon-Definition ist jetzt in calendar_cell_icon.dart
