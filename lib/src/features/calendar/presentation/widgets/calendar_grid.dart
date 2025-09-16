import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/calendar_cell_icon.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/calendar_avatar_scroll_row.dart';
import 'package:famka_app/src/features/gallery/presentation/widgets/event_image.dart';
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

  // Limit backward viewing to approximately 14 days instead of 6 months
  static const int _daysBack = 14;
  static const int _monthsForward = 14;

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

    _actualStartDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day - _daysBack,
    );

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

  @override
  void dispose() {
    _leftColumnVerticalScrollController.dispose();
    _gridVerticalScrollController.dispose();
    _avatarHorizontalScrollController.dispose();
    _gridHorizontalScrollController.dispose();
    super.dispose();
  }

  Widget _buildEventContent(String? eventUrl, String eventName, double size) {
    if (eventUrl == null || eventUrl.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey.shade200,
        child: Text(
          eventName.isNotEmpty ? eventName[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: size * 0.5,
            color: AppColors.famkaBlack,
          ),
        ),
      );
    }

    if (eventUrl.startsWith('emoji:')) {
      final emoji = eventUrl.substring(6);
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          emoji,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size,
          ),
        ),
      );
    } else if (eventUrl.startsWith('icon:')) {
      final iconCodePoint = int.tryParse(eventUrl.substring(5));
      if (iconCodePoint != null) {
        return Icon(
          Icons.category, // Use constant icon
          size: size * 0.9,
          color: AppColors.famkaBlack,
        );
      }
    } else if (eventUrl.startsWith('image:')) {
      final imageUrl = eventUrl.substring(6);
      if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.contain,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image,
                size: size * 0.7, color: Colors.red);
          },
        );
      } else {
        return Image.asset(
          imageUrl,
          fit: BoxFit.contain,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image,
                size: size * 0.7, color: Colors.red);
          },
        );
      }
    }

    return EventImage(
      widget.db,
      currentAvatarUrl: eventUrl,
      displayRadius: size / 2,
      applyTransformOffset: false,
      isInteractive: false,
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
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              monthName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
                                  final cellColor = (isSelectedMember &&
                                          isInSelectedRange &&
                                          widget.selectedRangeColor != null)
                                      ? widget.selectedRangeColor!
                                          .withOpacity(0.1)
                                      : (isWeekend
                                          ? Colors.grey.shade100
                                          : Colors.white);
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
