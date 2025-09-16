import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SingleEvent {
  final String singleEventId;
  final String groupId;
  final String singleEventName;
  final String singleEventDescription;
  final String singleEventLocation;
  final DateTime singleEventDate;
  final String singleEventUrl;
  final String creatorId;
  final List<String> acceptedMemberIds;
  final List<String> invitedMemberIds;
  final List<String> maybeMemberIds;
  final List<String> declinedMemberIds;
  final bool isAllDay;
  final bool? hasReminder;
  final String? reminderOffset;
  // Markierungsdaten für Bereichs-Termine
  final DateTimeRange? selectedDateRange;
  final int? selectedRangeColorValue;
  final List<String>? selectedMemberIds;

  SingleEvent({
    required this.singleEventId,
    required this.groupId,
    required this.singleEventName,
    required this.singleEventDescription,
    required this.singleEventLocation,
    required this.singleEventDate,
    required this.singleEventUrl,
    required this.creatorId,
    this.acceptedMemberIds = const [],
    this.invitedMemberIds = const [],
    this.maybeMemberIds = const [],
    this.declinedMemberIds = const [],
    required this.isAllDay,
    this.hasReminder,
    this.reminderOffset,
  this.selectedDateRange,
  this.selectedRangeColorValue,
  this.selectedMemberIds,
  });

  SingleEvent copyWith({
    String? singleEventId,
    String? groupId,
    String? singleEventName,
    String? singleEventDescription,
    String? singleEventLocation,
    DateTime? singleEventDate,
    String? singleEventUrl,
    String? creatorId,
    List<String>? acceptedMemberIds,
    List<String>? invitedMemberIds,
    List<String>? maybeMemberIds,
    List<String>? declinedMemberIds,
    bool? isAllDay,
    bool? hasReminder,
    String? reminderOffset,
  DateTimeRange? selectedDateRange,
  int? selectedRangeColorValue,
  List<String>? selectedMemberIds,
  }) {
    return SingleEvent(
      singleEventId: singleEventId ?? this.singleEventId,
      groupId: groupId ?? this.groupId,
      singleEventName: singleEventName ?? this.singleEventName,
      singleEventDescription: singleEventDescription ?? this.singleEventDescription,
      singleEventLocation: singleEventLocation ?? this.singleEventLocation,
      singleEventDate: singleEventDate ?? this.singleEventDate,
      singleEventUrl: singleEventUrl ?? this.singleEventUrl,
      creatorId: creatorId ?? this.creatorId,
      acceptedMemberIds: acceptedMemberIds ?? this.acceptedMemberIds,
      invitedMemberIds: invitedMemberIds ?? this.invitedMemberIds,
      maybeMemberIds: maybeMemberIds ?? this.maybeMemberIds,
      declinedMemberIds: declinedMemberIds ?? this.declinedMemberIds,
      isAllDay: isAllDay ?? this.isAllDay,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderOffset: reminderOffset ?? this.reminderOffset,
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      selectedRangeColorValue: selectedRangeColorValue ?? this.selectedRangeColorValue,
      selectedMemberIds: selectedMemberIds ?? this.selectedMemberIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'singleEventId': singleEventId,
      'groupId': groupId,
      'singleEventName': singleEventName,
      'singleEventDescription': singleEventDescription,
      'singleEventLocation': singleEventLocation,
      'singleEventDate': Timestamp.fromDate(singleEventDate),
      'singleEventUrl': singleEventUrl,
      'creatorId': creatorId,
      'acceptedMemberIds': acceptedMemberIds,
      'invitedMemberIds': invitedMemberIds,
      'maybeMemberIds': maybeMemberIds,
      'declinedMemberIds': declinedMemberIds,
      'isAllDay': isAllDay,
      'hasReminder': hasReminder,
      'reminderOffset': reminderOffset,
      // Markierungsdaten
      'selectedDateRange': selectedDateRange != null
          ? {
              'start': Timestamp.fromDate(selectedDateRange!.start),
              'end': Timestamp.fromDate(selectedDateRange!.end),
            }
          : null,
      'selectedRangeColorValue': selectedRangeColorValue,
      'selectedMemberIds': selectedMemberIds,
    };
  }

  factory SingleEvent.fromMap(Map<String, dynamic> map) {
    DateTimeRange? range;
    if (map['selectedDateRange'] != null && map['selectedDateRange']['start'] != null && map['selectedDateRange']['end'] != null) {
      range = DateTimeRange(
        start: (map['selectedDateRange']['start'] as Timestamp).toDate(),
        end: (map['selectedDateRange']['end'] as Timestamp).toDate(),
      );
    }
    return SingleEvent(
      singleEventId: map['singleEventId'] as String,
      groupId: map['groupId'] as String,
      singleEventName: map['singleEventName'] as String,
      singleEventDescription: map['singleEventDescription'] as String,
      singleEventLocation: map['singleEventLocation'] as String,
      singleEventDate: (map['singleEventDate'] as Timestamp).toDate(),
      singleEventUrl: map['singleEventUrl'] as String,
      creatorId: map['creatorId'] as String,
      acceptedMemberIds: List<String>.from(map['acceptedMemberIds'] ?? []),
      invitedMemberIds: List<String>.from(map['invitedMemberIds'] ?? []),
      maybeMemberIds: List<String>.from(map['maybeMemberIds'] ?? []),
      declinedMemberIds: List<String>.from(map['declinedMemberIds'] ?? []),
      isAllDay: map['isAllDay'] as bool? ?? false,
      hasReminder: map['hasReminder'] as bool?,
      reminderOffset: map['reminderOffset'] as String?,
      selectedDateRange: range,
      selectedRangeColorValue: map['selectedRangeColorValue'] as int?,
      selectedMemberIds: map['selectedMemberIds'] != null ? List<String>.from(map['selectedMemberIds']) : null,
    );
  }
}
