import 'package:hive/hive.dart';
import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: 1)
class UserProfileModel extends HiveObject {
  @HiveField(0)
  final String firstName;

  @HiveField(1)
  final String lastName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String street;

  @HiveField(4)
  final String city;

  @HiveField(5)
  final String zipCode;

  @HiveField(6)
  final String password;

  @HiveField(7)
  final String? profileImagePath;

  UserProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.street,
    required this.city,
    required this.zipCode,
    required this.password,
    this.profileImagePath,
  });

  // Mapper: Model -> Entity
  UserProfile toEntity() => UserProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
        street: street,
        city: city,
        zipCode: zipCode,
        password: password,
        profileImagePath: profileImagePath,
      );

  // Mapper: Entity -> Model
  factory UserProfileModel.fromEntity(UserProfile user) => UserProfileModel(
        firstName: user.firstName,
        lastName: user.lastName,
        email: user.email,
        street: user.street,
        city: user.city,
        zipCode: user.zipCode,
        password: user.password,
        profileImagePath: user.profileImagePath,
      );
}
