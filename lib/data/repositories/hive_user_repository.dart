import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../domain/repositories/user_repository.dart'; // Import Interface
import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

// for manumulating file paths
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// // Repository to manage User Profiles and Authentication
// // Simulates a simple user database using Hive
// // email as the unique key in the database to prevent duplicate users

class HiveUserRepository implements UserRepository {
  final Box<UserProfileModel> _usersBox; // The "Database" of all users
  final Box _sessionBox; // To remember who is currently logged in

  HiveUserRepository(this._usersBox, this._sessionBox);

  // SIGN UP METHOD
  @override
  Future<void> registerUser(UserProfile user) async {
    // Check if email exists in "DB"
    if (_usersBox.containsKey(user.email)) {
      throw Exception('User with this email already exists.');
    }
    // Handle profile image saving to permanent storage
    String? permanentPath = user.profileImagePath;

    if (permanentPath != null) {
      try {
        final sourceFile = File(permanentPath);

        // 1. Check if the temp file actually exists
        if (await sourceFile.exists()) {
          // 2. Get the permanent directory for this app
          final appDir = await getApplicationDocumentsDirectory();

          // 3. Create a new filename (e.g., 'profile_john.jpg') to avoid conflicts
          // We use the email to make it unique per user, or just keep original name
          final fileName =
              '${user.email}_profile${path.extension(permanentPath)}';
          final savedImage = await sourceFile.copy('${appDir.path}/$fileName');

          // 4. Update the path variable to the NEW permanent location
          permanentPath = savedImage.path;
        }
      } catch (e) {
        // If copying fails, we might log it, but we continue with the original path
        // (or null) to prevent crashing the registration.
        debugPrint("Error saving profile image: $e");
      }
    }

    // Save user using Email as the Key (Unique Index) and permanent image path
    final model = UserProfileModel(
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      street: user.street,
      city: user.city,
      zipCode: user.zipCode,
      password: user.password,
      profileImagePath: permanentPath,
    );

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
  @override
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
