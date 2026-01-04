import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../../data/repositories/user_repository.dart';

// Simple States
abstract class UserState {}
class UserInitial extends UserState {}
class UserSaved extends UserState {}

class UserCubit extends Cubit<UserState> {
  final UserRepository repository;

  UserCubit(this.repository) : super(UserInitial());

  Future<void> saveUserProfile(UserProfile user) async {
    await repository.saveUser(user);
    emit(UserSaved());
  }
  
  // Helper to check if user already exists
  UserProfile? getCurrentUser() {
    return repository.getUser();
  }
}