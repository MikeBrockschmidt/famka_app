import 'package:famka_app/gen_l10n/app_localizations.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/info_bottom_sheet.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/calendar_avatar_scroll_row.dart';
import 'package:famka_app/src/features/gallery/presentation/widgets/event_image.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';

class CalendarGrid extends StatefulWidget {
  final DatabaseRepository db;
  final Group? currentGroup;
  final AppUser? currentUser;
  final List<SingleEvent> allEvents;
  final Function(String eventId)? onEventDeletedConfirmed;
  final Function()? onEventsRefreshed;

  const CalendarGrid(
    this.db, {
    super.key,
    this.currentGroup,
    this.currentUser,
    required this.allEvents,
    this.onEventDeletedConfirmed,
    this.onEventsRefreshed,
  });

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
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
          IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
          size: size * 0.9,
          color: AppColors.famkaBlack,
        );
      }
    } else if (eventUrl.startsWith('image:')) {
      final imageUrl = eventUrl.substring(6);
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        width: size,
        height: size,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.broken_image, size: size * 0.7, color: Colors.red);
        },
      );
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
    final monthName =
        DateFormat('MMMM y', 'de_DE').format(currentTopDate).toUpperCase();

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
                      horizontalScrollControllerTop:
                          _avatarHorizontalScrollController,
                      groupMembers: currentGroupMembers,
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
                              DateFormat('dd. EEE', 'de_DE').format(date);
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
                                Text(datePart,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium),
                                Text(weekDayPart,
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
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
                                  return GestureDetector(
                                    onTap: () async {
                                      final DateTime cutoffDate = DateTime.now()
                                          .subtract(const Duration(days: 14));
                                      final bool isWithinRange = date
                                              .isAfter(cutoffDate) ||
                                          date.isAtSameMomentAs(cutoffDate) ||
                                          date.isAfter(DateTime.now());

                                      if (!isWithinRange) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(AppLocalizations.of(
                                                        context)
                                                    ?.oldEventsFoundMessage(
                                                        1) ??
                                                "Events older than 14 days are hidden. Check the calendar screen to manage old events."),
                                          ),
                                        );
                                        return;
                                      }

                                      final users = currentGroupMembers;
                                      final userId =
                                          users[personIndex].profilId;
                                      final userName =
                                          users[personIndex].firstName;

                                      final eventsForPerson =
                                          widget.allEvents.where((event) {
                                        final sameDay =
                                            event.singleEventDate.year ==
                                                    date.year &&
                                                event.singleEventDate.month ==
                                                    date.month &&
                                                event.singleEventDate.day ==
                                                    date.day;
                                        return sameDay &&
                                            (event.acceptedMemberIds
                                                    .contains(userId) ||
                                                event.invitedMemberIds
                                                    .contains(userId) ||
                                                event.maybeMemberIds
                                                    .contains(userId));
                                      }).toList();

                                      final BuildContext currentTapContext =
                                          context;

                                      final bool? eventWasDeleted =
                                          await showModalBottomSheet<bool>(
                                        context: currentTapContext,
                                        isScrollControlled: true,
                                        builder: (context) {
                                          return InfoBottomSheet(
                                            date: date,
                                            userName: userName,
                                            eventsForPerson: eventsForPerson,
                                            currentGroupMembers:
                                                currentGroupMembers,
                                            db: widget.db,
                                            onEventDeleted:
                                                (String deletedEventId) {
                                              widget.onEventDeletedConfirmed
                                                  ?.call(deletedEventId);
                                            },
                                            onEventUpdated: (updatedEvent) {
                                              widget.onEventsRefreshed?.call();
                                            },
                                          );
                                        },
                                      );

                                      if (eventWasDeleted == true) {
                                        debugPrint(
                                            'Event was deleted via InfoBottomSheet, CalendarScreen will refresh.');
                                        widget.onEventsRefreshed?.call();
                                      }
                                    },
                                    child: Container(
                                      width: personColumnWidth,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isWeekend
                                            ? Colors.grey.shade100
                                            : Colors.white,
                                        border: Border(
                                          right: BorderSide(
                                              color: Colors.grey.shade300),
                                          bottom: BorderSide(
                                              color: Colors.grey.shade300),
                                        ),
                                      ),
                                      child: CalendarCellIcon(
                                        date: date,
                                        personIndex: personIndex,
                                        db: widget.db,
                                        currentGroupMembers:
                                            currentGroupMembers,
                                        buildEventContent: _buildEventContent,
                                        allEvents: widget.allEvents,
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

class CalendarCellIcon extends StatelessWidget {
  final DateTime date;
  final int personIndex;
  final DatabaseRepository db;
  final List<AppUser> currentGroupMembers;
  final Widget Function(String?, String, double) buildEventContent;
  final List<SingleEvent> allEvents;

  const CalendarCellIcon({
    super.key,
    required this.date,
    required this.personIndex,
    required this.db,
    required this.currentGroupMembers,
    required this.buildEventContent,
    required this.allEvents,
  });

  @override
  Widget build(BuildContext context) {
    final userId = currentGroupMembers[personIndex].profilId;

    final DateTime cutoffDate =
        DateTime.now().subtract(const Duration(days: 14));
    final bool isWithinRange = date.isAfter(cutoffDate) ||
        date.isAtSameMomentAs(cutoffDate) ||
        date.isAfter(DateTime.now());

    final eventsForPerson = allEvents.where((event) {
      final sameDay = event.singleEventDate.year == date.year &&
          event.singleEventDate.month == date.month &&
          event.singleEventDate.day == date.day;

      return sameDay &&
          (event.acceptedMemberIds.contains(userId) ||
              event.invitedMemberIds.contains(userId) ||
              event.maybeMemberIds.contains(userId)) &&
          isWithinRange;
    }).toList();

    if (eventsForPerson.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        const iconSize = 36.0;
        const spacing = 3.0;

        final maxIconsPerRow =
            (constraints.maxWidth / (iconSize + spacing)).floor();

        final displayEvents = eventsForPerson.take(maxIconsPerRow * 2).toList();

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: displayEvents.map((event) {
            return SizedBox(
              width: iconSize,
              height: iconSize,
              child: buildEventContent(
                event.singleEventUrl,
                event.singleEventName,
                iconSize,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
