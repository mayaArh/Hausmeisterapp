import 'package:mein_digitaler_hausmeister/model_classes.dart/ticket.dart';

import '../services/firestore_crud/ticket_service.dart';

abstract class Staff {
  final String firstName;
  final String lastName;
  String email;
  String phoneNumber;
  List<Ticket> tickets = [];

  Staff({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  void addTicket(Ticket ticket) {
    tickets.add(ticket);
  }
}

class Janitor extends Staff {
  Janitor({
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
  });
}

class BuildingManagement extends Staff {
  BuildingManagement({
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
  });
}
