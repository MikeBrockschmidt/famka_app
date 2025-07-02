class SingleEvent {
  final String singleEventId;
  final String singleEventName;
  final String singleEventLocation;
  final DateTime singleEventDate;
  final DateTime? singleEventEndTime;
  final List<String> attendingUsers;
  final String singleEventUrl;
  final String? description;
  final String groupId;
  final String? repeatOption;
  final String? reminderOption;
  final int? numberOfRepeats;

  SingleEvent({
    required this.singleEventId,
    required this.singleEventName,
    required this.singleEventLocation,
    required this.singleEventDate,
    this.singleEventEndTime,
    required this.attendingUsers,
    required this.singleEventUrl,
    this.description,
    required this.groupId,
    this.repeatOption,
    this.reminderOption,
    this.numberOfRepeats,
  });
}
