import 'package:cloud_firestore/cloud_firestore.dart';

class TicketService {
  final db = FirebaseFirestore.instance;
  late DocumentReference<Map<String, dynamic>> userDoc;

  TicketService() {}
}
