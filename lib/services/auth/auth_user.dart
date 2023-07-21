import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/foundation.dart';

/// Represents a user that is authenticated.
@immutable
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  final String uid;

  const AuthUser(
      {required this.email, required this.isEmailVerified, required this.uid});

  /// Creates an [AuthUser] from the current Firebase User.
  factory AuthUser.fromFirebase(User user) => AuthUser(
      email: user.email, isEmailVerified: user.emailVerified, uid: user.uid);
}
