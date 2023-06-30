import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/ticket_service.dart';
import 'package:mein_digitaler_hausmeister/views/administration_views/single_ticket_view.dart';

import '../../model_classes.dart/house.dart';
import '../../model_classes.dart/ticket.dart';

class ClosedTicketsOverview extends StatefulWidget {
  final Function(Ticket) onTicketChanged;

  const ClosedTicketsOverview({super.key, required this.onTicketChanged});

  @override
  State<ClosedTicketsOverview> createState() => _ClosedTicketsOverviewState();
}

class _ClosedTicketsOverviewState extends State<ClosedTicketsOverview> {
  final FirestoreTicketService _ticketService = FirestoreTicketService();

  @override
  Widget build(BuildContext context) {
    final House house = ModalRoute.of(context)!.settings.arguments as House;
    Ticket? newTicket;
    return Scaffold(
        body: FutureBuilder<List<Ticket>>(
            future: _ticketService.getFilteredTickets(house, newTicket,
                filterOpenTickets: false),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  final tickets = snapshot.data;
                  if (tickets != null && tickets.isNotEmpty) {
                    return ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return GestureDetector(
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  insetPadding: const EdgeInsets.symmetric(
                                      horizontal: 25, vertical: 80),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: SingleTicketView(
                                      selectedTicket: ticket,
                                      onTicketChanged: widget.onTicketChanged,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black87),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Expanded(
                                child: Column(children: [
                              Center(
                                  child: Text(
                                ticket.topic,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )),
                              Center(
                                  child:
                                      Text('erstellt am: ${ticket.dateTime}')),
                            ])),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Text('Es sind noch keine Tickets vorhanden');
                  }
                default:
                  return const Scaffold();
              }
            }));
  }
}
