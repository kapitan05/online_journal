class UserProfile {
  final String firstName;
  final String lastName;
  final String email;
  final String street;
  final String password;
  final String city;
  final String zipCode;
  final String? profileImagePath;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.street,
    required this.password,
    required this.city,
    required this.zipCode,
    this.profileImagePath,
  });
}
