import 'package:hive/hive.dart';
import '../models/user_profile_model.dart';
import '../../domain/entities/user_profile.dart';

// Repository to manage User Profiles and Authentication
// Simulates a simple user database using Hive
// email as the unique key in the database to prevent duplicate users

class UserRepository {

final Box<UserProfileModel> _usersBox; // The "Database" of all users
  final Box _sessionBox; // To remember who is currently logged in 

  UserRepository(this._usersBox, this._sessionBox);

  // SIGN UP METHOD
  Future<void> registerUser(UserProfile user) async {
    // Check if email exists in "DB"
    if (_usersBox.containsKey(user.email)) {
      throw Exception('User with this email already exists.');
    }
    
    final model = UserProfileModel.fromEntity(user);
    // Save user using Email as the Key (Unique Index)
    await _usersBox.put(user.email, model);
  }

  //  SIGN IN METHOD
  Future<UserProfile> authenticateUser(String email, String password) async {
    final userModel = _usersBox.get(email);

    if (userModel == null) {
      throw Exception('User not found.');
    }

    if (userModel.password != password) {
      throw Exception('Incorrect password.');
    }

    // Login successful: Save session
    await _sessionBox.put('current_user_email', email);
    return userModel.toEntity();
  }

  // --- CHECK SESSION ---
  Future<bool> isLoggedIn() async {
    return _sessionBox.containsKey('current_user_email');
  }

  Future<void> logout() async {
    await _sessionBox.delete('current_user_email');
  }
}