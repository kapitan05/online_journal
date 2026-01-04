import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../../data/repositories/user_repository.dart';

// States to represent authentication status so toggle UI accordingly
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserProfile user;
  AuthAuthenticated(this.user);
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Logic 
class AuthCubit extends Cubit<AuthState> {
  final UserRepository repository;

  AuthCubit(this.repository) : super(AuthInitial());

  // Check on App Start
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await repository.isLoggedIn();
    if (isLoggedIn) {
       // Ideally, fetch the actual user object here
       emit(AuthAuthenticated(UserProfile(
         firstName: 'User', lastName: '', email: '', password: '', 
         street: '', city: '', zipCode: ''
       ))); 
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signUp(UserProfile user) async {
    emit(AuthLoading());
    try {
      await repository.registerUser(user);
      // Auto-login after signup
      await repository.authenticateUser(user.email, user.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await repository.authenticateUser(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> signOut() async {
    await repository.logout();
    emit(AuthUnauthenticated());
  }
}