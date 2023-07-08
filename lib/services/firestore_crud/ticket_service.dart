import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:mein_digitaler_hausmeister/enums/ticket_status.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_service.dart';
import 'package:rxdart/rxdart.dart';

import '../../model_classes.dart/house.dart';
import '../../model_classes.dart/staff.dart';
import '../../model_classes.dart/ticket.dart';
import 'crud_exceptions.dart';

class FirestoreDataService {
  FirestoreDataService._sharedInstance();
  static final FirestoreDataService _shared =
      FirestoreDataService._sharedInstance();
  factory FirestoreDataService() => _shared;

  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

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
        final ticketData = ticketDoc.data();
        if (filterOpenTickets &&
            ticketData['Status'] == TicketStatus.open.name) {
          final ticket = Ticket.fromFirestore(ticketDoc);
          ticketList.add(ticket);
        } else if (filterOpenTickets == false &&
            ticketDoc.data()['Status'] == TicketStatus.done.name) {
          ticketList.add(Ticket.fromFirestore(ticketDoc));
        }
        _sortTicketsByDateTime(ticketList);
      }
      return ticketList;
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
    final staffUser = await AuthService.firebase().currentStaff;
    DocumentReference<Map<String, dynamic>> ticketRef =
        await house.firestoreRef.collection('Tickets').add({
      'Vorname': staffUser!.firstName,
      'Nachname': staffUser.lastName,
      'erstellt am': dateTime,
      'Problembeschreibung': description,
      'Thema': topic,
      'Bild': image ?? '',
      'Status': status.name,
    });
    final ticketSnapshot = await ticketRef.get();
    Ticket ticket = Ticket.fromFirestore(ticketSnapshot);
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
