enum UserRole {
  admin,
  member,
  passiveMember, // Neue Rolle für passive Mitglieder
}

extension UserRoleExtension on UserRole {
  String toJson() {
    return name;
  }

  static UserRole fromJson(String json) {
    try {
      return UserRole.values.byName(json);
    } catch (_) {
      return UserRole.member; // Standardwert, falls unbekannt
    }
  }
}
