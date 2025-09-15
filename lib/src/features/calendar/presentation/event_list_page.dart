import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/theme/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/menu_sub_container_two_lines_group_c.dart';
import 'package:famka_app/src/features/calendar/presentation/widgets/info_bottom_sheet.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/gallery/presentation/widgets/event_image.dart';
import 'package:famka_app/gen_l10n/app_localizations.dart';

class EventListPage extends StatefulWidget {
  final DatabaseRepository db;
  final Group currentGroup;
  final AppUser currentUser;
  final AuthRepository auth;
  final Function()? onEventsRefreshed;

  const EventListPage({
    super.key,
    required this.db,
    required this.currentGroup,
    required this.currentUser,
    required this.auth,
    this.onEventsRefreshed,
  });

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  // Hilfsmethode: Vergleicht, ob zwei DateTime-Objekte am selben Tag liegen
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  late Group _displayGroup;
  List<SingleEvent> _events = [];
  bool _isLoading = true;
  bool _showLoadingIndicator = false;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();
  bool _initialScrollComplete = false;

  Map<String, List<SingleEvent>> groupedEvents = {};
  List<String> orderedHeaders = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('de', null);
    initializeDateFormatting('en', null);
    _displayGroup = widget.currentGroup;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadEvents();
    _deleteOldEventsIfNeeded();
  }

  void _deleteOldEventsIfNeeded() async {
    final DateTime cutoffDate =
        DateTime.now().subtract(const Duration(days: 14));
    final List<SingleEvent> allEvents =
        await widget.db.getEventsForGroup(_displayGroup.groupId);
    await _deleteOldEvents(allEvents, cutoffDate);
    await _loadEvents();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  // Dialog entfernt: Alte Events werden automatisch gelöscht

  Future<void> _deleteOldEvents(
      List<SingleEvent> allEvents, DateTime cutoffDate) async {
    final List<SingleEvent> oldEvents = allEvents
        .where((event) =>
            event.singleEventDate.isBefore(cutoffDate) &&
            !_isSameDay(event.singleEventDate, cutoffDate))
        .toList();

    if (oldEvents.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keine alten Ereignisse zum Löschen gefunden'),
          ),
        );
      }
      return;
    }

    int deletedCount = 0;
    int failedCount = 0;

    for (var event in oldEvents) {
      try {
        await widget.db.deleteEvent(event.groupId, event.singleEventId);
        deletedCount++;
      } catch (e) {
        failedCount++;
      }
    }

    if (mounted) {
      String message = '';
      if (deletedCount > 0) {
        message = '$deletedCount alte Ereignisse wurden gelöscht';
        if (failedCount > 0) {
          message += ', $failedCount konnten nicht gelöscht werden';
        }
      } else if (failedCount > 0) {
        message =
            'Fehler: $failedCount Ereignisse konnten nicht gelöscht werden';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _cleanupOldEvents(
      List<SingleEvent> allEvents, DateTime cutoffDate) async {
    final List<SingleEvent> oldEvents = allEvents
        .where((event) =>
            event.singleEventDate.isBefore(cutoffDate) &&
            !_isSameDay(event.singleEventDate, cutoffDate))
        .toList();

    if (oldEvents.isNotEmpty) {
      // Hinweis: Info-Banner für gelöschte alte Events wird über _filteredEventsCount gesteuert
    }
  }

  void _scrollToToday() {
    if (!mounted || _isLoading) return;

    _initialScrollComplete = true;

    final localizations = AppLocalizations.of(context);
    if (localizations == null) return;

    final todayHeader = localizations.eventListTodayHeader;
    final todayIndex = orderedHeaders.indexOf(todayHeader);

    if (todayIndex != -1) {
      double scrollPosition = 0;

      for (int i = 0; i < todayIndex; i++) {
        final header = orderedHeaders[i];
        scrollPosition += 50 + (groupedEvents[header]?.length ?? 0) * 70;
      }

      _scrollController.animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      // ...existing code...
    } else {}
  }

  @override
  void didUpdateWidget(covariant EventListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentGroup.groupId != oldWidget.currentGroup.groupId ||
        widget.currentUser.profilId != oldWidget.currentUser.profilId) {
      setState(() {
        _displayGroup = widget.currentGroup;
        _isLoading = true;
        _showLoadingIndicator = false;
      });
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    AppLocalizations? localizations;
    try {
      localizations = AppLocalizations.of(context);
    } catch (e) {
      // Fehler beim Laden der Lokalisierung ignorieren
    }

    // Show loading indicator only after a delay to avoid flashing
    setState(() {
      _isLoading = true;
      _showLoadingIndicator = false;
      _errorMessage = null;
    });

    // Delay showing the loading indicator to avoid flashing for quick loads
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted && _isLoading) {
        setState(() {
          _showLoadingIndicator = true;
        });
      }
    });

    try {
      final List<SingleEvent> allEvents =
          await widget.db.getEventsForGroup(_displayGroup.groupId);

      if (mounted) {
        final DateTime cutoffDate =
            DateTime.now().subtract(const Duration(days: 14));

        setState(() {
          _isLoading = false;
          _showLoadingIndicator = false;
          _events = allEvents
              .where((event) =>
                  event.singleEventDate.isAfter(cutoffDate) ||
                  _isSameDay(event.singleEventDate, cutoffDate))
              .toList();

          _events
              .sort((a, b) => a.singleEventDate.compareTo(b.singleEventDate));
        });

        _cleanupOldEvents(allEvents, cutoffDate);

        if (!_initialScrollComplete) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _scrollToToday();
          });
        }
      }
    } catch (e) {
      String errorStateMsg = 'Fehler beim Laden der Events: $e';
      if (localizations != null) {
        errorStateMsg = localizations.eventListLoadingError(e.toString());
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showLoadingIndicator = false;
          _errorMessage = errorStateMsg;
        });
      }
    }
  }

  Future<void> _onEventDeleted(String eventId) async {
    AppLocalizations? localizations;
    try {
      localizations = AppLocalizations.of(context);
    } catch (e) {
      // Fehler beim Laden der Lokalisierung ignorieren
    }

    try {
      final SingleEvent deletedEvent = _events.firstWhere(
        (event) => event.singleEventId == eventId,
        orElse: () => throw Exception(
            localizations?.eventDeleteTargetNotFound ??
                "Fehler: Zu löschender Termin nicht gefunden."),
      );

      await widget.db
          .deleteEvent(deletedEvent.groupId, deletedEvent.singleEventId);
      if (mounted) {
        setState(() {
          _events.removeWhere((e) => e.singleEventId == eventId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(localizations?.eventListDeletedSuccess ??
                  "Termin erfolgreich gelöscht.")),
        );
        widget.onEventsRefreshed?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaRed,
            content: Text(localizations != null
                ? localizations.eventDeletionError(e.toString())
                : "Fehler beim Löschen des Termins: $e"),
          ),
        );
      }
      await _loadEvents();
    }
  }

  Widget _buildEventLeadingIcon(
      String? eventUrl, String eventName, double size) {
    if (eventUrl == null || eventUrl.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.grey.shade200,
        child: Text(
          eventName.isNotEmpty ? eventName[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: size * 0.5,
            color: AppColors.famkaGreen,
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
            fontFamilyFallback: const [
              'Apple Color Emoji',
              'Segoe UI Emoji',
              'Segoe UI Symbol'
            ],
          ),
        ),
      );
    } else if (eventUrl.startsWith('icon:')) {
      final iconCodePoint = int.tryParse(eventUrl.substring(5));
      if (iconCodePoint != null) {
        return Icon(
          Icons.category, // Fallback to a constant icon
          size: size * 0.9,
          color: AppColors.famkaGrey,
        );
      }
    } else if (eventUrl.startsWith('image:')) {
      final actualImageUrl = eventUrl.substring(6);

      if (actualImageUrl.startsWith('http://') ||
          actualImageUrl.startsWith('https://')) {
        return EventImage(
          widget.db,
          currentAvatarUrl: actualImageUrl,
          displayRadius: size / 2,
          applyTransformOffset: false,
          isInteractive: false,
        );
      } else {
        return Image.asset(
          actualImageUrl,
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
    final localizations = AppLocalizations.of(context)!;
    final String currentLocale = Localizations.localeOf(context).languageCode;

    Map<String, List<SingleEvent>> groupedEvents = {};
    List<String> orderedHeaders = [];

    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    final todayHeader = localizations.eventListTodayHeader;
    final tomorrowHeader = localizations.eventListTomorrowHeader;
    bool hasTodayHeader = false;

    for (var event in _events) {
      final date = event.singleEventDate;
      String header;

      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        header = todayHeader;
        hasTodayHeader = true;
      } else if (date.year == tomorrow.year &&
          date.month == tomorrow.month &&
          date.day == tomorrow.day) {
        header = tomorrowHeader;
      } else {
        header = DateFormat('EEEE, d. MMMM y', currentLocale)
            .format(date)
            .toUpperCase();
      }

      if (!groupedEvents.containsKey(header)) {
        groupedEvents[header] = [];
        orderedHeaders.add(header);
      }
      groupedEvents[header]!.add(event);
    }

    groupedEvents.forEach((header, events) {
      events.sort((a, b) => a.singleEventDate.compareTo(b.singleEventDate));
    });

    orderedHeaders.sort((a, b) {
      if (a == todayHeader) return -1;
      if (b == todayHeader) return 1;
      if (a == tomorrowHeader) return -1;
      if (b == tomorrowHeader) return 1;

      final aEvents = groupedEvents[a]!;
      final bEvents = groupedEvents[b]!;
      if (aEvents.isNotEmpty && bEvents.isNotEmpty) {
        return aEvents.first.singleEventDate
            .compareTo(bEvents.first.singleEventDate);
      }
      return 0;
    });

    if (!_initialScrollComplete && hasTodayHeader && !_isLoading && mounted) {
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollToToday();
      });
    }

    void handleGroupUpdated(Group updatedGroup) {
      if (mounted) {
        setState(() {
          _displayGroup = updatedGroup;
          _isLoading = true;
          _showLoadingIndicator = false;
        });
        _loadEvents();
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 1,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          MenuSubContainerTwoLinesGroupC(
            widget.db,
            currentGroup: _displayGroup,
            onGroupUpdated: handleGroupUpdated,
            currentUser: widget.currentUser,
            auth: widget.auth,
          ),
          const Divider(thickness: 0.4, height: 0.4, color: Colors.grey),
          Expanded(
            child: _showLoadingIndicator
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(_errorMessage!,
                            style: TextStyle(color: AppColors.famkaRed)),
                      )
                    : groupedEvents.isEmpty
                        ? Center(
                            child: Text(
                              localizations.eventListNoEvents,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: orderedHeaders.length,
                            itemBuilder: (context, index) {
                              String header = orderedHeaders[index];
                              List<SingleEvent> events = groupedEvents[header]!;

                              return StickyHeaderBuilder(
                                builder:
                                    (BuildContext context, double stuckAmount) {
                                  stuckAmount =
                                      1.0 - stuckAmount.clamp(0.0, 1.0);
                                  return Container(
                                    height: 50.0,
                                    color: AppColors.famkaBlue,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      header,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  );
                                },
                                content: Column(
                                  children: events.map((event) {
                                    return GestureDetector(
                                      onTap: () async {
                                        await showModalBottomSheet<bool>(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) {
                                            return InfoBottomSheet(
                                              date: event.singleEventDate,
                                              userName:
                                                  widget.currentUser.firstName,
                                              eventsForPerson: [event],
                                              currentGroupMembers:
                                                  _displayGroup.groupMembers,
                                              db: widget.db,
                                              onEventDeleted: _onEventDeleted,
                                              onEventUpdated: (updatedEvent) {
                                                _loadEvents();
                                              },
                                            );
                                          },
                                        );
                                        await _loadEvents();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey.shade200)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 16.0),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 40,
                                                height: 40,
                                                child: _buildEventLeadingIcon(
                                                  event.singleEventUrl,
                                                  event.singleEventName,
                                                  40,
                                                ),
                                              ),
                                              const SizedBox(width: 16.0),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      event.singleEventName,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium,
                                                    ),
                                                    Text(
                                                      event.isAllDay
                                                          ? ' '
                                                          : localizations.eventListTimeFormat(
                                                              DateFormat(
                                                                      'HH:mm',
                                                                      currentLocale)
                                                                  .format(event
                                                                      .singleEventDate)),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.info_outline,
                                                    color: AppColors.famkaBlue),
                                                onPressed: () async {
                                                  await showModalBottomSheet<
                                                      bool>(
                                                    context: context,
                                                    isScrollControlled: true,
                                                    builder: (context) {
                                                      return InfoBottomSheet(
                                                        date: event
                                                            .singleEventDate,
                                                        userName: widget
                                                            .currentUser
                                                            .firstName,
                                                        eventsForPerson: [
                                                          event
                                                        ],
                                                        currentGroupMembers:
                                                            _displayGroup
                                                                .groupMembers,
                                                        db: widget.db,
                                                        onEventDeleted:
                                                            _onEventDeleted,
                                                        onEventUpdated:
                                                            (updatedEvent) {
                                                          _loadEvents();
                                                        },
                                                      );
                                                    },
                                                  );
                                                  await _loadEvents();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
          ),
          BottomNavigationThreeCalendar(
            widget.db,
            initialGroup: _displayGroup,
            currentUser: widget.currentUser,
            initialIndex: 1,
            auth: widget.auth,
            locale: Localizations.localeOf(context),
          ),
        ],
      ),
    );
  }
}
