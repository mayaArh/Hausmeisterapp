import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/enums/ticket_status.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/ticket_service.dart';

import '../../model_classes.dart/house.dart';
import '../../model_classes.dart/ticket.dart';
import 'create_ticket_view.dart';

class OpenTicketsOverview extends StatefulWidget {
  final Function(Ticket) onTicketAdded;

  const OpenTicketsOverview({super.key, required this.onTicketAdded});

  @override
  State<OpenTicketsOverview> createState() => _OpenTicketsOverviewState();
}

class _OpenTicketsOverviewState extends State<OpenTicketsOverview> {
  FirestoreTicketService _ticketService = FirestoreTicketService();

  @override
  Widget build(BuildContext context) {
    final House house = ModalRoute.of(context)!.settings.arguments as House;
    Ticket? newTicket;
    return Scaffold(
        body: FutureBuilder<List<Ticket>>(
            future: getOpenTickets(house, newTicket),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  final tickets = snapshot.data;
                  if (tickets != null && tickets.isNotEmpty) {
                    return ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black87),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Row(children: [
                                  Expanded(
                                      child: Column(children: [
                                    Center(
                                        child: Text(
                                      ticket.topic,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                    Center(
                                        child: Text(
                                            'erstellt am: ${ticket.dateTime}')),
                                  ])),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                          onPressed: () async {
                                            _ticketService.deleteTicket(ticket);
                                            widget.onTicketAdded(ticket);
                                          },
                                          icon: const Icon(
                                              Icons.delete_outlined)))
                                ]),
                              ),
                            ]);
                      },
                    );
                  } else {
                    return const Text('Es sind noch keine Tickets vorhanden');
                  }
                default:
                  return const CircularProgressIndicator();
              }
            }));
  }

  Future<List<Ticket>> getOpenTickets(House house, Ticket? newTicket) async {
    final List<Ticket> allTickets = await house.allTickets;
    for (Ticket ticket in allTickets) {
      if (ticket.status != TicketStatus.open) {
        allTickets.remove(ticket);
      }
    }
    if (newTicket != null) {
      allTickets.add(newTicket);
    }
    return allTickets;
  }
}
