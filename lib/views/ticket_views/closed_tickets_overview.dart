import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';
import 'package:mein_digitaler_hausmeister/views/ticket_views/ticket_list.dart';
import 'package:provider/provider.dart';

import '../../model_classes.dart/house.dart';
import '../../model_classes.dart/ticket.dart';

/// Displays all closed tickets for a house.
class ClosedTicketsOverview extends StatefulWidget {
  const ClosedTicketsOverview({super.key});

  @override
  State<ClosedTicketsOverview> createState() => _ClosedTicketsOverviewState();
}

class _ClosedTicketsOverviewState extends State<ClosedTicketsOverview> {
  @override
  Widget build(BuildContext context) {
    final House house = ModalRoute.of(context)!.settings.arguments as House;
    return StreamProvider<List<Ticket>>(
        create: (_) => FirestoreDataService()
            .streamTicketsForHouse(house, filterOpenTickets: false),
        initialData: const [],
        builder: (context, child) {
          return TicketList(
            tickets: Provider.of<List<Ticket>>(context),
            canBeEdited: false,
          );
        });
  }
}
