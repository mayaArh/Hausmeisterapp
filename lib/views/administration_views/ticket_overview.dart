import 'package:flutter/material.dart';

import '../../model_classes.dart/house.dart';
import '../../model_classes.dart/ticket.dart';
import 'create_ticket_view.dart';

class TicketOverview extends StatefulWidget {
  const TicketOverview({super.key});

  @override
  State<TicketOverview> createState() => _TicketOverviewState();
}

class _TicketOverviewState extends State<TicketOverview> {
  @override
  Widget build(BuildContext context) {
    final House house = ModalRoute.of(context)!.settings.arguments as House;
    Ticket? newTicket;
    return Scaffold(
        appBar: AppBar(
          title: Text(house.longAddress),
          actions: [
            IconButton(
              onPressed: () async {
                newTicket = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TicketCreationView(house: house),
                  ),
                );
                setState(() {});
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: FutureBuilder<List<Ticket>>(
            future: getTickets(house, newTicket),
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
                                            'erstellt am: ${ticket.dateTime}')),
                                    Center(
                                      child: Text(
                                          'Ticketersteller: ${ticket.firstName} ${ticket.lastName}'),
                                    ),
                                    Center(child: Text(ticket.description)),
                                  ])),
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                          onPressed: () {},
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

  Future<List<Ticket>> getTickets(House house, Ticket? newTicket) async {
    final List<Ticket> allTickets = await house.allTickets;
    if (newTicket != null) {
      allTickets.add(newTicket);
    }
    return allTickets;
  }
}
