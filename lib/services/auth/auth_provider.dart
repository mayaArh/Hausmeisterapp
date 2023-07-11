import 'package:mein_digitaler_hausmeister/model_classes/staff.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_user.dart';

/// Abstract class for authentication providers.
abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  Future<Staff?> get currentStaff;

  //creates a new user with the given email and password
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  //logs in the user with the given email and password
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  //logs out the current user
  Future<void> logOut();

  //sends an email verification to the current user
  Future<void> sendEmailVerification();
}
