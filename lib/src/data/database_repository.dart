import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';
import 'package:famka_app/src/features/login/domain/user_role.dart';

abstract class DatabaseRepository {
  AppUser? currentUser;
  Group? currentGroup;

  AuthRepository get auth;

  Future<String> getCurrentUserId();
  Future<List<AppUser>> getAllUsers();
  Future<void> createUser(AppUser user);
  Future<void> updateUser(AppUser user);
  Future<void> deleteUser(String userId);

  Future<AppUser?> getUserAsync(String userId);

  Future<void> createUserFromGoogleSignIn({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
  });

  Future<void> loginAs(String userId, String password, AppUser appUser);

  Future<String> getCurrentUserAvatarUrl();

  String generateNewGroupId();
  Future<void> addGroup(Group group);
  Future<void> updateGroup(Group group);
  Future<void> deleteGroup(String groupId);

  Future<Group?> getGroupAsync(String groupId);

  Future<List<Group>> getGroupsForUser(String userId);
  Future<List<Group>> getGroupsOfUser();
  Future<List<AppUser>> getGroupMembers(String groupId);
  Future<void> addUserToGroup(AppUser user, String groupId, UserRole role);
  Future<void> removeUserFromGroup(String userId, String groupId);
  Future<void> leaveGroup(String groupId, String userId);

  Future<List<Group>> getAllGroups();

  String generateNewEventId();

  Future<SingleEvent?> getEventAsync(String eventId);

  Future<List<SingleEvent>> getAllEvents();

  Future<List<SingleEvent>> getEventsForGroup(String groupId);

  Future<void> createEvent(SingleEvent event);
  Future<void> updateEvent(String groupId, SingleEvent event);
  Future<void> deleteEvent(String groupId, String eventId);
  Future<void> deleteSingleEvent(String eventId);
  Future<void> removeEventFromGroup(String groupId, String eventId);
}
