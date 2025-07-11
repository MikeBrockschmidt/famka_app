import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/firebase_auth_repository.dart';
import 'package:famka_app/src/features/login/domain/user_role.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

class MockDatabaseRepository implements DatabaseRepository {
  static final MockDatabaseRepository _instance =
      MockDatabaseRepository._internal();

  factory MockDatabaseRepository() {
    return _instance;
  }

  MockDatabaseRepository._internal() {
    _users.addAll([
      AppUser(
        profilId: 'u1',
        firstName: 'Mike',
        lastName: 'Brockschmidt',
        email: 'info@mike-brockschmidt.de',
        phoneNumber: '123456789',
        avatarUrl: 'assets/fotos/Mike.jpg',
        miscellaneous: 'Keine zusätzlichen Infos...',
        password: '!Mike1234',
      ),
      AppUser(
        profilId: 'u2',
        firstName: 'Melanie',
        lastName: 'Brockschmidt',
        email: 'melanie@example.com',
        phoneNumber: '987654321',
        avatarUrl: 'assets/fotos/Melanie.jpg',
        miscellaneous: 'Mama',
        password: '!Melanie1234',
      ),
      AppUser(
        profilId: 'u3',
        firstName: 'Max',
        lastName: 'Brockschmidt',
        email: '',
        phoneNumber: '',
        avatarUrl: 'assets/fotos/Max.jpg',
        miscellaneous: '',
        password: '!Max1234',
      ),
      AppUser(
        profilId: 'u4',
        firstName: 'Martha',
        lastName: 'Brockschmidt',
        email: '',
        phoneNumber: '',
        avatarUrl: 'assets/fotos/Martha.jpg',
        miscellaneous: '',
        password: '!Martha1234',
      ),
      AppUser(
        profilId: 'u5',
        firstName: 'Boyd',
        lastName: '',
        email: '',
        phoneNumber: '',
        avatarUrl: 'assets/fotos/boyd.jpg',
        miscellaneous: 'Unser 5-tes Familiemitglied',
        password: '',
      ),
    ]);
    _groups.addAll([
      Group(
        groupId: 'g1',
        groupName: 'Familie Brockschmidt',
        groupLocation: 'Osnabrück',
        groupDescription:
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua...',
        groupAvatarUrl: 'assets/fotos/Familie.jpg',
        creatorId: 'u1',
        groupMembers: List<AppUser>.from(
            [_users[0], _users[1], _users[2], _users[3], _users[4]]),
        userRoles: {
          'u1': UserRole.admin,
          'u2': UserRole.admin,
          'u3': UserRole.member,
          'u4': UserRole.member,
          'u5': UserRole.member,
        },
      ),
      Group(
        groupId: 'g2',
        groupName: 'Familie Test',
        groupLocation: 'Köln',
        groupDescription:
            'Köln ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua...',
        groupAvatarUrl: 'assets/fotos/Max.jpg',
        creatorId: 'u5',
        groupMembers: List<AppUser>.from([_users[4], _users[3]]),
        userRoles: {
          'u5': UserRole.admin,
          'u4': UserRole.member,
        },
      ),
      Group(
        groupId: 'g3',
        groupName: 'Freunde Köln',
        groupLocation: 'Köln',
        groupDescription: 'Eine Gruppe für Freunde in Köln.',
        groupAvatarUrl: 'assets/fotos/melanie.jpg',
        creatorId: 'u2',
        groupMembers: List<AppUser>.from([_users[1], _users[3], _users[4]]),
        userRoles: {
          'u2': UserRole.admin,
          'u3': UserRole.member,
          'u4': UserRole.member,
        },
      ),
    ]);

    _events.addAll([
      SingleEvent(
        singleEventId: _uuid.v4(),
        groupId: 'g1',
        creatorId: 'u1',
        singleEventName: 'Familienessen',
        singleEventDate: DateTime.now().add(const Duration(days: 1)),
        singleEventLocation: 'Restaurant O.S. Kitchen',
        singleEventDescription: 'Gemütliches Abendessen mit der Familie.',
        singleEventUrl: 'image:assets/icons/food.png',
        acceptedMemberIds: ['u1', 'u2', 'u3'],
        invitedMemberIds: ['u4'],
        maybeMemberIds: ['u5'],
      ),
      SingleEvent(
        singleEventId: _uuid.v4(),
        groupId: 'g1',
        creatorId: 'u2',
        singleEventName: 'Fußballtraining Max',
        singleEventDate: DateTime.now().add(const Duration(days: 2)),
        singleEventLocation: 'Sportplatz',
        singleEventDescription: 'Training für Max\'s Fußballmannschaft.',
        singleEventUrl: 'icon:58137',
        acceptedMemberIds: ['u2', 'u3'],
        invitedMemberIds: [],
        maybeMemberIds: ['u1'],
      ),
      SingleEvent(
        singleEventId: _uuid.v4(),
        groupId: 'g2',
        creatorId: 'u5',
        singleEventName: 'Kölner Dom Besuch',
        singleEventDate: DateTime.now().add(const Duration(days: 3)),
        singleEventLocation: 'Kölner Dom',
        singleEventDescription: 'Besichtigung des Kölner Doms.',
        singleEventUrl: 'emoji:⛪',
        acceptedMemberIds: ['u5'],
        invitedMemberIds: ['u4'],
        maybeMemberIds: [],
      ),
    ]);
  }

