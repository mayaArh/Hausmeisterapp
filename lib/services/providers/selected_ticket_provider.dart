import 'package:flutter/material.dart';

import '../../model_classes/ticket.dart';

class SelectedTicketProvider with ChangeNotifier {
  Ticket? _selectedTicket;

  Ticket? get selectedTicket => _selectedTicket;

  set selectedTicket(Ticket? ticket) {
    _selectedTicket = ticket;
    notifyListeners();
  }
}
