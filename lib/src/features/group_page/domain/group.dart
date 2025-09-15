import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/login/domain/user_role.dart';

class Group {
  final String groupId;
  String groupName;
  String groupDescription;
  String? groupLocation;
  String groupAvatarUrl;
  final String creatorId;
  final List<AppUser> groupMembers;
  final Map<String, UserRole> userRoles;
  final Map<String, Map<String, dynamic>> passiveMembersData;

  Group({
    required this.groupId,
    required this.groupName,
    this.groupLocation,
    required this.groupDescription,
    required this.groupAvatarUrl,
    required this.creatorId,
    required this.groupMembers,
    required this.userRoles,
    this.passiveMembersData = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupLocation': groupLocation,
      'groupAvatarUrl': groupAvatarUrl,
      'creatorId': creatorId,
      'groupMemberIds': groupMembers.map((e) => e.profilId).toList(),
      'userRoles': userRoles.map((key, value) => MapEntry(key, value.toJson())),
      'passiveMembersData': passiveMembersData,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map, List<AppUser> members) {
    Map<String, UserRole> roles = {};
    if (map['userRoles'] is Map) {
      (map['userRoles'] as Map).forEach((key, value) {
        roles[key as String] = UserRoleExtension.fromJson(value);
      });
    }

    Map<String, Map<String, dynamic>> extractedPassiveMembersData = {};
    if (map['passiveMembersData'] is Map) {
      (map['passiveMembersData'] as Map).forEach((key, value) {
        if (value is Map<String, dynamic>) {
          extractedPassiveMembersData[key as String] = value;
        }
      });
    }

    // Debug-Ausgabe für die passiven Mitglieder
    // ...existing code...

    return Group(
      groupId: map['groupId'] as String,
      groupName: map['groupName'] as String,
      groupLocation: map['groupLocation'] as String?,
      groupDescription: map['groupDescription'] as String,
      groupAvatarUrl: map['groupAvatarUrl'] as String,
      creatorId: map['creatorId'] as String,
      groupMembers: members,
      userRoles: roles,
      passiveMembersData: extractedPassiveMembersData,
    );
  }

  Group copyWith({
    String? groupId,
    String? groupName,
    String? groupLocation,
    String? groupDescription,
    String? groupAvatarUrl,
    String? creatorId,
    List<AppUser>? groupMembers,
    Map<String, UserRole>? userRoles,
    Map<String, Map<String, dynamic>>? passiveMembersData,
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
      passiveMembersData: passiveMembersData ?? this.passiveMembersData,
    );
  }

  AppUser? getCreator() {
    try {
      return groupMembers.firstWhere((user) => user.profilId == creatorId);
    } catch (e) {
      return null;
    }
  }
}