  final Uuid _uuid = const Uuid();
  final List<Group> _groups = [];
  final List<AppUser> _users = [];
  final List<SingleEvent> _events = [];

  String? _currentLoggedInUserId;
  Group? _currentGroupValue;

  @override
  AppUser? currentUser;

  @override
  AuthRepository get auth => FirebaseAuthRepository();

  @override
  Group? get currentGroup => _currentGroupValue;

  @override
  set currentGroup(Group? group) {
    _currentGroupValue = group;
  }

  @override
  Future<void> loginAs(
      String userIdOrEmailOrPhone, String password, AppUser appUser) async {
    final user = _users.firstWhereOrNull(
      (u) =>
          (u.profilId == userIdOrEmailOrPhone ||
              u.email == userIdOrEmailOrPhone ||
              u.phoneNumber == userIdOrEmailOrPhone) &&
          u.password == password,
    );
    if (user != null) {
      _currentLoggedInUserId = user.profilId;
      currentUser = user;
      currentGroup = (await getGroupsForUser(user.profilId)).firstOrNull;
    } else {
      throw Exception('Falscher Benutzername oder Passwort');
    }
  }

  @override
  Future<String> getCurrentUserId() async {
    await Future.delayed(const Duration(milliseconds: 1));
    if (_currentLoggedInUserId != null) {
      return _currentLoggedInUserId!;
    } else {
      throw Exception('Kein Benutzer ist eingeloggt.');
    }
  }

