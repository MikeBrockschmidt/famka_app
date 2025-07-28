// lib/src/features/group_page/domain/group.dart
import 'package:famka_app/src/features/login/domain/app_user.dart';
import 'package:famka_app/src/features/login/domain/user_role.dart';

class Group {
  final String groupId;
  String groupName;
  String groupDescription;
  String? groupLocation; // ZURÜCKGEFÜHRT als optionaler String
  String groupAvatarUrl;
  final String creatorId; // Wieder creatorId genannt, um UI anzupassen
  final List<AppUser> groupMembers; // Liste der AppUser-Objekte
  final Map<String, UserRole> userRoles;
  final Map<String, Map<String, dynamic>>
      passiveMembersData; // Beibehalten für passive Mitglieder

  Group({
    required this.groupId,
    required this.groupName,
    this.groupLocation, // Optionaler Parameter
    required this.groupDescription,
    required this.groupAvatarUrl,
    required this.creatorId,
    required this.groupMembers,
    required this.userRoles,
    this.passiveMembersData = const {}, // Initialisierung des Feldes
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupLocation': groupLocation, // Hinzugefügt
      'groupAvatarUrl': groupAvatarUrl,
      'creatorId': creatorId, // Hinzugefügt
      'groupMemberIds':
          groupMembers.map((e) => e.profilId).toList(), // Speichert IDs
      'userRoles': userRoles.map((key, value) => MapEntry(key, value.toJson())),
      'passiveMembersData': passiveMembersData, // Beibehalten
    };
  }

  factory Group.fromMap(Map<String, dynamic> map, List<AppUser> members) {
    // Umwandlung von userRoles
    Map<String, UserRole> roles = {};
    if (map['userRoles'] is Map) {
      (map['userRoles'] as Map).forEach((key, value) {
        roles[key as String] = UserRoleExtension.fromJson(value);
      });
    }

    // Extrahieren der passiveMembersData
    Map<String, Map<String, dynamic>> extractedPassiveMembersData = {};
    if (map['passiveMembersData'] is Map) {
      (map['passiveMembersData'] as Map).forEach((key, value) {
        if (value is Map<String, dynamic>) {
          extractedPassiveMembersData[key as String] = value;
        }
      });
    }

    return Group(
      groupId: map['groupId'] as String,
      groupName: map['groupName'] as String,
      groupLocation: map['groupLocation'] as String?, // Hinzugefügt
      groupDescription: map['groupDescription'] as String,
      groupAvatarUrl: map['groupAvatarUrl'] as String,
      creatorId: map['creatorId'] as String, // Hinzugefügt
      groupMembers: members, // Die Liste der AppUser-Objekte
      userRoles: roles,
      passiveMembersData: extractedPassiveMembersData,
    );
  }

  // Ihr copyWith und getCreator()
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
