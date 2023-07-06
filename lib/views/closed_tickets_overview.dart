import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/ticket_service.dart';
import 'package:mein_digitaler_hausmeister/views/ticket_overview.dart';

import '../model_classes.dart/house.dart';
import '../model_classes.dart/ticket.dart';

class ClosedTicketsOverview extends TicketsOverview {
  const ClosedTicketsOverview({
    Key? key,
    required Function(Ticket) onTicketChanged,
  }) : super(key: key, onTicketChanged: onTicketChanged);

  @override
  Future<List<Ticket>> fetchTickets(House house, bool filterOpenTickets) {
    final FirestoreTicketService ticketService = FirestoreTicketService();
    Ticket? newTicket;
    return ticketService.getFilteredTickets(
      house,
      newTicket,
      filterOpenTickets: false,
    );
  }
}
