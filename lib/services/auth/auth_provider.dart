import 'package:mein_digitaler_hausmeister/model_classes.dart/staff.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();
  AuthUser? get currentUser;
  Future<Staff?> get currentStaff;
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();

  Future<void> sendEmailVerification();
}
