import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/routes.dart';

import '../../model_classes.dart/house.dart';
import '../../model_classes.dart/ticket.dart';

class TicketOverview extends StatefulWidget {
  const TicketOverview({super.key});

  @override
  State<TicketOverview> createState() => _TicketOverviewState();
}

class _TicketOverviewState extends State<TicketOverview> {
  @override
  Widget build(BuildContext context) {
    final HouseA house = ModalRoute.of(context)!.settings.arguments as HouseA;

    return Scaffold(
        appBar: AppBar(
          title: Text(house.longAddress),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(ticketCreationRoute, arguments: house);
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: FutureBuilder<List<TicketA>>(
            future: house.allTickets,
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
                                  child: Column(
                                    children: [
                                      Center(
                                          child: Text(
                                              'erstellt am: ${ticket.dateTime}')),
                                      Center(
                                        child: Text(
                                            'Ticketersteller: ${ticket.firstName} ${ticket.lastName}'),
                                      ),
                                      Center(child: Text(ticket.description)),
                                    ],
                                  )),
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
}
