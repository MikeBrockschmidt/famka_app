import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:famka_app/src/features/login/domain/user_role.dart';

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
    try {
      final snapshot = await _firestore.collection('users').get();
      print('✅ Alle Benutzer erfolgreich abgerufen.');
      return snapshot.docs.map((doc) => AppUser.fromMap(doc.data())).toList();
    } catch (e) {
      print('❌ Fehler beim Abrufen aller Benutzer: $e');
      return [];
    }
  }

  @override
  Future<void> createUser(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.profilId).set(user.toMap());
      print('✅ Benutzer ${user.profilId} erfolgreich erstellt.');
    } catch (e) {
      print('❌ Fehler beim Erstellen des Benutzers: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateUser(AppUser user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.profilId)
          .update(user.toMap());
      print('✅ Benutzer ${user.profilId} erfolgreich aktualisiert.');
    } catch (e) {
      print('❌ Fehler beim Aktualisieren des Benutzers: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      print('✅ Benutzer $userId erfolgreich gelöscht.');
    } catch (e) {
      print('❌ Fehler beim Löschen des Benutzers $userId: $e');
      rethrow;
    }
  }

  @override
  Future<AppUser?> getUserAsync(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        print('✅ Benutzer $userId erfolgreich abgerufen.');
        return AppUser.fromMap(doc.data()!);
      }
      print('ℹ️ Benutzer $userId nicht gefunden.');
      return null;
    } catch (e) {
      print('❌ Fehler beim Abrufen des Benutzers $userId: $e');
      return null;
    }
  }

  @override
  Future<void> loginAs(String userId, String password, AppUser appUser) async {
    currentUser = appUser;
    print('✅ Erfolgreich als Benutzer ${appUser.firstName} eingeloggt.');
  }

  @override
  Future<String> getCurrentUserAvatarUrl() async {
    final userId = await getCurrentUserId();
    final user = await getUserAsync(userId);
    return user?.avatarUrl ?? 'assets/grafiken/famka-kreis.png';
  }

  @override
  String generateNewGroupId() {
    return _uuid.v4();
  }

  @override
  Future<void> addGroup(Group group) async {
    try {
      await _firestore
          .collection('groups')
          .doc(group.groupId)
          .set(group.toMap());
      print('✅ Gruppe ${group.groupId} erfolgreich hinzugefügt.');
    } catch (e) {
      print('❌ Fehler beim Hinzufügen der Gruppe: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateGroup(Group group) async {
    try {
      await _firestore
          .collection('groups')
          .doc(group.groupId)
          .update(group.toMap());
      print('✅ Gruppe ${group.groupId} erfolgreich aktualisiert.');
    } catch (e) {
      print('❌ Fehler beim Aktualisieren der Gruppe: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      await _firestore.collection('groups').doc(groupId).delete();
      print('✅ Gruppe $groupId erfolgreich gelöscht.');
    } catch (e) {
      print('❌ Fehler beim Löschen der Gruppe $groupId: $e');
      rethrow;
    }
  }

  @override
  Future<Group?> getGroupAsync(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (doc.exists) {
        final groupData = doc.data()!;
        final memberIds = List<String>.from(groupData['groupMemberIds'] ?? []);
        final List<AppUser> members = [];
        for (final memberId in memberIds) {
          final member = await getUserAsync(memberId);
          if (member != null) {
            members.add(member);
          }
        }
        print('✅ Gruppe $groupId erfolgreich abgerufen.');
        return Group.fromMap(groupData, members);
      }
      print('ℹ️ Gruppe $groupId nicht gefunden.');
      return null;
    } catch (e) {
      print('❌ Fehler beim Abrufen der Gruppe $groupId: $e');
      return null;
    }
  }

  @override
  Future<List<Group>> getGroupsForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('groups')
          .where('groupMemberIds', arrayContains: userId)
          .get();
      final List<Group> groups = [];
      for (var doc in snapshot.docs) {
        final groupData = doc.data();
        final memberIds = List<String>.from(groupData['groupMemberIds'] ?? []);
        final List<AppUser> members = [];
        for (final memberId in memberIds) {
          final member = await getUserAsync(memberId);
          if (member != null) {
            members.add(member);
          }
        }
        groups.add(Group.fromMap(groupData, members));
      }
      print('✅ Gruppen für Benutzer $userId erfolgreich abgerufen.');
      return groups;
    } catch (e) {
      print('❌ Fehler beim Abrufen der Gruppen für Benutzer $userId: $e');
      return [];
    }
  }

  @override
  Future<List<Group>> getGroupsOfUser() async {
    final currentUserId = await getCurrentUserId();
    return getGroupsForUser(currentUserId);
  }

  @override
  Future<List<AppUser>> getGroupMembers(String groupId) async {
    try {
      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) return [];

      final memberIds =
          List<String>.from(groupDoc.data()?['groupMemberIds'] ?? []);
      final List<AppUser> members = [];
      for (final id in memberIds) {
        final user = await getUserAsync(id);
        if (user != null) {
          members.add(user);
        }
      }
      print('✅ Gruppenmitglieder für Gruppe $groupId erfolgreich abgerufen.');
      return members;
    } catch (e) {
      print(
          '❌ Fehler beim Abrufen der Gruppenmitglieder für Gruppe $groupId: $e');
      return [];
    }
  }

  @override
  Future<void> addUserToGroup(
      AppUser user, String groupId, UserRole role) async {
    try {
      final groupRef = _firestore.collection('groups').doc(groupId);
      final groupDoc = await groupRef.get();

      if (groupDoc.exists) {
        final groupData = groupDoc.data()!;
        final List<String> currentMemberIds =
            List<String>.from(groupData['groupMemberIds'] ?? []);
        Map<String, dynamic> currentUserRoles =
            Map<String, dynamic>.from(groupData['userRoles'] ?? {});

        if (!currentMemberIds.contains(user.profilId)) {
          currentMemberIds.add(user.profilId);
        }

        currentUserRoles[user.profilId] = role.toJson();

        await groupRef.update({
          'groupMemberIds': currentMemberIds,
          'userRoles': currentUserRoles,
        });

        final existingUser = await getUserAsync(user.profilId);
        if (existingUser == null) {
          await createUser(user);
        }

        print(
            '✅ Benutzer ${user.profilId} mit Rolle ${role.name} erfolgreich zur Gruppe $groupId hinzugefügt.');
      } else {
        print('❌ Gruppe $groupId nicht gefunden.');
      }
    } catch (e) {
      print(
          '❌ Fehler beim Hinzufügen von Benutzer ${user.profilId} zur Gruppe $groupId: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeUserFromGroup(String userId, String groupId) async {
    try {
      final groupRef = _firestore.collection('groups').doc(groupId);
      final groupDoc = await groupRef.get();

      if (groupDoc.exists) {
        final groupData = groupDoc.data()!;
        final List<String> currentMemberIds =
            List<String>.from(groupData['groupMemberIds'] ?? []);
        Map<String, dynamic> currentUserRoles =
            Map<String, dynamic>.from(groupData['userRoles'] ?? {});

        currentMemberIds.remove(userId);
        currentUserRoles.remove(userId);

        await groupRef.update({
          'groupMemberIds': currentMemberIds,
          'userRoles': currentUserRoles,
        });
        print('✅ Benutzer $userId erfolgreich aus Gruppe $groupId entfernt.');
      } else {
        print('❌ Gruppe $groupId nicht gefunden.');
      }
    } catch (e) {
      print(
          '❌ Fehler beim Entfernen von Benutzer $userId aus Gruppe $groupId: $e');
      rethrow;
    }
  }

  @override
  Future<void> leaveGroup(String groupId, String userId) async {
    await removeUserFromGroup(userId, groupId);
    print('✅ Benutzer $userId hat Gruppe $groupId verlassen.');
  }

  @override
  Future<List<Group>> getAllGroups() async {
    try {
      final snapshot = await _firestore.collection('groups').get();
      final List<Group> groups = [];
      for (var doc in snapshot.docs) {
        final groupData = doc.data();
        final memberIds = List<String>.from(groupData['groupMemberIds'] ?? []);
        final List<AppUser> members = [];
        for (final memberId in memberIds) {
          final member = await getUserAsync(memberId);
          if (member != null) {
            members.add(member);
          }
        }
        groups.add(Group.fromMap(groupData, members));
      }
      print('✅ Alle Gruppen erfolgreich abgerufen.');
      return groups;
    } catch (e) {
      print('❌ Fehler beim Abrufen aller Gruppen: $e');
      return [];
    }
  }

  @override
  String generateNewEventId() {
    return _uuid.v4();
  }

  @override
  Future<SingleEvent?> getEventAsync(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        print('✅ Event $eventId erfolgreich abgerufen.');
        return SingleEvent.fromMap(doc.data()!);
      }
      print('ℹ️ Event $eventId nicht gefunden.');
      return null;
    } catch (e) {
      print('❌ Fehler beim Abrufen des Events $eventId: $e');
      return null;
    }
  }

  @override
  Future<List<SingleEvent>> getAllEvents() async {
    try {
      final snapshot = await _firestore.collection('events').get();
      print('✅ Alle Events erfolgreich abgerufen.');
      return snapshot.docs
          .map((doc) => SingleEvent.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Fehler beim Abrufen aller Events: $e');
      return [];
    }
  }

  @override
  Future<List<SingleEvent>> getEventsForGroup(String groupId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('groupId', isEqualTo: groupId)
          .get();
      print('✅ Events für Gruppe $groupId erfolgreich abgerufen.');
      return snapshot.docs
          .map((doc) => SingleEvent.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Fehler beim Abrufen der Events für Gruppe $groupId: $e');
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
      print('✅ Event ${event.singleEventId} erfolgreich erstellt.');
    } catch (e) {
      print('❌ Fehler beim Hinzufügen des Events: $e');
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
      print('✅ Event ${event.singleEventId} erfolgreich aktualisiert.');
    } catch (e) {
      print('❌ Fehler beim Aktualisieren des Events: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(String groupId, String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      print('✅ Event $eventId erfolgreich gelöscht.');
    } catch (e) {
      print('❌ Fehler beim Löschen des Events $eventId: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteSingleEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      print('✅ Einzelnes Event $eventId erfolgreich gelöscht.');
    } catch (e) {
      print('❌ Fehler beim Löschen des einzelnen Events $eventId: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeEventFromGroup(String groupId, String eventId) {
    return deleteSingleEvent(eventId);
  }
}
