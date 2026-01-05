import '../entities/user_profile.dart';

abstract class UserRepository {
  Future<void> registerUser(UserProfile user);
  Future<UserProfile> authenticateUser(String email, String password);
  Future<bool> isLoggedIn();
  Future<void> logout();
  Future<bool> userExists(String email);
  Future<UserProfile?> getCurrentUser();
}