  @override
  Future<List<Group>> getGroupsForUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 1));
    return _groups
        .where((group) =>
            group.groupMembers.any((member) => member.profilId == userId))
        .toList();
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 1));
    return _users;
  }

  @override
  Future<List<SingleEvent>> getAllEvents() async {
    await Future.delayed(const Duration(milliseconds: 1));
    return _events;
  }

  @override
  Future<List<SingleEvent>> getEventsForGroup(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 1));
    return _events.where((event) => event.groupId == groupId).toList();
  }

  @override
  Future<void> addUserToGroup(AppUser user, String groupId) async {
    for (Group group in _groups) {
      if (group.groupId == groupId) {
        if (!group.groupMembers.any((m) => m.profilId == user.profilId)) {
          group.groupMembers.add(user);
        }
        break;
      }
    }
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  Future<void> createEvent(SingleEvent event) async {
    _events.add(event);
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  Future<void> addGroup(Group group) async {
    _groups.add(group);
    currentGroup = group;
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  Future<void> createUser(AppUser user) async {
    _users.add(user);
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  Future<void> deleteEvent(String groupId, String eventId) async {
    _events.removeWhere(
        (event) => event.groupId == groupId && event.singleEventId == eventId);
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    _groups.removeWhere((group) => group.groupId == groupId);
    if (currentGroup?.groupId == groupId) {
      currentGroup = null;
    }
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  Future<void> deleteUser(String userId) async {
    _users.removeWhere((user) => user.profilId == userId);
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  Future<SingleEvent?> getEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 1));
    return _events.firstWhereOrNull((event) => event.singleEventId == eventId);
  }

  @override
  Future<SingleEvent?> getEventAsync(String eventId) async {
    return getEvent(eventId);
  }

  @override
  Future<Group?> getGroup(String groupId) async {
    await Future.delayed(const Duration(milliseconds: 1));
    return _groups.firstWhereOrNull((group) => group.groupId == groupId);
  }

  @override
  Future<Group?> getGroupAsync(String groupId) async {
    return getGroup(groupId);
  }

  @override
  Future<AppUser?> getUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 1));
    return _users.firstWhereOrNull((user) => user.profilId == userId);
  }

  @override
  Future<AppUser?> getUserAsync(String userId) async {
    return getUser(userId);
  }

  @override
  Future<void> removeUserFromGroup(String userId, String groupId) async {
    for (Group group in _groups) {
      if (group.groupId == groupId) {
        group.groupMembers.removeWhere((user) => user.profilId == userId);
        group.userRoles.remove(userId);
        break;
      }
    }
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  Future<void> updateEvent(String groupId, SingleEvent event) async {
    for (int i = 0; i < _events.length; i++) {
      if (_events[i].singleEventId == event.singleEventId &&
          _events[i].groupId == groupId) {
        _events[i] = event;
        break;
      }
    }
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  Future<void> updateGroup(Group group) async {
    for (int i = 0; i < _groups.length; i++) {
      if (_groups[i].groupId == group.groupId) {
        _groups[i] = group;
        if (currentGroup?.groupId == group.groupId) {
          currentGroup = group;
        }
        break;
      }
    }
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  Future<void> updateUser(AppUser user) async {
    for (int i = 0; i < _users.length; i++) {
      if (_users[i].profilId == user.profilId) {
        _users[i] = user;
        if (currentUser?.profilId == user.profilId) {
          currentUser = user;
        }
        break;
      }
    }
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  Future<List<AppUser>> getGroupMembers(String groupId) async {
    final group = _groups.firstWhereOrNull((g) => g.groupId == groupId);
    return group?.groupMembers ?? [];
  }

  @override
  Future<List<Group>> getAllGroups() async {
    await Future.delayed(const Duration(milliseconds: 1));
    return _groups;
  }

  @override
  String generateNewGroupId() {
    return _uuid.v4();
  }

  @override
  String generateNewEventId() {
    return _uuid.v4();
  }

  @override
  Future<List<Group>> getGroupsOfUser() async {
    final userId = await getCurrentUserId();
    return getGroupsForUser(userId);
  }

  @override
  Future<String> getCurrentUserAvatarUrl() async {
    final userId = await getCurrentUserId();
    final user = await getUser(userId);
    if (user != null) {
      return user.avatarUrl ?? '';
    } else {
      throw Exception('Kein Benutzer gefunden.');
    }
  }

  @override
  Future<void> leaveGroup(String groupId, String userId) async {
    final groupIndex = _groups.indexWhere((group) => group.groupId == groupId);

    if (groupIndex != -1) {
      final group = _groups[groupIndex];

      group.groupMembers.removeWhere((member) => member.profilId == userId);
      group.userRoles.remove(userId);

      if (group.groupMembers.isEmpty) {
        _groups.removeAt(groupIndex);
        if (currentGroup?.groupId == groupId) {
          currentGroup = null;
        }
      } else {
        _groups[groupIndex] = group;
      }
    } else {
      throw Exception('Gruppe nicht gefunden.');
    }
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  Future<void> deleteSingleEvent(String eventId) {
    throw UnimplementedError();
  }
}
