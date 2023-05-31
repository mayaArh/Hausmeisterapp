import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_user.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/crud_exceptions.dart';

class RegistrationService {
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

  ///Fetches the in firestore stored data for the given user and
  ///stores it in a corresponding <Staff> member. Returns a Future of
  ///the <Staff> member.
  Future<Staff> fetchUserFirestoreData(AuthUser user) async {
    final userDoc = await getFirestoreUserDoc(user.email!);
    userDoc!
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      Map<String, Map<House, List<Ticket>>> allTickets =
          _getAllTicketsForUser(documentSnapshot.data()!);
    });
  }

  Map<String, Map<House, List<Ticket>>> _getAllTicketsForUser(
      Map<String, dynamic> userData) {
    late final Map<String, Map<House, List<Ticket>>> allTickets =
        <String, Map<House, List<Ticket>>>{};
    final Map<String, List<DocumentReference<Map<String, dynamic>>>> houseMap =
        userData['Gebäude'];
    houseMap.forEach((city, houseDocs) async {
      for (DocumentReference<Map<String, dynamic>> houseDoc in houseDocs) {
        final data = await houseDoc.get().then((snapshot) => snapshot.data()!);
        House house = House(
            street: data['Strasse'],
            houseNumber: data['Hausnummer'],
            postalCode: data['Postleitzahl'],
            city: data['Ort']);
        List<Ticket> allTicketsForHouse =
            await _getAllTicketsForHouse(houseDoc);
        Map<House, List<Ticket>> houseTicketMap = {house: allTicketsForHouse};
        allTickets.putIfAbsent(city, () => houseTicketMap);
      }
    });
    return allTickets;
  }

  Future<List<Ticket>> _getAllTicketsForHouse(
      DocumentReference<Map<String, dynamic>> houseDoc) async {
    List<Ticket> allHouseTickets = List<Ticket>.empty(growable: true);
    CollectionReference<Map<String, dynamic>> ticketDocs =
        houseDoc.collection('Tickets');
    await ticketDocs.get().then((querySnapshot) => {
          if (querySnapshot.size > 0)
            {
              querySnapshot.docs.forEach((ticketDoc) {
                final ticketData = ticketDoc.data();
                final Ticket ticket = Ticket(
                    firstName: ticketData['Vorname'],
                    lastName: ticketData['Nachname'],
                    dateTime: ticketData['erstellt am'],
                    description: ticketData['Problembeschreibung'],
                    image: ticketData['Bild']);
                allHouseTickets.add(ticket);
              })
            }
        });
    return allHouseTickets;
  }
}

class Ticket {
  final String firstName;
  final String lastName;
  final DateTime dateTime;
  final String description;
  final String image;

  Ticket({
    required this.firstName,
    required this.lastName,
    required this.dateTime,
    required this.description,
    required this.image,
  });
}

class House {
  final String street;
  final int houseNumber;
  final int postalCode;
  final String city;

  House(
      {required this.street,
      required this.houseNumber,
      required this.postalCode,
      required this.city});
}

abstract class Staff {
  final String firstName;
  final String lastName;
  String email;
  String phoneNumber;
  Map<String, List<Ticket>> allTickets;
  //string = name of city

  Staff({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.allTickets,
  });
}

class Janitor extends Staff {
  Janitor({
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    required super.allTickets,
  });
}

class BuildingManagement extends Staff {
  BuildingManagement({
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    required super.allTickets,
  });
}
