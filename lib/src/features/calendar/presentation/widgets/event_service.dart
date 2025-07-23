import 'dart:async';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final _eventsController = StreamController<List<SingleEvent>>.broadcast();

  Stream<List<SingleEvent>> get eventsStream => _eventsController.stream;

  void updateEvents(List<SingleEvent> events) {
    _eventsController.add(events);
  }

  void dispose() {
    _eventsController.close();
  }
}
