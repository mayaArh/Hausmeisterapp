import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_user.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/crud_exceptions.dart';

class RegistrationService {
  RegistrationService._sharedInstance();
  static final RegistrationService _shared =
      RegistrationService._sharedInstance();
  factory RegistrationService() => _shared;

  final db = FirebaseFirestore.instance;

  Future<bool> isAllowedUser(String email) async {
    return await getFirestoreUserDoc(email) != null;
  }

  Future<DocumentReference<Map<String, dynamic>>?> getFirestoreUserDoc(
      String email) async {
    DocumentReference<Map<String, dynamic>>? userDoc;
    try {
      CollectionReference<Map<String, dynamic>> staffCollection =
          db.collection('Hausverwaltung');
      for (int i = 0; i < 2; i++) {
        final QuerySnapshot<Map<String, dynamic>> queryUser =
            await staffCollection.where('Email', isEqualTo: email).get();
        if (queryUser.size == 1) {
          userDoc = queryUser.docs.first.reference;
        }
        if (queryUser.size > 1) {
          throw SeveralUsersWithSameEmail();
        }
        staffCollection = db.collection('Hausmeister');
      }
    } catch (_) {}
    return userDoc;
  }

  Future<void> changeDocIdtoUID(AuthUser user) async {
    final userDoc = await getFirestoreUserDoc(user.email!);
    final newUserDoc = userDoc!.parent.doc(user.uid);
    final data = await userDoc.get().then((snapshot) => snapshot.data());
    await userDoc.delete();
    newUserDoc.set(data!);
  }
}
