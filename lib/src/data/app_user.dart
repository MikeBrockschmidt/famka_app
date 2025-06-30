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
    required this.password,
  });
}
