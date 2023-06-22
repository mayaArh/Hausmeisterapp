import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String firstName;
  final String lastName;
  final String dateTime;
  final String topic;
  final String description;
  final String? imageRef;
  DocumentReference docRef;

  Ticket({
    required this.firstName,
    required this.lastName,
    required this.dateTime,
    required this.topic,
    required this.description,
    required this.imageRef,
    required this.docRef,
  });

  @override
  String toString() {
    return 'Vorname: $firstName, Nachname: $lastName, Thema: $topic, Beschreibung: $description, Referenz: ${docRef.toString()}';
  }

  factory Ticket.fromJson(Map<String, dynamic> json, DocumentReference docRef) {
    return Ticket(
      firstName: json['Vorname'],
      lastName: json['Nachname'],
      dateTime: json['erstellt am'],
      topic: json['Thema'],
      description: json['Problembeschreibung'],
      imageRef: json['Bild'],
      docRef: docRef,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Vorname': firstName,
      'Nachname': lastName,
      'erstellt am': dateTime,
      'Problembeschreibung': description,
      'Thema': topic,
      'Bild': imageRef,
    };
  }
}
