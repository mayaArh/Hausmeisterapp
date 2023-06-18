import 'package:flutter/material.dart';

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
                        return ListTile(
                          title: Text(ticket.description),
                        );
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
