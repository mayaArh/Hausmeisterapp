import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/crud_exceptions.dart';

class House {
  final DocumentReference firestoreRef;
  final String street;
  final int houseNumber;
  final int postalCode;
  final String city;

  House({
    required this.firestoreRef,
    required this.street,
    required this.houseNumber,
    required this.postalCode,
    required this.city,
  });

  factory House.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      Map<String, dynamic> data = doc.data()!;
      return House(
        firestoreRef: doc.reference,
        street: data['Strasse'],
        houseNumber: data['Hausnummer'],
        postalCode: data['Postleitzahl'],
        city: data['Ort'],
      );
    } catch (_) {
      throw HouseDoesntHaveAllFields();
    }
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
}
