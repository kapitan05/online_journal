import 'package:hive/hive.dart';
import '../models/user_profile_model.dart';
import '../../domain/entities/user_profile.dart';

class UserRepository {
  final Box<UserProfileModel> box;

  UserRepository(this.box);

  Future<void> saveUser(UserProfile user) async {
    final model = UserProfileModel.fromEntity(user);
    // We use a fixed key 'current_user' so we always overwrite the old profile
    await box.put('current_user', model);
  }

  UserProfile? getUser() {
    final model = box.get('current_user');
    return model?.toEntity();
  }
}