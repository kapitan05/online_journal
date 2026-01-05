import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:online_journal_local/presentation/cubit/auth_state.dart';
import '../../domain/entities/user_profile.dart';
import '../../data/repositories/user_repository.dart';


// Logic 
class AuthCubit extends Cubit<AuthState> {
  final UserRepository repository;

  AuthCubit(this.repository) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
      try {
        // Fetch the REAL user from the repository
        final currentUser = await repository.getCurrentUser();

        if (currentUser != null) {
          emit(AuthAuthenticated(currentUser));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (e) {
        // If something goes wrong (data corruption etc ) -> logout
        await repository.logout();
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

  // Check if email already exists
  Future<bool> checkEmailExists(String email) async {
    return await repository.userExists(email);
  }

}