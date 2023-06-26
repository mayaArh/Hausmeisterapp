import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/ticket_status.dart';

class Ticket {
  final String firstName;
  final String lastName;
  final String dateTime;
  String topic;
  String description;
  String? imageUrl;
  DocumentReference docRef;
  TicketStatus status;

  Ticket(
      {required this.firstName,
      required this.lastName,
      required this.dateTime,
      required this.topic,
      required this.description,
      required this.imageUrl,
      required this.docRef,
      required this.status});

  @override
  String toString() {
    return 'Ersteller: $firstName $lastName, Thema: $topic, Problembeschreibung: $description}';
  }

  factory Ticket.fromJson(Map<String, dynamic> json, DocumentReference docRef) {
    return Ticket(
      firstName: json['Vorname'],
      lastName: json['Nachname'],
      dateTime: json['erstellt am'],
      topic: json['Thema'],
      description: json['Problembeschreibung'],
      imageUrl: json['Bild'] == '' ? null : json['Bild'],
      docRef: docRef,
      status: TicketStatus.values.byName(json['Status']),
    );
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
