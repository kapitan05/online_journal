import 'package:hive/hive.dart';
import '../../domain/repositories/user_repository.dart'; // Import Interface
import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

// // Repository to manage User Profiles and Authentication
// // Simulates a simple user database using Hive
// // email as the unique key in the database to prevent duplicate users

class HiveUserRepository implements UserRepository { 

  final Box<UserProfileModel> _usersBox;  // The "Database" of all users
  final Box _sessionBox; // To remember who is currently logged in 

  HiveUserRepository(this._usersBox, this._sessionBox);

  // SIGN UP METHOD
  @override
  Future<void> registerUser(UserProfile user) async {
    // Check if email exists in "DB"
    if (_usersBox.containsKey(user.email)) {
      throw Exception('User with this email already exists.');
    }
    // Save user using Email as the Key (Unique Index)
    final model = UserProfileModel.fromEntity(user);
    await _usersBox.put(user.email, model);
  }

  @override
  Future<UserProfile> authenticateUser(String email, String password) async {
    final userModel = _usersBox.get(email);

    if (userModel == null) throw Exception('User not found.');
    if (userModel.password != password) throw Exception('Incorrect password.');


    // Login successful: Save session
    await _sessionBox.put('current_user_email', email);
    return userModel.toEntity();
  }

  @override
  Future<bool> isLoggedIn() async {
    return _sessionBox.containsKey('current_user_email');
  }

  @override
  Future<void> logout() async {
    await _sessionBox.delete('current_user_email');
  }

  @override
  Future<bool> userExists(String email) async {
    return _usersBox.containsKey(email);
  }

 
  // Get current logged-in user
  Future<UserProfile?> getCurrentUser() async {
    // Get the email from the session box
    final email = _sessionBox.get('current_user_email');
    
    // If no email is saved, no one is logged in
    if (email == null) return null;

    // Find the user in the database
    final userModel = _usersBox.get(email);
    
    // Return the entity
    return userModel?.toEntity();
  }
}