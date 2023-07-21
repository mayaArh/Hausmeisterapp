import 'package:firebase_core/firebase_core.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_exceptions.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuth, FirebaseAuthException;
import '../../firebase_options.dart';
import '../../model_classes/staff.dart';
import '../firestore_crud/crud_exceptions.dart';
import '../firestore_crud/firestore_data_service.dart';
import 'auth_provider.dart';

/// Authentication provider for Firebase.
class FirebaseAuthProvider extends AuthProvider {
  //Creates an [AuthUser] with the given email and password
  //and returns it if the creation was successful, otherwise
  //throws an exception describing the error.
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (h) {
      throw GenericAuthException();
    }
  }

  //Returns the current [AuthUser] if the user is logged in,
  //otherwise returns null.
  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  //Returns a future of the current [Staff] if the user is logged in,
  //otherwise returns <Future<null>>
  @override
  Future<Staff?> get currentStaff async {
    final user = FirebaseAuth.instance.currentUser;
    Staff? staff;
    if (user != null) {
      final userDoc =
          (await FirestoreDataService().getFirestoreUserDoc(user.email!))!;

      Staff? staffUser;
      await userDoc.get().then((snapshot) {
        if (userDoc.parent.id == 'PropertyManagement') {
          staffUser = BuildingManager.fromFirebase(snapshot);
        } else if (userDoc.parent.id == 'Janitors') {
          staffUser = Janitor.fromFirebase(snapshot);
        } else {
          throw CouldNotFindUser();
        }
        staff = staffUser;
      });
    }
    return staff;
  }

  //Logs in the user with the given email and password and
  //returns the [AuthUser] if the login was successful, otherwise
  //throws an exception describing the error.
  @override
  Future<AuthUser> logIn(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else if (e.code == 'network-request-failed') {
        throw NoInternetAuthException();
      } else if (email.isEmpty) {
        throw NoEmailProvidedAuthException();
      } else if (password.isEmpty) {
        throw NoPasswordProvidedAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
}
