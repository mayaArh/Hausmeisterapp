import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/ticket_service.dart';
import 'package:mein_digitaler_hausmeister/views/ticket_list.dart';
import 'package:provider/provider.dart';

import '../model_classes.dart/house.dart';
import '../model_classes.dart/ticket.dart';

class OpenTicketsOverview extends StatefulWidget {
  const OpenTicketsOverview({super.key});

  @override
  State<OpenTicketsOverview> createState() => _OpenTicketsOverviewState();
}

class _OpenTicketsOverviewState extends State<OpenTicketsOverview> {
  @override
  Widget build(BuildContext context) {
    final House house = ModalRoute.of(context)!.settings.arguments as House;
    return StreamProvider<List<Ticket>>(
        create: (_) => FirestoreDataService()
            .streamTicketsForHouse(house, filterOpenTickets: true),
        initialData: const [],
        builder: (context, child) {
          return TicketList(tickets: Provider.of<List<Ticket>>(context));
        });
  }
}
