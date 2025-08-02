class AppUser {
  final String profilId;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? phoneNumber;
  final String? miscellaneous;
  final String? password;
  final bool canCreateGroups;
  final String? fcmToken;

  const AppUser({
    required this.profilId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.phoneNumber,
    this.miscellaneous,
    this.password,
    this.canCreateGroups = true,
    this.fcmToken,
  });

  AppUser copyWith({
    String? profilId,
    String? email,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? phoneNumber,
    String? miscellaneous,
    String? password,
    bool? canCreateGroups,
    String? fcmToken,
  }) {
    return AppUser(
      profilId: profilId ?? this.profilId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      miscellaneous: miscellaneous ?? this.miscellaneous,
      password: password ?? this.password,
      canCreateGroups: canCreateGroups ?? this.canCreateGroups,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profilId': profilId,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'miscellaneous': miscellaneous,
      'password': password,
      'canCreateGroups': canCreateGroups,
      'fcmToken': fcmToken,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      profilId: map['profilId'] as String,
      email: map['email'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      avatarUrl: map['avatarUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      miscellaneous: map['miscellaneous'] as String?,
      password: map['password'] as String?,
      canCreateGroups: map['canCreateGroups'] as bool? ?? true,
      fcmToken: map['fcmToken'] as String?,
    );
  }
}
