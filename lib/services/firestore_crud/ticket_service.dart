import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:mein_digitaler_hausmeister/enums/ticket_status.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_service.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/registration_service.dart';
import 'package:rxdart/rxdart.dart';

import '../../model_classes.dart/house.dart';
import '../../model_classes.dart/staff.dart';
import '../../model_classes.dart/ticket.dart';
import '../auth/auth_user.dart';
import 'crud_exceptions.dart';

class FirestoreDataService {
  FirestoreDataService._sharedInstance();
  static final FirestoreDataService _shared =
      FirestoreDataService._sharedInstance();
  factory FirestoreDataService() => _shared;

  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  late Staff _staffUser;
  List<List<String>> houseDocIds = [];
  late DocumentReference<Map<String, dynamic>> userDoc;

  final _registrationService = RegistrationService();

  Stream<List<QuerySnapshot<Map<String, dynamic>>>> get firestoreStreams {
    List<Stream<QuerySnapshot<Map<String, dynamic>>>> streams = [];
    for (List<String> houseDocIdList in houseDocIds) {
      final stream = db
          .collection('Gebäude')
          .where(
            FieldPath.documentId,
            whereIn: houseDocIdList,
          )
          .snapshots();
      streams.add(stream);
    }
    Stream<List<QuerySnapshot<Map<String, dynamic>>>> zippedStreams =
        ZipStream(streams, (values) => values);
    return zippedStreams;
  }

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
            _sortHouses(houseList);
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

  Stream<List<Ticket>> streamTicketsForHouse(House house,
      {required bool filterOpenTickets}) {
    return house.firestoreRef.collection('Tickets').snapshots().map((data) {
      List<Ticket> ticketList = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> ticketDoc in data.docs) {
        if (filterOpenTickets &&
            ticketDoc.data()['Status'] == TicketStatus.open.toString()) {
          ticketList.add(Ticket.fromFirestore(ticketDoc));
        } else if (filterOpenTickets == false &&
            ticketDoc.data()['Status'] == TicketStatus.done.toString()) {
          ticketList.add(Ticket.fromFirestore(ticketDoc));
        }
        _sortTicketsByDateTime(ticketList);
      }
      return ticketList;
    });
  }

  ///Fetches the in firestore stored data for the given user and
  ///stores it in a corresponding <Staff> member. Returns a Future of
  ///the <Staff> member.
  Future<Staff> fetchUserFirestoreDataAsStaff(AuthUser user) async {
    userDoc = (await _registrationService.getFirestoreUserDoc(user.email!))!;
    late final Map<String, dynamic> userData;
    await userDoc
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      userData = documentSnapshot.data()!;
      _setAllTicketsForUser(userData);
      if (userDoc.parent.id == 'Hausverwaltung') {
        _staffUser = BuildingManager.fromFirebase(documentSnapshot);
      } else if (userDoc.parent.id == 'Hausmeister') {
        _staffUser = Janitor.fromFirebase(documentSnapshot);
      } else {
        throw CouldNotFindUser();
      }
    });
    return _staffUser;
  }

  void _setAllTicketsForUser(Map<String, dynamic> userData) async {
    final houseMap = userData['Gebäude'];
    final fetchHouseDataTasks = <Future<void>>[];
    int i = 0;
    List<String> houseDocIDs = List.empty(growable: true);
    houseMap.forEach((city, houseDocs) async {
      for (DocumentReference<Map<String, dynamic>> houseDoc in houseDocs) {
        houseDocIDs.add(houseDoc.id);
        i++;
        if (i == 10 || houseDocs.last == houseDoc) {
          houseDocIds.add(List<String>.from(houseDocIDs));
          houseDocIDs.clear();
          i = 0;
        }
        fetchHouseDataTasks.add(_fetchHouseData(houseDoc, city));
      }
    });
    if (houseDocIDs.isNotEmpty) {
      houseDocIds.add(List<String>.from(houseDocIDs));
    }
    await Future.wait(fetchHouseDataTasks);
  }

  Future<void> _fetchHouseData(
      DocumentReference<Map<String, dynamic>> houseDoc, String city) async {
    await houseDoc.get().then((snapshot) {
      snapshot.data()!;
    });
  }

  Future<Ticket> addTicketToHouse({
    required House house,
    required String topic,
    required String description,
    required String dateTime,
    required String? image,
    required TicketStatus status,
  }) async {
    DocumentReference ticketRef =
        await house.firestoreRef.collection('Tickets').add({
      'Vorname': _staffUser.firstName,
      'Nachname': _staffUser.lastName,
      'erstellt am': dateTime,
      'Problembeschreibung': description,
      'Thema': topic,
      'Bild': image ?? '',
      'Status': status.name,
    });
    Ticket ticket = Ticket(
        firstName: _staffUser.firstName,
        lastName: _staffUser.lastName,
        dateTime: dateTime,
        topic: topic,
        description: description,
        imageUrl: image,
        firestoreRef: ticketRef,
        status: status);

    ticket.firestoreRef = ticketRef;
    return ticket;
  }

  void _sortTicketsByDateTime(List<Ticket> tickets) {
    tickets.sort((ticketA, ticketB) {
      final dateTimeA = DateFormat('dd.MM.yyyy, HH:mm').parse(ticketA.dateTime);
      final dateTimeB = DateFormat('dd.MM.yyyy, HH:mm').parse(ticketB.dateTime);
      return dateTimeA.compareTo(dateTimeB);
    });
  }

  Future<void> deleteTicket(Ticket ticket) async {
    deleteStorageImage(ticket.imageUrl!);
    await Future.wait([ticket.firestoreRef.delete()]);
  }

  Future<Ticket> changeTicketTopic(Ticket ticket, String newTopic) async {
    ticket.topic = newTopic;
    await ticket.firestoreRef.update({'Thema': newTopic});
    return ticket;
  }

  Future<Ticket> changeTicketDescription(
      Ticket ticket, String newDescription) async {
    ticket.description = newDescription;
    await ticket.firestoreRef.update({'Problembeschreibung': newDescription});
    return ticket;
  }

  Future<Ticket> updateTicketStatus(
      Ticket ticket, TicketStatus newStatus) async {
    ticket.status = newStatus;
    await ticket.firestoreRef.update({'Status': newStatus.name});
    return ticket;
  }

  /// deletes the image stored for the ticket
  /// and adds the given new image to the ticket
  Future<Ticket> changeTicketImage(Ticket ticket, String? newImageUrl) async {
    deleteStorageImage(ticket.imageUrl!);
    ticket.imageUrl = newImageUrl;
    await ticket.firestoreRef.update({'Bild': newImageUrl});
    return ticket;
  }

  Future<void> deleteStorageImage(String? imageUrl) async {
    if (imageUrl != null) {
      final imageRef = storage.refFromURL(imageUrl);
      await imageRef.delete();
    }
  }

  void _sortHouses(List<House> houses) {
    houses.sort((houseA, houseB) {
      int streetComparison = houseA.street.compareTo(houseB.street);
      if (streetComparison != 0) {
        return streetComparison;
      } else {
        return houseA.houseNumber.compareTo(houseB.houseNumber);
      }
    });
  }
}
