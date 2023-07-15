import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mein_digitaler_hausmeister/enums/ticket_status.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_service.dart';

import '../../model_classes/house.dart';
import '../../model_classes/staff.dart';
import '../../model_classes/ticket.dart';
import '../../utilities/sort.dart';
import '../auth/auth_user.dart';
import 'crud_exceptions.dart';

// This class is responsible for all the CRUD operations that are
// related to the firestore database and the connected firebase storage.

class FirestoreDataService {
  FirestoreDataService._sharedInstance();
  static final FirestoreDataService _shared =
      FirestoreDataService._sharedInstance();
  factory FirestoreDataService() => _shared;

  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  //returns a stream of all the cities that are specified for the
  //current user
  Stream<List<String>> streamCities() async* {
    Staff? staff = await AuthService.firebase().currentStaff;
    if (staff != null) {
      DocumentReference<Map<String, dynamic>> userDoc = staff.firestoreRef;
      try {
        yield* userDoc.snapshots().map((userSnapshot) {
          final userData = userSnapshot.data();
          List<String> cityNames = [];
          if (userData != null) {
            final cityList = userData['Gebäude'];
            cityNames = cityList.keys.toList() ?? [];
            cityNames.sort((elemA, elemB) => elemA.compareTo(elemB));
          }
          return cityNames;
        });
      } catch (e) {
        throw CouldNotFindUserData();
      }
    } else {
      throw CouldNotFindUser();
    }
  }

  //returns a stream of all houses that are specified for the
  //current user at the given city
  Stream<List<House>> streamHousesForCity(String city) async* {
    Staff? staff = await AuthService.firebase().currentStaff;
    if (staff != null) {
      DocumentReference<Map<String, dynamic>> userDoc = staff.firestoreRef;
      try {
        await for (DocumentSnapshot<Map<String, dynamic>> userSnapshot
            in userDoc.snapshots()) {
          final userData = userSnapshot.data();
          List<House> houseList = [];
          if (userData != null) {
            Map<String, dynamic> houseMap = userData['Gebäude'];
            if (houseMap.containsKey(city)) {
              List<dynamic> houseDocs = houseMap[city];
              for (DocumentReference<Map<String, dynamic>> houseDoc in houseDocs
                  .cast<DocumentReference<Map<String, dynamic>>>()) {
                final houseSnapshot = await houseDoc.get();
                houseList.add(House.fromFirestore(houseSnapshot));
              }
            }
            Sort.sortHouses(houseList);
          }
          yield houseList;
        }
      } catch (e) {
        throw CouldNotFindUserData();
      }
    } else {
      throw CouldNotFindUser();
    }
  }

  //returns a stream of tickets for the given house. If filterOpenTickets is true,
  //all tickets with status open are returned, otherwise all tickets
  //with status done are returned
  Stream<List<Ticket>> streamTicketsForHouse(House house,
      {required bool filterOpenTickets}) {
    return house.firestoreRef.collection('Tickets').snapshots().map((data) {
      List<Ticket> ticketList = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> ticketDoc in data.docs) {
        final ticketData = ticketDoc.data();
        if (filterOpenTickets &&
            ticketData['Status'] == TicketStatus.open.name) {
          final ticket = Ticket.fromFirestore(ticketDoc);
          ticketList.add(ticket);
        } else if (filterOpenTickets == false &&
            ticketDoc.data()['Status'] == TicketStatus.done.name) {
          final ticket = Ticket.fromFirestore(ticketDoc);
          ticketList.add(ticket);
        }
        Sort.sortTicketsByDateTime(ticketList);
      }
      return ticketList;
    });
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

  //adds a new ticket to the given house
  Future<Ticket> addTicketToHouse({
    required House house,
    required String topic,
    required String description,
    required String dateTime,
    required String? image,
  }) async {
    final staffUser = await AuthService.firebase().currentStaff;
    DocumentReference<Map<String, dynamic>> ticketRef = house.firestoreRef
        .collection('Tickets')
        .doc('${staffUser!.firestoreRef.id}at${DateTime.now()}');
    ticketRef.set({
      'Vorname': staffUser.firstName,
      'Nachname': staffUser.lastName,
      'erstellt am': dateTime,
      'Problembeschreibung': description,
      'Thema': topic,
      'Bild': image ?? '',
      'Status': 'open',
    });
    final ticketSnapshot = await ticketRef.get();
    Ticket ticket = Ticket.fromFirestore(ticketSnapshot);
    return ticket;
  }

  //changes the ticket topic to the given topic
  Future<Ticket> changeTicketTopic(Ticket ticket, String newTopic) async {
    ticket.topic = newTopic;
    await ticket.firestoreRef.update({'Thema': newTopic});
    return ticket;
  }

  //changes the ticket description to the given description
  Future<Ticket> changeTicketDescription(
      Ticket ticket, String newDescription) async {
    ticket.description = newDescription;
    await ticket.firestoreRef.update({'Problembeschreibung': newDescription});
    return ticket;
  }

  //updates the status of the given ticket to the new status
  Future<Ticket> updateTicketStatus(
      Ticket ticket, TicketStatus newStatus) async {
    ticket.status = newStatus;
    await ticket.firestoreRef.update({'Status': newStatus.name});
    return ticket;
  }

  /// deletes the image stored for the ticket
  /// and adds a potentially new image to the ticket
  Future<Ticket> changeTicketImage(Ticket ticket, String? newImageUrl) async {
    if (ticket.imageUrl != null) {
      deleteStorageImage(ticket.imageUrl!);
    }
    ticket.imageUrl = newImageUrl;
    await ticket.firestoreRef.update({'Bild': newImageUrl});
    return ticket;
  }

  //deletes the ticket from the database and the corresponding image from the storage
  Future<void> deleteTicket(Ticket ticket) async {
    if (ticket.imageUrl != null) {
      deleteStorageImage(ticket.imageUrl!);
    }
    await Future.wait([ticket.firestoreRef.delete()]);
  }

  //deletes the image from the storage
  Future<void> deleteStorageImage(String? imageUrl) async {
    if (imageUrl != null) {
      final imageRef = storage.refFromURL(imageUrl);
      await imageRef.delete();
    }
  }

  /*Future<bool> userHasPermissionToEditTicket(Ticket ticket) async {
    final user = AuthService.firebase().currentUser;
    if (ticket.firestoreRef.id == user!.uid) {}
  }*/

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
