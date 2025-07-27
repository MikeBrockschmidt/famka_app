import 'package:famka_app/src/features/login/domain/user_role.dart'; // Sicherstellen, dass dies importiert ist

class AppUser {
  final String profilId;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? phoneNumber; // Hinzugefügt, falls noch nicht vorhanden
  final String? miscellaneous; // Hinzugefügt, falls noch nicht vorhanden
  final String? password; // Hinzugefügt, falls noch nicht vorhanden
  final bool canCreateGroups; // NEUES FELD HINZUGEFÜGT

  const AppUser({
    required this.profilId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.phoneNumber,
    this.miscellaneous,
    this.password,
    this.canCreateGroups = true, // Standardmäßig true setzen
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
    bool? canCreateGroups, // NEUES FELD HINZUGEFÜGT
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
      canCreateGroups:
          canCreateGroups ?? this.canCreateGroups, // NEUES FELD HINZUGEFÜGT
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
      'canCreateGroups': canCreateGroups, // NEUES FELD HINZUGEFÜGT
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
      password: map['password']
          as String?, // Passwörter sollten nicht direkt im AppUser-Modell gespeichert werden, es sei denn, es ist gehasht.
      canCreateGroups: map['canCreateGroups'] as bool? ??
          true, // NEUES FELD HINZUGEFÜGT (Standardwert bei null)
    );
  }

  // fromJson ist hier nicht mehr notwendig, da fromMap verwendet wird.
  // factory AppUser.fromJson(Map<String, dynamic> json) {
  //   throw UnimplementedError('Use AppUser.fromMap(map)');
  // }
}
