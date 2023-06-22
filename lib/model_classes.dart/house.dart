import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mein_digitaler_hausmeister/model_classes.dart/staff.dart';
import 'package:mein_digitaler_hausmeister/model_classes.dart/ticket.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_service.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/ticket_service.dart';

import '../services/auth/auth_user.dart';
import '../services/firestore_crud/firestore_data_provider.dart';

class House {
  final String street;
  final int houseNumber;
  final int postalCode;
  final String city;

  final FirestoreDataProvider dataProvider = FirestoreDataProvider();
  final FirestoreTicketService _ticketService = FirestoreTicketService();
  final AuthUser user = AuthService.firebase().currentUser!;

  House({
    required this.street,
    required this.houseNumber,
    required this.postalCode,
    required this.city,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      street: json['Strasse'],
      houseNumber: json['Hausnummer'],
      postalCode: json['Postleitzahl'],
      city: json['Ort'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Strasse': street,
      'Hausnummer': houseNumber,
      'Postleitzahl': postalCode,
      'Ort': city,
    };
  }

  String get shortAddress {
    return '$street ${houseNumber.toString()}';
  }

  String get longAddress {
    return '$street ${houseNumber.toString()}, $city';
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

  Future<List<Ticket>> get allTickets async {
    List<Ticket> tickets = [];
    if (dataProvider.snapshots != null) {
      for (final QuerySnapshot<Map<String, dynamic>> snapshot
          in dataProvider.snapshots!) {
        for (final QueryDocumentSnapshot<Map<String, dynamic>> houseDoc
            in snapshot.docs) {
          final House house = House.fromJson(houseDoc.data());

          if (house == this) {
            final QuerySnapshot<Map<String, dynamic>> ticketDocs =
                await houseDoc.reference.collection('Tickets').get();

            for (final QueryDocumentSnapshot<
                Map<String, dynamic>> ticketSnapshot in ticketDocs.docs) {
              final Map<String, dynamic> ticketData = ticketSnapshot.data();
              final Ticket ticket = Ticket.fromJson(ticketData);
              tickets.add(ticket);
            }
          }
        }
      }
    }

    return tickets;
  }
}
