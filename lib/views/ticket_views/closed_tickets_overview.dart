import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';
import 'package:mein_digitaler_hausmeister/views/ticket_views/ticket_list.dart';
import 'package:provider/provider.dart';

import '../../model_classes/ticket.dart';
import '../../services/providers/selected_house_provider.dart';

/// Displays all closed tickets for a house.
class ClosedTicketsOverview extends StatefulWidget {
  const ClosedTicketsOverview({super.key});

  @override
  State<ClosedTicketsOverview> createState() => _ClosedTicketsOverviewState();
}

class _ClosedTicketsOverviewState extends State<ClosedTicketsOverview> {
  @override
  Widget build(BuildContext context) {
    final houseProvider = Provider.of<SelectedHouseProvider>(context);
    final selectedHouse = houseProvider.selectedHouse!;
    return StreamProvider<List<Ticket>>(
        create: (_) => FirestoreDataService().streamTicketsForHouse(
            selectedHouse,
            filterOpenTickets: false,
            showOldestFirst: false),
        initialData: const [],
        builder: (context, child) {
          return TicketList(
            tickets: Provider.of<List<Ticket>>(context),
            ticketsHaveStatusOpen: false,
          );
        });
  }
}
