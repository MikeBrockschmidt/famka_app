import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famka_app/src/data/database_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:famka_app/src/features/login/domain/user_role.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  AuthRepository get auth => throw UnimplementedError(
      'AuthRepository is not implemented in FirestoreDatabaseRepository. It should be injected separately.');

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
  Future<void> saveUserFCMToken(String userId, String? token) async {
    if (token == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'fcmToken': token});
      print('✅ FCM-Token für Benutzer $userId erfolgreich gespeichert.');
    } catch (e) {
      print('❌ Fehler beim Speichern des FCM-Tokens für Benutzer $userId: $e');
    }
  }

  String generateNewGroupId() {
    return _uuid.v4();
  }

  @override
  Future<void> addGroup(Group group) async {
    try {
      final Map<String, dynamic> dataToSave = group.toMap();
      print('DEBUG: Daten, die an Firestore gesendet werden: $dataToSave');
      await _firestore.collection('groups').doc(group.groupId).set(dataToSave);
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

  Future<List<AppUser>> _fetchGroupMembersAndPassive(List<String> memberIds,
      Map<String, Map<String, dynamic>> passiveMembersData) async {
    print('🔍 LADEN DER GRUPPENMITGLIEDER:');
    print('  - Mitglieder-IDs: $memberIds');
    print('  - Passive Mitglieder: ${passiveMembersData.keys.toList()}');

    final List<AppUser> members = [];
    final Set<String> loadedMemberIds = {}; // Hilft, Duplikate zu vermeiden

    // Erst alle regulären Benutzer aus der Mitgliederliste laden
    for (final memberId in memberIds) {
      // Überprüfen, ob der Benutzer existiert
      final doc = await _firestore.collection('users').doc(memberId).get();
      if (doc.exists) {
        // Regulärer Benutzer existiert in der Datenbank
        final member = AppUser.fromMap(doc.data()!);
        members.add(member);
        loadedMemberIds.add(memberId);
        print('✅ Aktiver Benutzer $memberId erfolgreich geladen.');
      } else if (passiveMembersData.containsKey(memberId)) {
        // Kein regulärer Benutzer, aber in passiveMembersData vorhanden
        final passiveData = passiveMembersData[memberId]!;
        final dummyPassiveUser = AppUser(
          profilId: memberId,
          firstName: passiveData['firstName'] ?? 'Passives Mitglied',
          lastName: passiveData['lastName'] ?? '(Unbekannt)',
          email: '',
          phoneNumber: '',
          avatarUrl:
              passiveData['avatarUrl'] ?? 'assets/grafiken/famka-kreis.png',
          password: '',
          miscellaneous: null,
        );
        members.add(dummyPassiveUser);
        loadedMemberIds.add(memberId);
        print('✅ Passives Mitglied $memberId aus memberIds geladen.');
      } else {
        // Weder regulärer noch passiver Benutzer - sollte nicht in der Liste sein
        print('⚠️ Ungültige Benutzer-ID gefunden: $memberId - wird ignoriert');
        // Wir fügen diesen Benutzer nicht zur Liste hinzu, um die Liste zu bereinigen
      }
    }

    // WICHTIG: Wir laden alle passiven Mitglieder aus passiveMembersData, aber OHNE Duplikate
    // Diese Änderung stellt sicher, dass passive Mitglieder, die in passiveMembersData sind,
    // aber nicht in memberIds, wieder in der UI angezeigt werden.
    for (final passiveMemberId in passiveMembersData.keys) {
      // Überprüfen, ob das passive Mitglied bereits geladen wurde
      if (!loadedMemberIds.contains(passiveMemberId)) {
        final passiveData = passiveMembersData[passiveMemberId]!;
        final dummyPassiveUser = AppUser(
          profilId: passiveMemberId,
          firstName: passiveData['firstName'] ?? 'Passives Mitglied',
          lastName: passiveData['lastName'] ?? '(Unbekannt)',
          email: '',
          phoneNumber: '',
          avatarUrl:
              passiveData['avatarUrl'] ?? 'assets/grafiken/famka-kreis.png',
          password: '',
          miscellaneous: null,
        );
        members.add(dummyPassiveUser);
        loadedMemberIds.add(passiveMemberId);
        print('✅ Zusätzliches passives Mitglied $passiveMemberId hinzugefügt.');
      }
    }

    print('✅ Insgesamt ${members.length} Mitglieder geladen (inkl. passive).');
    return members;
  }

  @override
  Future<Group?> getGroupAsync(String groupId) async {
    try {
      print('🔄 Lade Gruppe mit ID: $groupId');

      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (doc.exists) {
        final groupData = doc.data()!;

        // Mitglieder-IDs laden
        List<String> memberIds =
            List<String>.from(groupData['groupMemberIds'] ?? []);

        // Passive Mitglieder-Daten laden
        final Map<String, dynamic> passiveMembersDataRaw =
            groupData['passiveMembersData'] ?? {};
        final Map<String, Map<String, dynamic>> extractedPassiveMembersData =
            {};

        passiveMembersDataRaw.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            // Alle passiven Mitglieder hinzufügen, unabhängig davon, ob sie in memberIds sind
            extractedPassiveMembersData[key] = value;
            if (!memberIds.contains(key)) {
              print(
                  'ℹ️ Passives Mitglied $key ist nicht in groupMemberIds, wird aber trotzdem geladen');
            }
          }
        });

        // Mitglieder laden
        final List<AppUser> members = await _fetchGroupMembersAndPassive(
            memberIds, extractedPassiveMembersData);

        // Erstelle und gib die Gruppe zurück
        print(
            '✅ Gruppe $groupId erfolgreich abgerufen mit ${members.length} Mitgliedern.');
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
      print('🔄 Lade Gruppen für Benutzer: $userId');

      final snapshot = await _firestore
          .collection('groups')
          .where('groupMemberIds', arrayContains: userId)
          .get();

      final List<Group> groups = [];

      for (var doc in snapshot.docs) {
        final groupData = doc.data();
        List<String> memberIds =
            List<String>.from(groupData['groupMemberIds'] ?? []);

        // Bereinigen der Mitgliederliste - entferne nicht mehr existierende Benutzer
        List<String> validMemberIds = [];
        bool membersChanged = false;

        for (final memberId in memberIds) {
          final userExists = await _userExists(memberId);
          if (userExists) {
            validMemberIds.add(memberId);
          } else {
            // Benutzer existiert nicht mehr in der users-Sammlung
            // Überprüfen, ob es ein passives Mitglied ist
            final passiveMembersDataRaw = groupData['passiveMembersData'] ?? {};
            final isPassiveMember = passiveMembersDataRaw.containsKey(memberId);

            if (isPassiveMember) {
              // Passive Mitglieder dürfen in der Liste bleiben
              validMemberIds.add(memberId);
              print(
                  'ℹ️ Passives Mitglied $memberId bleibt in der Gruppe ${groupData['name']}');
            } else {
              // Ungültige ID entfernen
              membersChanged = true;
              print(
                  '⚠️ Benutzer $memberId existiert nicht mehr und wird aus Gruppe ${groupData['name']} entfernt');
            }
          }
        }

        // Aktualisiere die Gruppe, wenn sich die Mitgliederliste geändert hat
        if (membersChanged) {
          await _firestore.collection('groups').doc(doc.id).update({
            'groupMemberIds': validMemberIds,
          });
          print(
              '✅ Mitgliederliste für Gruppe ${groupData['name']} aktualisiert');
        }

        // Passive Mitglieder-Daten laden
        final Map<String, dynamic> passiveMembersDataRaw =
            groupData['passiveMembersData'] ?? {};
        final Map<String, Map<String, dynamic>> extractedPassiveMembersData =
            {};

        passiveMembersDataRaw.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            // Alle passiven Mitglieder hinzufügen, unabhängig davon, ob sie in validMemberIds sind
            extractedPassiveMembersData[key] = value;
            if (!validMemberIds.contains(key)) {
              print(
                  'ℹ️ Passives Mitglied $key ist nicht in validMemberIds, wird aber trotzdem geladen');
            }
          }
        });

        // Mitglieder laden und Gruppe erstellen
        final List<AppUser> members = await _fetchGroupMembersAndPassive(
            validMemberIds, extractedPassiveMembersData);
        groups.add(Group.fromMap(groupData, members));
      }

      print(
          '✅ ${groups.length} Gruppen für Benutzer $userId erfolgreich abgerufen.');
      return groups;
    } catch (e) {
      print('❌ Fehler beim Abrufen der Gruppen für Benutzer $userId: $e');
      return [];
    }
  }

  // Hilfsmethode zum Überprüfen, ob ein Benutzer existiert
  Future<bool> _userExists(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('❌ Fehler beim Überprüfen der Existenz von Benutzer $userId: $e');
      return false;
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
      print('🔄 Lade Gruppenmitglieder für Gruppe: $groupId');

      final groupDoc = await _firestore.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        print('❌ Gruppe $groupId nicht gefunden.');
        return [];
      }

      final groupData = groupDoc.data()!;
      List<String> memberIds =
          List<String>.from(groupData['groupMemberIds'] ?? []);

      // Passive Mitglieder-Daten laden
      final Map<String, dynamic> passiveMembersDataRaw =
          groupData['passiveMembersData'] ?? {};
      final Map<String, Map<String, dynamic>> extractedPassiveMembersData = {};

      passiveMembersDataRaw.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          // Alle passiven Mitglieder hinzufügen, unabhängig davon, ob sie in memberIds sind
          extractedPassiveMembersData[key] = value;
          if (!memberIds.contains(key)) {
            print(
                'ℹ️ Passives Mitglied $key ist nicht in groupMemberIds, wird aber trotzdem geladen');
          }
        }
      });

      // Mitglieder laden
      final List<AppUser> members = await _fetchGroupMembersAndPassive(
          memberIds, extractedPassiveMembersData);

      print(
          '✅ ${members.length} Gruppenmitglieder für Gruppe $groupId erfolgreich abgerufen.');
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
        List<String> currentMemberIds =
            List<String>.from(groupData['groupMemberIds'] ?? []);
        Map<String, dynamic> currentUserRoles =
            Map<String, dynamic>.from(groupData['userRoles'] ?? {});
        Map<String, dynamic> currentPassiveMembersData =
            Map<String, dynamic>.from(groupData['passiveMembersData'] ?? {});

        if (!currentMemberIds.contains(user.profilId)) {
          currentMemberIds.add(user.profilId);
        }

        currentUserRoles[user.profilId] = role.toJson();

        if (role == UserRole.passiveMember) {
          currentPassiveMembersData[user.profilId] = {
            'firstName': user.firstName,
            'lastName': user.lastName,
            'avatarUrl': user.avatarUrl,
          };
        } else {
          currentPassiveMembersData.remove(user.profilId);
        }

        await groupRef.update({
          'groupMemberIds': currentMemberIds,
          'userRoles': currentUserRoles,
          'passiveMembersData': currentPassiveMembersData,
        });

        if (role != UserRole.passiveMember) {
          final existingUser = await getUserAsync(user.profilId);
          if (existingUser == null) {
            await createUser(user);
          } else {
            await updateUser(user);
          }
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
      print(
          '� ENTFERNE BENUTZER: Starte Entfernung von $userId aus Gruppe $groupId');

      // Gruppe direkt abrufen ohne Cache
      final groupRef = _firestore.collection('groups').doc(groupId);
      final groupDoc = await groupRef.get();

      if (groupDoc.exists) {
        print('🔴 Gruppe $groupId gefunden.');
        final groupData = groupDoc.data()!;

        // Daten abrufen und Logs vor der Änderung ausgeben
        List<String> currentMemberIds =
            List<String>.from(groupData['groupMemberIds'] ?? []);
        Map<String, dynamic> currentUserRoles =
            Map<String, dynamic>.from(groupData['userRoles'] ?? {});
        Map<String, dynamic> currentPassiveMembersData =
            Map<String, dynamic>.from(groupData['passiveMembersData'] ?? {});

        print('� VOR DEM ENTFERNEN:');
        print('  - Member in memberIds: ${currentMemberIds.contains(userId)}');
        print(
            '  - Member in userRoles: ${currentUserRoles.containsKey(userId)}');
        print(
            '  - Member in passiveMembersData: ${currentPassiveMembersData.containsKey(userId)}');
        print('  - Alle memberIds: $currentMemberIds');
        print(
            '  - Alle passiveMembersData keys: ${currentPassiveMembersData.keys.toList()}');

        // Explizit aus allen drei Datenstrukturen entfernen
        currentMemberIds.remove(userId);
        currentUserRoles.remove(userId);
        currentPassiveMembersData.remove(userId);

        print('� NACH DEM ENTFERNEN:');
        print('  - Member in memberIds: ${currentMemberIds.contains(userId)}');
        print(
            '  - Member in userRoles: ${currentUserRoles.containsKey(userId)}');
        print(
            '  - Member in passiveMembersData: ${currentPassiveMembersData.containsKey(userId)}');
        print('  - Alle memberIds: $currentMemberIds');
        print(
            '  - Alle passiveMembersData keys: ${currentPassiveMembersData.keys.toList()}');

        // Direkt updateMap verwenden für maximale Kontrolle
        Map<String, dynamic> updateMap = {
          'groupMemberIds': currentMemberIds,
          'userRoles': currentUserRoles,
          'passiveMembersData': currentPassiveMembersData,
        };

        print('🔴 Update Map für Firestore: $updateMap');

        // Direkt ohne Transaktion ausführen
        await groupRef.update(updateMap);

        // Direkt überprüfen, ob die Änderungen gespeichert wurden
        final updatedDoc = await groupRef.get();
        final updatedData = updatedDoc.data()!;
        final List<String> updatedMemberIds =
            List<String>.from(updatedData['groupMemberIds'] ?? []);
        final Map<String, dynamic> updatedPassiveMembersData =
            Map<String, dynamic>.from(updatedData['passiveMembersData'] ?? {});

        print('🔴 NACH DEM SPEICHERN IN DER DATENBANK:');
        print('  - Member in memberIds: ${updatedMemberIds.contains(userId)}');
        print(
            '  - Member in passiveMembersData: ${updatedPassiveMembersData.containsKey(userId)}');
        print('  - Alle memberIds: $updatedMemberIds');
        print(
            '  - Alle passiveMembersData keys: ${updatedPassiveMembersData.keys.toList()}');

        // Cache leeren, um sicherzustellen, dass beim nächsten Laden neue Daten geladen werden
        _currentGroupInternal = null;
        currentGroup = null;

        print(
            '✅ Benutzer $userId erfolgreich aus Gruppe $groupId entfernt und Cache geleert.');
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
        List<String> memberIds =
            List<String>.from(groupData['groupMemberIds'] ?? []);

        final Map<String, dynamic> passiveMembersDataRaw =
            groupData['passiveMembersData'] ?? {};
        final Map<String, Map<String, dynamic>> extractedPassiveMembersData =
            {};
        passiveMembersDataRaw.forEach((key, value) {
          if (value is Map<String, dynamic>) {
            extractedPassiveMembersData[key] = value;
          }
        });

        final List<AppUser> members = await _fetchGroupMembersAndPassive(
            memberIds, extractedPassiveMembersData);
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

      // Wenn der Termin eine Erinnerung hat, sicherstellen dass die Benachrichtigung geplant wird
      if (event.hasReminder == true && event.reminderOffset != null) {
        await sendAppointmentNotification(event);
      }
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

  @override
  Future<void> createUserFromGoogleSignIn({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
  }) async {
    final user = AppUser(
      profilId: uid,
      email: email ?? '',
      firstName: displayName?.split(' ').first ?? '',
      lastName: displayName?.split(' ').length == 2
          ? displayName!.split(' ').last
          : '',
      avatarUrl: photoUrl ?? 'assets/grafiken/famka-kreis.png',
      password: '',
      miscellaneous: null,
    );

    final existingUser = await getUserAsync(uid);
    if (existingUser == null) {
      await createUser(user);
      print('✅ Google-Nutzer $uid erfolgreich erstellt.');
    } else {
      await updateUser(user);
      print('ℹ️ Google-Nutzer $uid existiert bereits und wurde aktualisiert.');
    }

    currentUser = user;
  }

  @override
  Future<void> sendAppointmentNotification(SingleEvent event) async {
    try {
      if (event.hasReminder != true ||
          event.reminderOffset == null ||
          event.reminderOffset?.isEmpty == true) {
        print('Keine Erinnerung für diesen Termin eingestellt.');
        return;
      }

      // Die Erinnerung wird automatisch durch die Firebase Cloud Function
      // "scheduleReminder" geplant, wenn das Event in Firestore erstellt wird.
      // Wir müssen hier nichts weiter tun, außer sicherzustellen,
      // dass die hasReminder und reminderOffset Felder korrekt gesetzt sind.

      print('✅ Erinnerung für Termin ${event.singleEventName} wird geplant.');
    } catch (e) {
      print('❌ Fehler beim Planen der Terminerinnerung: $e');
      rethrow;
    }
  }

  // Ohne Override-Annotation, da sie nicht in der Basisklasse existiert
  Future<void> createUserFromAppleSignIn({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
  }) {
    throw UnimplementedError();
  }

  // Ohne Override-Annotation, da sie nicht in der Basisklasse existiert
  Future<void> getGroupsStream(String userId) {
    throw UnimplementedError();
  }

  // Methode zum Speichern der Mitglieder-Reihenfolge
  Future<void> updateGroupMemberOrder(String groupId, List<String> newMemberOrder) async {
    try {
      print('🔄 Aktualisiere Mitgliederreihenfolge für Gruppe $groupId');
      print('Neue Reihenfolge: $newMemberOrder');
      
      await _firestore.collection('groups').doc(groupId).update({
        'groupMemberIds': newMemberOrder,
      });
      
      print('✅ Gruppenmitglieder-Reihenfolge erfolgreich aktualisiert.');
    } catch (e) {
      print('❌ Fehler beim Aktualisieren der Mitgliederreihenfolge: $e');
      rethrow;
    }
  }
}
