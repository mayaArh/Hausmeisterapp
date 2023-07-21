import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mein_digitaler_hausmeister/constants/ticket_db_fields.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/crud_exceptions.dart';

import '../enums/ticket_status.dart';

/// Represents a ticket.
class Ticket {
  DocumentReference firestoreRef;
  final String nameCreator;
  String? nameCompleter;
  final String creationDateTime;
  String? completionDateTime;
  String task;
  String description;
  String? imageUrl;
  TicketStatus status;
  final String uId;

  Ticket(
      {required this.firestoreRef,
      required this.nameCreator,
      required this.creationDateTime,
      required this.task,
      required this.description,
      required this.imageUrl,
      required this.uId,
      this.status = TicketStatus.open,
      this.nameCompleter = '',
      this.completionDateTime = ''});

  /// Creates a ticket from a Firestore [DocumentSnapshot]
  factory Ticket.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      Map<String, dynamic> data = doc.data()!;

      return Ticket(
        firestoreRef: doc.reference,
        nameCreator: data[nameCreatorField],
        nameCompleter: data[nameCompleterField],
        creationDateTime: data[creationDateTimeField],
        completionDateTime: data[completionDateTimeField],
        task: data[taskField],
        description: data[descriptionField],
        imageUrl: data[imageUrlField],
        status: TicketStatus.values.byName(data[statusField]),
        uId: data[uIdField],
      );
    } catch (_) {
      throw TicketDoesntHaveAllFields();
    }
  }

  String get creationDate => creationDateTime.substring(0, 10);

  String get completionDate => completionDateTime?.substring(0, 10) ?? '';
}
