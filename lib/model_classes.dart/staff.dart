import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_crud/crud_exceptions.dart';

//Represents a user
abstract class Staff {
  final DocumentReference<Map<String, dynamic>> firestoreRef;
  final String firstName;
  final String lastName;
  String email;
  String phoneNumber;

  Staff({
    required this.firestoreRef,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });
}

//Represents a janitor
class Janitor extends Staff {
  Janitor({
    required super.firestoreRef,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
  });

  //Creates a janitor from a Firestore [DocumentSnapshot]
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

//Represents a building manager
class BuildingManager extends Staff {
  BuildingManager({
    required super.firestoreRef,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
  });

  //Creates a building manager from a Firestore [DocumentSnapshot]
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
