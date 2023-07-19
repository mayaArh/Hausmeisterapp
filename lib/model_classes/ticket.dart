import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/crud_exceptions.dart';

import '../enums/ticket_status.dart';

/// Represents a ticket.
class Ticket {
  DocumentReference firestoreRef;
  final String nameCreator;
  String nameCompleter;
  final String dateTime;
  String topic;
  String description;
  String? imageUrl;
  TicketStatus status;
  final String uId;

  Ticket(
      {required this.firestoreRef,
      required this.nameCreator,
      required this.nameCompleter,
      required this.dateTime,
      required this.topic,
      required this.description,
      required this.imageUrl,
      required this.status,
      required this.uId});

  /// Creates a ticket from a Firestore [DocumentSnapshot]
  factory Ticket.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      Map<String, dynamic> data = doc.data()!;
      return Ticket(
        firestoreRef: doc.reference,
        nameCreator: data['Ersteller'],
        dateTime: data['erstellt am'],
        topic: data['Thema'],
        description: data['Problembeschreibung'],
        imageUrl: data['Bild'] == '' ? null : doc['Bild'],
        status: TicketStatus.values.byName(data['Status']),
        uId: data['uId'],
        nameCompleter: data['erledigt von'],
      );
    } catch (_) {
      throw TicketDoesntHaveAllFields();
    }
  }

  String get date => dateTime.substring(0, 10);
}
