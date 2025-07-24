// lib/src/features/calendar/presentation/event_list_page.dart
import 'package:famka_app/src/common/bottom_navigation_three_calendar.dart';
import 'package:famka_app/src/common/button_linear_gradient.dart';
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

class EventListPage extends StatefulWidget {
  final DatabaseRepository db;
  final Group currentGroup;
  final AppUser currentUser;
  final AuthRepository auth;
  final Function()?
      onEventsRefreshed; // HINZUGEFÜGT: Callback, wenn Events neu geladen werden sollen

  const EventListPage({
    super.key,
    required this.db,
    required this.currentGroup,
    required this.currentUser,
    required this.auth,
    this.onEventsRefreshed, // HINZUGEFÜGT
  });

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  late Group _displayGroup;
  List<SingleEvent> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('de_DE', null);
    _displayGroup = widget.currentGroup;
    _loadEvents();
  }

  @override
  void didUpdateWidget(covariant EventListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentGroup.groupId != oldWidget.currentGroup.groupId ||
        widget.currentUser.profilId != oldWidget.currentUser.profilId) {
      setState(() {
        _displayGroup = widget.currentGroup;
      });
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    print('EventListPage: Starte Laden der Events...');
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('EventListPage: Lade Events für Gruppe ${_displayGroup.groupId}');
      final List<SingleEvent> allEvents =
          await widget.db.getEventsForGroup(_displayGroup.groupId);

      setState(() {
        _events = allEvents;
        _events.sort((a, b) => a.singleEventDate.compareTo(b.singleEventDate));
        print('EventListPage: ${_events.length} Events geladen');
      });
    } catch (e) {
      print('EventListPage: Fehler beim Laden - $e');
      setState(() {
        _errorMessage = 'Fehler beim Laden der Events: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onEventDeleted(String eventId) async {
    try {
      final SingleEvent? deletedEvent = _events.firstWhere(
        (event) => event.singleEventId == eventId,
        orElse: () => null!,
      );

      if (deletedEvent != null) {
        await widget.db
            .deleteEvent(deletedEvent.groupId, deletedEvent.singleEventId);
        if (mounted) {
          setState(() {
            _events.removeWhere((e) => e.singleEventId == eventId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Termin erfolgreich gelöscht.')),
          );
          widget.onEventsRefreshed?.call(); // HINZUGEFÜGT: Refresh nach Löschen
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.famkaRed,
              content: Text('Fehler: Zu löschender Termin nicht gefunden.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.famkaRed,
            content: Text('Fehler beim Löschen des Termins: $e'),
          ),
        );
      }
      await _loadEvents();
    }
  }

  Widget _buildEventLeadingIcon(
      String? eventUrl, String eventName, double size) {
    if (eventUrl == null || eventUrl.isEmpty) {
      // Fallback für leere/null URLs
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
      return Text(
        emoji,
        style: TextStyle(
          fontSize: size * 0.9,
          fontFamilyFallback: const [
            'Apple Color Emoji',
            'Segoe UI Emoji',
            'Segoe UI Symbol'
          ],
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
      final actualImageUrl = eventUrl.substring(6); // Entferne 'image:' Präfix

      if (actualImageUrl.startsWith('http://') ||
          actualImageUrl.startsWith('https://')) {
        return EventImage(
          widget.db,
          currentAvatarUrl: actualImageUrl,
          displayRadius: size / 2,
          applyTransformOffset: false,
          isInteractive: false, // <-- Wichtige Änderung
        );
      } else {
        // Fallback für lokale Asset-Bilder mit 'image:' Präfix
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

    // Dieser Fall sollte greifen, wenn eventUrl direkt eine HTTP/HTTPS-URL ist
    // ohne das 'image:' Präfix, oder als letzter Fallback.
    return EventImage(
      widget.db,
      currentAvatarUrl: eventUrl,
      displayRadius: size / 2,
      applyTransformOffset: false,
      isInteractive: false, // <-- Wichtige Änderung
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<SingleEvent>> groupedEvents = {};
    for (var event in _events) {
      final date = event.singleEventDate;
      String header;
      final today = DateTime.now();
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      if (date.year == today.year &&
          date.month == today.month &&
          date.day == today.day) {
        header = 'HEUTE';
      } else if (date.year == tomorrow.year &&
          date.month == tomorrow.month &&
          date.day == tomorrow.day) {
        header = 'MORGEN';
      } else {
        header =
            DateFormat('EEEE, d. MMMM y', 'de_DE').format(date).toUpperCase();
      }

      if (!groupedEvents.containsKey(header)) {
        groupedEvents[header] = [];
      }
      groupedEvents[header]!.add(event);
    }

    void _handleGroupUpdated(Group updatedGroup) {
      if (mounted) {
        setState(() {
          _displayGroup = updatedGroup;
          _loadEvents();
        });
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
          MenuSubContainer2LinesGroupC(
            widget.db,
            currentGroup: _displayGroup,
            onGroupUpdated: _handleGroupUpdated,
            currentUser: widget.currentUser,
            auth: widget.auth,
          ),
          const Divider(thickness: 0.4, height: 0.4, color: Colors.grey),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text(_errorMessage!,
                            style: TextStyle(color: AppColors.famkaRed)),
                      )
                    : groupedEvents.isEmpty
                        ? const Center(
                            child: Text(
                              'Keine Termine für diese Gruppe gefunden.',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: groupedEvents.keys.length,
                            itemBuilder: (context, index) {
                              String header =
                                  groupedEvents.keys.elementAt(index);
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
                                        final bool? eventWasDeleted =
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
                                              // HIER IST DIE KORREKTUR/ERGÄNZUNG:
                                              onEventUpdated: (updatedEvent) {
                                                _loadEvents(); // Events neu laden, um die Änderungen anzuzeigen
                                              },
                                            );
                                          },
                                        );
                                        // Nach dem Schließen des Bottom Sheets, egal ob gelöscht oder nicht,
                                        // laden wir die Events neu, falls eine Aktualisierung stattgefunden hat.
                                        // Der onEventUpdated-Callback im InfoBottomSheet sollte dies bereits triggern,
                                        // aber ein zusätzlicher Aufruf hier schadet nicht, falls andere Änderungen
                                        // (nicht nur Beschreibung) in Zukunft hinzukommen.
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
                                                      '${DateFormat('HH:mm', 'de_DE').format(event.singleEventDate)} Uhr',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () async {
                                                  final bool? confirm =
                                                      await showDialog<bool>(
                                                    context: context,
                                                    builder: (BuildContext
                                                        dialogContext) {
                                                      return AlertDialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        title: const Text(
                                                          'Termin löschen',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        content: Text(
                                                          'Möchtest du "${event.singleEventName}" wirklich löschen?',
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black87),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                24, 20, 24, 0),
                                                        actionsPadding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                16, 8, 16, 16),
                                                        actions: <Widget>[
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () =>
                                                                    Navigator.of(
                                                                            dialogContext)
                                                                        .pop(
                                                                            false),
                                                                child:
                                                                    const ButtonLinearGradient(
                                                                  buttonText:
                                                                      'Abbrechen',
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 12),
                                                              GestureDetector(
                                                                onTap: () =>
                                                                    Navigator.of(
                                                                            dialogContext)
                                                                        .pop(
                                                                            true),
                                                                child:
                                                                    const ButtonLinearGradient(
                                                                  buttonText:
                                                                      'Löschen',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );

                                                  if (confirm == true) {
                                                    await _onEventDeleted(
                                                        event.singleEventId);
                                                  }
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
            // onEventsRefreshed: widget.onEventsRefreshed, // DIESE ZEILE WIRD ENTFERNT ODER AUSKOMMENTIERT
          ),
        ],
      ),
    );
  }
}
