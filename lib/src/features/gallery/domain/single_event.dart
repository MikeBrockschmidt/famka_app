class SingleEvent {
  final String singleEventId;
  final String singleEventName;
  final String singleEventLocation;
  final DateTime singleEventDate;
  final List<String> attendingUsers;
  final String singleEventUrl;
  final String groupId;

  SingleEvent({
    required this.singleEventId,
    required this.singleEventName,
    required this.singleEventLocation,
    required this.singleEventDate,
    required this.attendingUsers,
    required this.singleEventUrl,
    required this.groupId,
  });
}
