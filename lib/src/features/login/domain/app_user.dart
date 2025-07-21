class AppUser {
  final String profilId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? avatarUrl;

  final String? phoneNumber;
  final String? miscellaneous;
  final String? password;
  final String? managedById;

  AppUser({
    required this.profilId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.avatarUrl,
    this.phoneNumber,
    this.miscellaneous,
    this.password,
    this.managedById,
  });

  Map<String, dynamic> toMap() {
    return {
      'profilId': profilId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
      'miscellaneous': miscellaneous,
      'password': password,
      'managedById': managedById,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      profilId: map['profilId'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      miscellaneous: map['miscellaneous'] as String?,
      password: map['password'] as String?,
      managedById: map['managedById'] as String?,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser.fromMap(json);

  AppUser copyWith({
    String? profilId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? miscellaneous,
    String? password,
    String? managedById,
  }) {
    return AppUser(
      profilId: profilId ?? this.profilId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      miscellaneous: miscellaneous ?? this.miscellaneous,
      password: password ?? this.password,
      managedById: managedById ?? this.managedById,
    );
  }
}
