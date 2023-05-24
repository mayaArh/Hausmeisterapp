import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/crud_exceptions.dart';

class RegistrationService {
  final db = FirebaseFirestore.instance;

  Future createFirestoreRenter(Renter renter, Map renterAddress) async {
    /// Creates a renter document in firestore
    ///
    /// throws [CouldNotFindGivenHouse()] if the address of the given renter doesn't exist
    /// in the database
    try {
      final docHouses = db.collection('houses');
      final queryRenterHouse = await docHouses
          .where('address', isEqualTo: renterAddress)
          .get()
          .then((querySnapshot) => querySnapshot.docs.first);
      final docRenterHouse = queryRenterHouse.reference;
      _addRenterToHouse(renter, docRenterHouse);
    } on StateError {
      throw CouldNotFindGivenHouse();
    }
  }

  Future _addRenterToHouse(Renter renter,
      DocumentReference<Map<String, dynamic>> docRenterHouse) async {
    ///Adds the renter to the given house document in firestore.
    ///
    ///Adds the renter to the subcollection "renters" of the given house,
    ///creates the subcollection first if it doesn't exist.
    final rentersCollection = docRenterHouse.collection('renters');
    final renterDocument = rentersCollection.doc();
    if (await rentersCollection.get().then((snapshot) => snapshot.size) > 0) {
      // 'renters' subcollection exists
      await renterDocument.set(renter.toJson());
    } else {
      // 'renters' subcollection doesn't exist
      await rentersCollection.doc('renters').set(renter.toJson());
    }
    docRenterHouse.set(renter.toJson());
  }
}

class Renter {
  final String firstName;
  final String lastName;
  String email;
  String phoneNumber;
  final int flatNumber;
  late final int id;

  Renter(
      {required this.firstName,
      required this.lastName,
      required this.email,
      required this.phoneNumber,
      required this.flatNumber});

  setId(int id) => this.id = id;

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
        'flatNumber': flatNumber,
      };
}
