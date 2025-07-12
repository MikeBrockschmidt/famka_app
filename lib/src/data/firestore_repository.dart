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
    try {
      final snapshot = await _firestore.collection('users').get();
      print('✅ Alle Benutzer erfolgreich abgerufen.');
      return snapshot.docs.map((doc) => AppUser.fromMap(doc.data()!)).toList();
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
      print('❌ Fehler beim Löschen des Benutzers: $e');
      rethrow;
    }
  }

  @override
  Future<AppUser?> getUserAsync(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Fehler beim Abrufen des Benutzers $userId: $e');
      return null;
    }
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
    try {
      await _firestore
          .collection('groups')
          .doc(group.groupId)
          .set(group.toMap());
      currentGroup = group;
      print(
          '✅ Gruppe "${group.groupName}" mit ID "${group.groupId}" erfolgreich in Firestore gespeichert.');
    } catch (e) {
      print('❌ Fehler beim Speichern der Gruppe in Firestore: $e');
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
      currentGroup = group;
      print('✅ Gruppe ${group.groupName} erfolgreich aktualisiert.');
    } catch (e) {
      print('❌ Fehler beim Aktualisieren der Gruppe: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      await _firestore.collection('groups').doc(groupId).delete();
      if (currentGroup?.groupId == groupId) {
        currentGroup = null;
      }
      print('✅ Gruppe $groupId erfolgreich gelöscht.');
    } catch (e) {
      print('❌ Fehler beim Löschen der Gruppe: $e');
      rethrow;
    }
  }

  @override
  Future<Group?> getGroupAsync(String groupId) async {
    try {
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
    } catch (e) {
      print('❌ Fehler beim Abrufen der Gruppe $groupId: $e');
      return null;
    }
  }

  @override
  Future<List<Group>> getGroupsForUser(String userId) async {
    try {
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
      print('✅ Gruppen für Benutzer $userId erfolgreich abgerufen.');
      return groups;
    } catch (e) {
      print('❌ Fehler beim Abrufen der Gruppen für Benutzer $userId: $e');
      return [];
    }
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
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'groupMemberIds': FieldValue.arrayUnion([user.profilId]),
      });
      if (currentGroup?.groupId == groupId) {
        currentGroup = await getGroupAsync(groupId);
      }
      print('✅ Benutzer ${user.profilId} zur Gruppe $groupId hinzugefügt.');
    } catch (e) {
      print('❌ Fehler beim Hinzufügen des Benutzers zur Gruppe: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeUserFromGroup(String userId, String groupId) async {
    try {
      await _firestore.collection('groups').doc(groupId).update({
        'groupMemberIds': FieldValue.arrayRemove([userId]),
      });
      if (currentGroup?.groupId == groupId) {
        currentGroup = await getGroupAsync(groupId);
      }
      print('✅ Benutzer $userId aus Gruppe $groupId entfernt.');
    } catch (e) {
      print('❌ Fehler beim Entfernen des Benutzers aus der Gruppe: $e');
      rethrow;
    }
  }

  @override
  Future<void> leaveGroup(String groupId, String userId) async {
    try {
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
      print('✅ Benutzer $userId hat Gruppe $groupId verlassen.');
    } catch (e) {
      print('❌ Fehler beim Verlassen der Gruppe: $e');
      rethrow;
    }
  }

  @override
  Future<List<Group>> getAllGroups() async {
    try {
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
      print('✅ Alle Gruppen erfolgreich abgerufen.');
      return groups;
    } catch (e) {
      print('❌ Fehler beim Abrufen aller Gruppen: $e');
      return [];
    }
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
      print('❌ Fehler beim Abrufen des Events $eventId: $e');
      return null;
    }
  }

  @override
  Future<List<SingleEvent>> getAllEvents() async {
    try {
      final querySnapshot = await _firestore.collection('events').get();
      print('✅ Alle Events erfolgreich abgerufen.');
      return querySnapshot.docs
          .map((doc) => SingleEvent.fromMap(doc.data()!))
          .toList();
    } catch (e) {
      print('❌ Fehler beim Abrufen aller Events: $e');
      return [];
    }
  }

  @override
  Future<List<SingleEvent>> getEventsForGroup(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('events')
          .where('groupId', isEqualTo: groupId)
          .get();
      print('✅ Events für Gruppe $groupId erfolgreich abgerufen.');
      return querySnapshot.docs
          .map((doc) => SingleEvent.fromMap(doc.data()!))
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
      print('✅ SingleEvent $eventId erfolgreich gelöscht.');
    } catch (e) {
      print('❌ Fehler beim Löschen des SingleEvents $eventId: $e');
      rethrow;
    }
  }
}
