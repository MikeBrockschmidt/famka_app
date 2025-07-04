import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/data/firebase_auth_repository.dart';
import 'package:famka_app/src/data/user_role.dart';
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
        birthDate: DateTime(1981, 8, 16),
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
        birthDate: DateTime(1981, 4, 17),
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
        birthDate: DateTime(2016, 7, 23),
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
        birthDate: DateTime(2017, 9, 26),
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
        birthDate: DateTime(2016, 8, 10),
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
  }

  final Uuid _uuid = const Uuid();
  final List<Group> _groups = [];
  final List<AppUser> _users = [];
  final List<SingleEvent> _events = [];

  String? _currentLoggedInUserId;

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
      currentUser = appUser;
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
  List<SingleEvent> getAllEvents() {
    return _events;
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
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  Future<void> deleteUser(String userId) async {
    _users.removeWhere((user) => user.profilId == userId);
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  SingleEvent? getEvent(String eventId) {
    return _events.firstWhereOrNull((event) => event.singleEventId == eventId);
  }

  @override
  Group? getGroup(String groupId) {
    return _groups.firstWhereOrNull((group) => group.groupId == groupId);
  }

  @override
  AppUser? getUser(String userId) {
    return _users.firstWhereOrNull((user) => user.profilId == userId);
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
  List<Group> getAllGroups() {
    return _groups;
  }

  @override
  String generateNewGroupId() {
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
    final user = getUser(userId);
    if (user != null) {
      return user.avatarUrl;
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
      } else {
        _groups[groupIndex] = group;
      }
    } else {
      throw Exception('Gruppe nicht gefunden.');
    }
    await Future.delayed(const Duration(milliseconds: 1));
  }

  @override
  AppUser? currentUser;

  @override
  AuthRepository get auth => FirebaseAuthRepository();
}
