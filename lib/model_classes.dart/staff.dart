import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mein_digitaler_hausmeister/model_classes.dart/ticket.dart';

import '../services/firestore_crud/crud_exceptions.dart';

abstract class Staff {
  final DocumentReference<Map<String, dynamic>> firestoreRef;
  final String firstName;
  final String lastName;
  String email;
  String phoneNumber;
  List<Ticket> tickets = [];

  Staff({
    required this.firestoreRef,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  void addTicket(Ticket ticket) {
    tickets.add(ticket);
  }
}

class Janitor extends Staff {
  Janitor({
    required super.firestoreRef,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
  });

  factory Janitor.fromFirebase(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      Map<String, dynamic> data = doc.data()!;
      return Janitor(
        firestoreRef: doc.reference,
        firstName: data['Vorname'],
        lastName: data['Nachname'],
        email: data['Email'],
        phoneNumber: data['Telefonnummer'],
      );
    } catch (_) {
      throw JanitorDoesntHaveAllFields();
    }
  }
}

class BuildingManager extends Staff {
  BuildingManager({
    required super.firestoreRef,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
  });

  factory BuildingManager.fromFirebase(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      Map<String, dynamic> data = doc.data()!;
      return BuildingManager(
        firestoreRef: doc.reference,
        firstName: data['Vorname'],
        lastName: data['Nachname'],
        email: data['Email'],
        phoneNumber: data['Telefonnummer'],
      );
    } catch (_) {
      throw BuildingManagerDoesntHaveAllFields();
    }
  }
}
