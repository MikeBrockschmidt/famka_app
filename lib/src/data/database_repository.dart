import 'package:famka_app/src/data/app_user.dart';
import 'package:famka_app/src/data/auth_repository.dart';
import 'package:famka_app/src/features/group_page/domain/group.dart';
import 'package:famka_app/src/features/appointment/domain/single_event.dart';

abstract class DatabaseRepository {
  // DatabaseRepository get auth => null;
  AuthRepository get auth;

  Future<String> getCurrentUserId();
  Future<List<Group>> getGroupsForUser(String userId);
  Future<List<Group>> getGroupsOfUser();
  Future<List<AppUser>> getAllUsers();
  List<SingleEvent> getAllEvents();
  Future<void> addUserToGroup(AppUser user, String groupId);
  Future<void> createEvent(SingleEvent event);
  Future<void> addGroup(Group group);
  Future<void> createUser(AppUser user);
  Future<void> deleteEvent(String groupId, String eventId);
  Future<void> deleteGroup(String groupId);
  Future<void> deleteUser(String userId);
  SingleEvent? getEvent(String eventId);
  Group? getGroup(String groupId);
  AppUser? getUser(String userId);
  AppUser? currentUser;
  Future<void> removeUserFromGroup(String userId, String groupId);
  Future<void> updateEvent(String groupId, SingleEvent event);
  Future<void> updateGroup(Group group);
  Future<void> updateUser(AppUser user);
  Future<List<AppUser>> getGroupMembers(String groupId);
  List<Group> getAllGroups();
  String generateNewGroupId();
  Future<void> loginAs(String userId, String password, AppUser appUser);
  Future<String> getCurrentUserAvatarUrl();
  Future<void> leaveGroup(String groupId, String userId);
}
