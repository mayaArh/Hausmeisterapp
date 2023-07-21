import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mein_digitaler_hausmeister/model_classes/ticket.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/crud_exceptions.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';

/// Represents a house in the database
class House {
  final DocumentReference firestoreRef;
  final String street;
  final int houseNumber;
  final int postalCode;
  final String city;

  Stream<List<Ticket>> streamOpenTickets() {
    return FirestoreDataService().streamTicketsForHouse(
        house: this, filterOpenTickets: true, showOldestFirst: true);
  }

  Stream<List<Ticket>> streamClosedTickets() {
    return FirestoreDataService().streamTicketsForHouse(
        house: this, filterOpenTickets: false, showOldestFirst: false);
  }

  Future<void> addTicket(
      {required String task,
      required String description,
      required String? imageUrl}) async {
    await FirestoreDataService().addTicketToHouse(
        house: this, task: task, description: description, imageUrl: imageUrl);
  }

  House({
    required this.firestoreRef,
    required this.street,
    required this.houseNumber,
    required this.postalCode,
    required this.city,
  });

  /// Creates a house from a Firestore [DocumentSnapshot]
  factory House.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      Map<String, dynamic> data = doc.data()!;
      return House(
        firestoreRef: doc.reference,
        street: data['street'],
        houseNumber: data['houseNumber'],
        postalCode: data['postalCode'],
        city: data['city'],
      );
    } catch (_) {
      throw HouseDoesntHaveAllFields();
    }
  }

  String get shortAddress {
    return '$street ${houseNumber.toString()}';
  }

  String get longAddress {
    return '$street ${houseNumber.toString()}, $postalCode $city';
  }

  @override
  bool operator ==(covariant House other) =>
      other.street == street &&
      other.houseNumber == houseNumber &&
      other.postalCode == postalCode &&
      other.city == city;

  @override
  int get hashCode {
    const prime = 31;
    int result = 1;
    result = prime * result + street.hashCode;
    result = prime * result + houseNumber.hashCode;
    result = prime * result + postalCode.hashCode;
    result = prime * result + city.hashCode;
    return result;
  }
}
