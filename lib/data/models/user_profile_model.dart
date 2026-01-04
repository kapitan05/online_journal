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

  UserProfileModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.street,
    required this.city,
    required this.zipCode,
  });

  // Mapper: Model -> Entity
  UserProfile toEntity() => UserProfile(
    firstName: firstName,
    lastName: lastName,
    email: email,
    street: street,
    city: city,
    zipCode: zipCode,
  );

  // Mapper: Entity -> Model
  factory UserProfileModel.fromEntity(UserProfile user) => UserProfileModel(
    firstName: user.firstName,
    lastName: user.lastName,
    email: user.email,
    street: user.street,
    city: user.city,
    zipCode: user.zipCode,
  );
}