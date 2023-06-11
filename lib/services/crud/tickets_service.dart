import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/auth_user.dart';
import '../firestore_crud/crud_exceptions.dart';
import '../firestore_crud/registration_service.dart';

class FirestoreTicketService {
  FirestoreTicketService._sharedInstance() {
    _ticketsStreamController =
        StreamController<Map<String, Map<House, List<Ticket>>>>.broadcast(
      onListen: () {
        _ticketsStreamController.sink.add(_allTicketsByHouseInCity);
      },
    );
  }
  static final FirestoreTicketService _shared =
      FirestoreTicketService._sharedInstance();
  factory FirestoreTicketService() => _shared;

  final db = FirebaseFirestore.instance;
  final _registrationService = RegistrationService();
  late DocumentReference<Map<String, dynamic>> userDoc;
  Map<String, Map<House, List<Ticket>>> _allTicketsByHouseInCity = {};
  late final StreamController<Map<String, Map<House, List<Ticket>>>>
      _ticketsStreamController;

  Stream<Map<String, Map<House, List<Ticket>>>> get allTicketsByHouseInCity =>
      _ticketsStreamController.stream;

  ///Fetches the in firestore stored data for the given user and
  ///stores it in a corresponding <Staff> member. Returns a Future of
  ///the <Staff> member.
  Future<Staff> fetchUserFirestoreDataAsStaff(AuthUser user) async {
    userDoc = (await _registrationService.getFirestoreUserDoc(user.email!))!;
    late final Map<String, dynamic> userData;
    userDoc
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      userData = documentSnapshot.data()!;
      _setAllTicketsForUser(userData);
    });
    final String firstName = userData['Vorname'];
    final String lastName = userData['Nachname'];
    final String email = userData['Email'];
    final String phoneNumber = userData['Vorname'];
    if (userDoc.parent.id == 'Hausverwaltung') {
      return BuildingManagement(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );
    }
    if (userDoc.parent.id == 'Hausmeister') {
      return Janitor(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );
    } else {
      throw CouldNotFindUser();
    }
  }

  void _setAllTicketsForUser(Map<String, dynamic> userData) {
    late final Map<String, Map<House, List<Ticket>>> allTicketsByHouse =
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
            city: data['Ort'],
            doc: houseDoc);
        List<Ticket> allTicketsForHouse =
            await _setAllTicketsForHouse(houseDoc);
        Map<House, List<Ticket>> houseTicketMap = {house: allTicketsForHouse};
        allTicketsByHouse.putIfAbsent(city, () => houseTicketMap);
      }
    });
    _allTicketsByHouseInCity = allTicketsByHouse;
    _ticketsStreamController.add(_allTicketsByHouseInCity);
  }

  Future<List<Ticket>> _setAllTicketsForHouse(
      DocumentReference<Map<String, dynamic>> houseDoc) async {
    List<Ticket> allHouseTickets = List<Ticket>.empty(growable: true);
    CollectionReference<Map<String, dynamic>> ticketCollection =
        houseDoc.collection('Tickets');
    await ticketCollection.get().then((querySnapshot) => {
          if (querySnapshot.size > 0)
            {
              querySnapshot.docs.forEach((ticketDoc) {
                final ticketData = ticketDoc.data();
                final Ticket ticket = Ticket(
                    firstName: ticketData['Vorname'],
                    lastName: ticketData['Nachname'],
                    dateTime:
                        DateTime.parse(ticketData['erstellt am']).toLocal(),
                    description: ticketData['Problembeschreibung'],
                    image: ticketData['Bild']);
                ticket.setTicketDoc(ticketDoc.reference);
                allHouseTickets.add(ticket);
              })
            }
        });
    return allHouseTickets;
  }

  void addTicketToHouse(House house, Ticket ticket) async {
    //add to database
    DocumentReference<Map<String, dynamic>> ticketDoc =
        await house.doc.collection('Tickets').add(ticket.toJson());
    ticket.setTicketDoc(ticketDoc);
    //add to StreamController
    Map<House, List<Ticket>>? houseMap = _allTicketsByHouseInCity[house.city];
    if (houseMap != null) {
      List<Ticket>? houseTickets = houseMap[house];
      if (houseTickets != null) {
        houseTickets.add(ticket);
      } else {
        throw CouldNotFindGivenHouse();
      }
    } else {
      throw CouldNotFindGivenHouse();
    }
  }

  /*List<String> getListOfCities() {
    return allTicketsByHouseInCity.keys.toList();
  }

  List<House> getListOfHouses(String city) {
    Map<House, List<Ticket>>? cities = allTicketsByHouseInCity[city];
    if (cities != null) {
      return cities.keys.toList();
    } else {
      throw GivenCityDoesntExist();
    }
  }

  List<Ticket> getListOfTickets(String city, House house) {
    Map<House, List<Ticket>>? cities = allTicketsByHouseInCity[city];
    if (cities != null) {
      List<Ticket>? tickets = cities[house];
      if (tickets != null) {
        return tickets;
      } else {
        throw GivenHouseDoesntExist();
      }
    } else {
      throw GivenCityDoesntExist();
    }
  }*/
}

class Ticket {
  final String firstName;
  final String lastName;
  final DateTime dateTime;
  final String description;
  final String? image;
  late final DocumentReference<Map<String, dynamic>> ticketDoc;

  Ticket({
    required this.firstName,
    required this.lastName,
    required this.dateTime,
    required this.description,
    required this.image,
  });

  void setTicketDoc(DocumentReference<Map<String, dynamic>> doc) {
    ticketDoc = doc;
  }

  Map<String, dynamic> toJson() {
    return {
      'Vorname': firstName,
      'Nachname': lastName,
      'erstellt am': dateTime.toIso8601String(),
      'Problembeschreibung': description,
      'Bild': image,
    };
  }
}

class House {
  final String street;
  final int houseNumber;
  final int postalCode;
  final String city;
  final DocumentReference<Map<String, dynamic>> doc;

  House(
      {required this.street,
      required this.houseNumber,
      required this.postalCode,
      required this.city,
      required this.doc});
}

abstract class Staff {
  final String firstName;
  final String lastName;
  String email;
  String phoneNumber;

  Staff({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });
}

class Janitor extends Staff {
  Janitor({
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
  });
}

class BuildingManagement extends Staff {
  BuildingManagement({
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
  });
}
