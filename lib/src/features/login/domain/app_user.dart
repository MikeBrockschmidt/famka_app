class AppUser {
  final String profilId;
  final String firstName;
  final String lastName;
  final String? email; // Kann für passive Mitglieder null sein
  final String? avatarUrl;

  final String? phoneNumber; // Kann für passive Mitglieder null sein
  final String? miscellaneous;
  final String? password; // Sollte für passive Mitglieder null sein
  final String?
      managedById; // Neu: ID des aktiven Mitglieds, das dieses passive Profil verwaltet

  AppUser({
    required this.profilId,
    required this.firstName,
    required this.lastName,
    this.email, // Muss nicht mehr required sein
    this.avatarUrl,
    this.phoneNumber,
    this.miscellaneous,
    this.password,
    this.managedById, // Initialisierung des neuen Feldes
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
      'managedById': managedById, // Hinzufügen zum Map
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      profilId: map['profilId'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      email: map['email'] as String?, // Kann null sein
      avatarUrl: map['avatarUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      miscellaneous: map['miscellaneous'] as String?,
      password: map['password'] as String?,
      managedById: map['managedById'] as String?, // Lesen des neuen Feldes
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
    String? managedById, // Hinzufügen zum copyWith
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
      managedById: managedById ?? this.managedById, // Zuweisung im copyWith
    );
  }
}
