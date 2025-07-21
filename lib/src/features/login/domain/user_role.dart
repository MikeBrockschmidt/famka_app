enum UserRole {
  admin,
  member,
  passiveMember,
}

extension UserRoleExtension on UserRole {
  String toJson() {
    return name;
  }

  static UserRole fromJson(String json) {
    try {
      return UserRole.values.byName(json);
    } catch (_) {
      return UserRole.member;
    }
  }
}
