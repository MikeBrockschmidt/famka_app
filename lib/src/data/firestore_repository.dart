import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:uuid/uuid.dart';

class FirestoreDatabaseRepository implements DatabaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  @override
  AppUser? currentUser;

  Group? _currentGroupInternal;

  @override
  Group? get currentGroup => _currentGroupInternal;

  @override
  set currentGroup(Group? group) {
    _currentGroupInternal = group;
  }

  @override
  AuthRepository get auth =>
      throw UnimplementedError('AuthRepository should be injected.');

  @override
  Future<String> getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    throw Exception('Kein Benutzer eingeloggt.');
  }

  @override
  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => AppUser.fromMap(doc.data()!)).toList();
  }

  @override
  Future<void> createUser(AppUser user) async {
    await _firestore.collection('users').doc(user.profilId).set(user.toMap());
  }

  @override
  Future<void> updateUser(AppUser user) async {
    await _firestore
        .collection('users')
        .doc(user.profilId)
        .update(user.toMap());
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  @override
  Future<AppUser?> getUserAsync(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!);
    }
    return null;
  }

  @override
  Future<void> loginAs(String userId, String password, AppUser user) async {
    throw UnimplementedError(
        'loginAs in DatabaseRepository is ambiguous. Use AuthRepository for login.');
  }

  @override
  Future<String> getCurrentUserAvatarUrl() async {
    final id = await getCurrentUserId();
    final user = await getUserAsync(id);
    return user?.avatarUrl ?? '';
  }

  @override
  String generateNewGroupId() {
    return _uuid.v4();
  }

  @override
  Future<void> addGroup(Group group) async {
    await _firestore.collection('groups').doc(group.groupId).set(group.toMap());
    currentGroup = group;
  }

  @override
  Future<void> updateGroup(Group group) async {
    await _firestore
        .collection('groups')
        .doc(group.groupId)
        .update(group.toMap());
    currentGroup = group;
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection('groups').doc(groupId).delete();
    if (currentGroup?.groupId == groupId) {
      currentGroup = null;
    }
  }

  @override
  Future<Group?> getGroupAsync(String groupId) async {
    final doc = await _firestore.collection('groups').doc(groupId).get();
    if (doc.exists) {
      final groupData = doc.data()!;
      final List<String> memberIds =
          List<String>.from(groupData['groupMemberIds'] ?? []);
      List<AppUser> members = [];
      for (String memberId in memberIds) {
        final user = await getUserAsync(memberId);
        if (user != null) {
          members.add(user);
        }
      }
      return Group.fromMap(groupData, members);
    }
    return null;
  }

  @override
  Future<List<Group>> getGroupsForUser(String userId) async {
    final querySnapshot = await _firestore
        .collection('groups')
        .where('groupMemberIds', arrayContains: userId)
        .get();

    List<Group> groups = [];
    for (var doc in querySnapshot.docs) {
      final groupData = doc.data();
      final List<String> memberIds =
          List<String>.from(groupData['groupMemberIds'] ?? []);
      List<AppUser> members = [];
      for (String memberId in memberIds) {
        final user = await getUserAsync(memberId);
        if (user != null) {
          members.add(user);
        }
      }
      groups.add(Group.fromMap(groupData, members));
    }
    return groups;
  }

  @override
  Future<List<Group>> getGroupsOfUser() async {
    final userId = await getCurrentUserId();
    return getGroupsForUser(userId);
  }

  @override
  Future<List<AppUser>> getGroupMembers(String groupId) async {
    final group = await getGroupAsync(groupId);
    return group?.groupMembers ?? [];
  }

  @override
  Future<void> addUserToGroup(AppUser user, String groupId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'groupMemberIds': FieldValue.arrayUnion([user.profilId]),
    });
    if (currentGroup?.groupId == groupId) {
      currentGroup = await getGroupAsync(groupId);
    }
  }

  @override
  Future<void> removeUserFromGroup(String userId, String groupId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'groupMemberIds': FieldValue.arrayRemove([userId]),
    });
    if (currentGroup?.groupId == groupId) {
      currentGroup = await getGroupAsync(groupId);
    }
  }

  @override
  Future<void> leaveGroup(String groupId, String userId) async {
    final group = await getGroupAsync(groupId);
    if (group == null) return;

    await _firestore.collection('groups').doc(groupId).update({
      'groupMemberIds': FieldValue.arrayRemove([userId]),
      'userRoles.$userId': FieldValue.delete(),
    });

    if (currentGroup?.groupId == groupId) {
      currentGroup = await getGroupAsync(groupId);
    }

    final updatedGroup = await getGroupAsync(groupId);
    if (updatedGroup != null && updatedGroup.groupMembers.isEmpty) {
      await deleteGroup(groupId);
    }
  }

  @override
  Future<List<Group>> getAllGroups() async {
    final querySnapshot = await _firestore.collection('groups').get();
    List<Group> groups = [];
    for (var doc in querySnapshot.docs) {
      final groupData = doc.data();
      final List<String> memberIds =
          List<String>.from(groupData['groupMemberIds'] ?? []);
      List<AppUser> members = [];
      for (String memberId in memberIds) {
        final user = await getUserAsync(memberId);
        if (user != null) {
          members.add(user);
        }
      }
      groups.add(Group.fromMap(groupData, members));
    }
    return groups;
  }

  @override
  String generateNewEventId() => _uuid.v4();

  @override
  Future<SingleEvent?> getEventAsync(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return SingleEvent.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Fehler beim Abrufen des Events: $e');
      return null;
    }
  }

  @override
  Future<List<SingleEvent>> getAllEvents() async {
    final querySnapshot = await _firestore.collection('events').get();
    return querySnapshot.docs
        .map((doc) => SingleEvent.fromMap(doc.data()!))
        .toList();
  }

  @override
  Future<List<SingleEvent>> getEventsForGroup(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('events')
          .where('groupId', isEqualTo: groupId)
          .get();
      return querySnapshot.docs
          .map((doc) => SingleEvent.fromMap(doc.data()!))
          .toList();
    } catch (e) {
      print('Fehler beim Abrufen der Events für Gruppe $groupId: $e');
      return [];
    }
  }

  @override
  Future<void> createEvent(SingleEvent event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.singleEventId)
          .set(event.toMap());
    } catch (e) {
      print('Fehler beim Hinzufügen des Events: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateEvent(String groupId, SingleEvent event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.singleEventId)
          .update(event.toMap());
    } catch (e) {
      print('Fehler beim Aktualisieren des Events: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(String groupId, String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      print('Fehler beim Löschen des Events $eventId: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteSingleEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      print('Fehler beim Löschen des SingleEvents $eventId: $e');
      rethrow;
    }
  }
}
