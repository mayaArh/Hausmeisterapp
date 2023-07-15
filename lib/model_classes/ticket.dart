import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/crud_exceptions.dart';

import '../enums/ticket_status.dart';

/// Represents a ticket.
class Ticket {
  DocumentReference firestoreRef;
  final String firstName;
  final String lastName;
  final String dateTime;
  String topic;
  String description;
  String? imageUrl;
  TicketStatus status;

  Ticket(
      {required this.firestoreRef,
      required this.firstName,
      required this.lastName,
      required this.dateTime,
      required this.topic,
      required this.description,
      required this.imageUrl,
      required this.status});

  /// Creates a ticket from a Firestore [DocumentSnapshot]
  factory Ticket.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      Map<String, dynamic> data = doc.data()!;
      return Ticket(
        firestoreRef: doc.reference,
        firstName: data['Vorname'],
        lastName: data['Nachname'],
        dateTime: data['erstellt am'],
        topic: data['Thema'],
        description: data['Problembeschreibung'],
        imageUrl: data['Bild'] == '' ? null : doc['Bild'],
        status: TicketStatus.values.byName(data['Status']),
      );
    } catch (_) {
      throw TicketDoesntHaveAllFields();
    }
  }

  String get date => dateTime.substring(0, 10);
}
