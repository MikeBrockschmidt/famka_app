import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/login/domain/user_role.dart';

class Group {
  final String groupId;
  final String groupName;
  final String groupLocation;
  final String groupDescription;
  final String groupAvatarUrl;
  final String creatorId;
  final List<AppUser> groupMembers;
  final Map<String, UserRole> userRoles;

  const Group({
    required this.groupId,
    required this.groupName,
    required this.groupLocation,
    required this.groupDescription,
    required this.groupAvatarUrl,
    required this.creatorId,
    required this.groupMembers,
    required this.userRoles,
  });

  Group copyWith({
    String? groupId,
    String? groupName,
    String? groupLocation,
    String? groupDescription,
    String? groupAvatarUrl,
    String? creatorId,
    List<AppUser>? groupMembers,
    Map<String, UserRole>? userRoles,
  }) {
    return Group(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      groupLocation: groupLocation ?? this.groupLocation,
      groupDescription: groupDescription ?? this.groupDescription,
      groupAvatarUrl: groupAvatarUrl ?? this.groupAvatarUrl,
      creatorId: creatorId ?? this.creatorId,
      groupMembers: groupMembers ?? this.groupMembers,
      userRoles: userRoles ?? this.userRoles,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'groupLocation': groupLocation,
      'groupDescription': groupDescription,
      'groupAvatarUrl': groupAvatarUrl,
      'creatorId': creatorId,
      'groupMemberIds': groupMembers.map((e) => e.profilId).toList(),
      'userRoles': userRoles.map((key, role) => MapEntry(key, role.toJson())),
    };
  }

  factory Group.fromMap(Map<String, dynamic> map, List<AppUser> members) {
    return Group(
      groupId: map['groupId'] as String,
      groupName: map['groupName'] as String,
      groupLocation: map['groupLocation'] as String,
      groupDescription: map['groupDescription'] as String,
      groupAvatarUrl: map['groupAvatarUrl'] as String,
      creatorId: map['creatorId'] as String,
      groupMembers: members,
      userRoles: (map['userRoles'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, UserRoleExtension.fromJson(value)),
      ),
    );
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError(
        'Use Group.fromMap(map, members) with fetched members.');
  }

  AppUser? getCreator() {
    try {
      return groupMembers.firstWhere((user) => user.profilId == creatorId);
    } catch (e) {
      return null;
    }
  }
}
