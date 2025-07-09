import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String profilId;
  final String firstName;
  final String lastName;
  final DateTime birthDate;
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final String miscellaneous;
  final String password;

  AppUser({
    required this.profilId,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.email,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.miscellaneous,
    this.password = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'profilId': profilId,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': Timestamp.fromDate(birthDate),
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'miscellaneous': miscellaneous,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      profilId: map['profilId'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      birthDate: (map['birthDate'] as Timestamp).toDate(),
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String,
      avatarUrl: map['avatarUrl'] as String,
      miscellaneous: map['miscellaneous'] as String,
      password: '',
    );
  }

  AppUser copyWith({
    String? profilId,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? miscellaneous,
    String? password,
  }) {
    return AppUser(
      profilId: profilId ?? this.profilId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      miscellaneous: miscellaneous ?? this.miscellaneous,
      password: password ?? this.password,
    );
  }
}
