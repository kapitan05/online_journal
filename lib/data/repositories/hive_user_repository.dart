import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../domain/repositories/user_repository.dart'; // Import Interface
import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

// for manumulating file paths
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'dart:convert'; // for utf8
import 'package:crypto/crypto.dart';

// // Repository to manage User Profiles and Authentication
// // Simulates a simple user database using Hive
// // email as the unique key in the database to prevent duplicate users

class HiveUserRepository implements UserRepository {
  final Box<UserProfileModel> _usersBox; // The "Database" of all users
  final Box _sessionBox; // To remember who is currently logged in

  HiveUserRepository(this._usersBox, this._sessionBox);

  // --- NEW SECURITY HELPER ---
  String _hashPassword(String password) {
    // 1. Convert string to bytes
    var bytes = utf8.encode(password);
    // 2. Hash using SHA-256 (Standard secure hashing)
    var digest = sha256.convert(bytes);
    // 3. Return as a String
    return digest.toString();
  }

  // --- HELPER: Reconstruct the full path dynamically ---
  // *fixes the bug "avatar is not permanent on IOS"
  Future<UserProfile> _mapModelToEntity(UserProfileModel model) async {
    String? fullPath = model.profileImagePath;

    // If we have a stored filename, append it to the CURRENT app directory
    if (fullPath != null && fullPath.isNotEmpty) {
      final appDir = await getApplicationDocumentsDirectory();
      // This creates: /Current-iOS-Container/Documents/my_profile.jpg
      fullPath = path.join(appDir.path, fullPath);
    }

    return UserProfile(
      firstName: model.firstName,
      lastName: model.lastName,
      email: model.email,
      password: model.password,
      street: model.street,
      city: model.city,
      zipCode: model.zipCode,
      profileImagePath: fullPath, // Return the valid CURRENT path
    );
  }

  // SIGN UP METHOD
  @override
  Future<void> registerUser(UserProfile user) async {
    // Check if email exists in "DB"
    if (_usersBox.containsKey(user.email)) {
      throw Exception('User with this email already exists.');
    }

    // Handle profile image saving to permanent storage
    String? fileNameOnly; // We will save ONLY the filename

    if (user.profileImagePath != null) {
      try {
        // Fix: Use the user's provided path, not undefined 'permanentPath'
        final sourceFile = File(user.profileImagePath!);

        // 1. Check if the temp file actually exists
        if (await sourceFile.exists()) {
          // 2. Get the permanent directory for this app
          final appDir = await getApplicationDocumentsDirectory();

          // 3. Create a new filename (e.g., 'profile_john.jpg') to avoid conflicts
          // We use the email to make it unique per user
          final fileName =
              '${user.email}_profile${path.extension(user.profileImagePath!)}';

          // Copy the file to the app's document directory
          await sourceFile.copy(path.join(appDir.path, fileName));

          // 4. Update variable to store ONLY the filename (relative path)
          fileNameOnly = fileName;
        }
      } catch (e) {
        // If copying fails, we might log it, but we continue
        // to prevent crashing the registration.
        debugPrint("Error saving profile image: $e");
      }
    }

    // 🔒 SECURITY FIX: Hash the password before creating the model
    final hashedPassword = _hashPassword(user.password);

    // Save user using Email as the Key (Unique Index) and permanent image filename
    final model = UserProfileModel(
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      street: user.street,
      city: user.city,
      zipCode: user.zipCode,
      password: hashedPassword,
      profileImagePath: fileNameOnly, // <--- Store only the filename!
    );

    await _usersBox.put(user.email, model);
  }

  @override
  Future<UserProfile> authenticateUser(String email, String password) async {
    final userModel = _usersBox.get(email);

    if (userModel == null) throw Exception('User not found.');

    // 🔒 SECURITY: Hash the INPUT password and compare with STORED hash
    final inputHash = _hashPassword(password);

    if (userModel.password != inputHash) {
      throw Exception('Incorrect password.');
    }

    // Login successful: Save session
    await _sessionBox.put('current_user_email', email);

    // FIX: Use the helper to reconstruct the path dynamically
    return await _mapModelToEntity(userModel);
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

    if (userModel == null) return null;

    // FIX: Use the helper to reconstruct the path dynamically
    return await _mapModelToEntity(userModel);
  }
}
