import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/ticket_status.dart';

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

  @override
  String toString() {
    return 'Ersteller: $firstName $lastName, Thema: $topic, Problembeschreibung: $description, Status: ${status.name}';
  }

  factory Ticket.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      Map<String, dynamic> data = doc.data()!;
      return Ticket(
        firestoreRef: doc.reference,
        firstName: doc['Vorname'],
        lastName: doc['Nachname'],
        dateTime: doc['erstellt am'],
        topic: doc['Thema'],
        description: doc['Problembeschreibung'],
        imageUrl: doc['Bild'] == '' ? null : doc['Bild'],
        status: TicketStatus.values.byName(doc['Status']),
      );
    } catch (_) {
      throw TicketDoesntHaveAllFields();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Vorname': firstName,
      'Nachname': lastName,
      'erstellt am': dateTime,
      'Problembeschreibung': description,
      'Thema': topic,
      'Bild': imageUrl ?? '',
      'Status': status.name,
    };
  }
}
