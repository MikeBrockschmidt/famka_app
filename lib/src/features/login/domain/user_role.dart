enum UserRole {
  admin,
  member,
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
