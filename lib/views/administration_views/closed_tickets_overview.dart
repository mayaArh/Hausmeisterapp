import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/ticket_service.dart';

import '../../model_classes.dart/house.dart';
import '../../model_classes.dart/ticket.dart';

class ClosedTicketsOverview extends StatefulWidget {
  const ClosedTicketsOverview({super.key});

  @override
  State<ClosedTicketsOverview> createState() => _ClosedTicketsOverviewState();
}

class _ClosedTicketsOverviewState extends State<ClosedTicketsOverview> {
  final FirestoreTicketService _ticketService = FirestoreTicketService();

  @override
  Widget build(BuildContext context) {
    final House house = ModalRoute.of(context)!.settings.arguments as House;
    return Scaffold(
        body: FutureBuilder<List<Ticket>>(
            future: _ticketService.getClosedTickets(house),
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
                                            setState(() {});
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
                  return const Scaffold();
              }
            }));
  }
}
