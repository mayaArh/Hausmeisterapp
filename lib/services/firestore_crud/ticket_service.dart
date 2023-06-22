import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/registration_service.dart';
import 'package:rxdart/rxdart.dart';

import '../../model_classes.dart/house.dart';
import '../../model_classes.dart/staff.dart';
import '../../model_classes.dart/ticket.dart';
import '../auth/auth_user.dart';
import 'crud_exceptions.dart';
import 'firestore_data_provider.dart';

class FirestoreTicketService {
  FirestoreTicketService._sharedInstance();
  static final FirestoreTicketService _shared =
      FirestoreTicketService._sharedInstance();
  factory FirestoreTicketService() => _shared;

  final db = FirebaseFirestore.instance;
  late final Staff _staffUser;
  List<List<String>> houseDocIds = [];
  late DocumentReference<Map<String, dynamic>> userDoc;

  final _registrationService = RegistrationService();
  final _dataProvider = FirestoreDataProvider();

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
    });
    final String firstName = userData['Vorname'];
    final String lastName = userData['Nachname'];
    final String email = userData['Email'];
    final String phoneNumber = userData['Vorname'];
    if (userDoc.parent.id == 'Hausverwaltung') {
      _staffUser = BuildingManagement(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );
    }
    if (userDoc.parent.id == 'Hausmeister') {
      _staffUser = Janitor(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );
    } else {
      throw CouldNotFindUser();
    }
    return _staffUser;
  }

  void _setAllTicketsForUser(Map<String, dynamic> userData) async {
    Map<String, Map<House, List<Ticket>>> allTicketsByHouse =
        <String, Map<House, List<Ticket>>>{};
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
        fetchHouseDataTasks
            .add(_fetchHouseData(houseDoc, city, allTicketsByHouse));
      }
    });
    if (houseDocIDs.isNotEmpty) {
      houseDocIds.add(List<String>.from(houseDocIDs));
    }
    await Future.wait(fetchHouseDataTasks);
  }

  Future<void> _fetchHouseData(
      DocumentReference<Map<String, dynamic>> houseDoc,
      String city,
      Map<String, Map<House, List<Ticket>>> allTicketsByHouse) async {
    await houseDoc.get().then((snapshot) => snapshot.data()!);
  }

  Future<Ticket?> addTicketToHouse(
      {required House house,
      required String topic,
      required String description,
      required String dateTime,
      required String image}) async {
    if (_dataProvider.snapshots != null) {
      for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in _dataProvider.snapshots!) {
        for (final QueryDocumentSnapshot<Map<String, dynamic>> houseDoc
            in snapshot.docs) {
          final House queryHouse = House.fromJson(houseDoc.data());

          if (queryHouse == house) {
            Ticket ticket = Ticket(
                firstName: _staffUser.firstName,
                lastName: _staffUser.lastName,
                dateTime: dateTime,
                topic: topic,
                description: description,
                image: image);
            houseDoc.reference.collection('Tickets').add(ticket.toJson());
            return ticket;
          }
        }
      }
    }
    return null;
  }
}
