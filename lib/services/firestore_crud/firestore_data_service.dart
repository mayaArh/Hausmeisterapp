import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/auth_user.dart';
import 'crud_exceptions.dart';
import 'firestore_city_service.dart';
import 'firestore_house_service.dart';
import 'firestore_ticket_service.dart';

// This class is responsible for all the CRUD operations that are
// related to the firestore database and the connected firebase storage.

class FirestoreDataService
    with FirestoreTicketService, FirestoreCityService, FirestoreHouseService {
  final db = FirebaseFirestore.instance;

  static final FirestoreDataService _instance = FirestoreDataService._shared();

  FirestoreDataService._shared();

  factory FirestoreDataService() => _instance;

  Future<DocumentReference<Map<String, dynamic>>?> getFirestoreUserDoc(
      String email) async {
    DocumentReference<Map<String, dynamic>>? userDoc;
    try {
      CollectionReference<Map<String, dynamic>> staffCollection =
          db.collection('PropertyManagement');
      for (int i = 0; i < 2; i++) {
        final QuerySnapshot<Map<String, dynamic>> queryUser =
            await staffCollection.where('Email', isEqualTo: email).get();
        if (queryUser.size == 1) {
          userDoc = queryUser.docs.first.reference;
        }
        if (queryUser.size > 1) {
          throw SeveralUsersWithSameEmail();
        }
        staffCollection = db.collection('Janitors');
      }
    } catch (_) {}
    return userDoc;
  }

  //sets the id of the firestore document to the uid of the user
  Future<void> changeDocIdtoUID(AuthUser user) async {
    final userDoc = await getFirestoreUserDoc(user.email!);
    if (userDoc!.id != user.uid) {
      final newUserDoc = userDoc.parent.doc(user.uid);
      final data = await userDoc.get().then((snapshot) => snapshot.data());
      await userDoc.delete();
      newUserDoc.set(data!);
    }
  }

  //returns true if the user with the given email is allowed to use the app
  Future<bool> isAllowedUser(String email) async {
    return await getFirestoreUserDoc(email) != null;
  }
}
