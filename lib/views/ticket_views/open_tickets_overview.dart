import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/views/ticket_views/ticket_list.dart';
import 'package:provider/provider.dart';

import '../../model_classes/ticket.dart';
import '../../services/providers/selected_house_provider.dart';

/// Displays all open tickets for a house
class OpenTicketsOverview extends StatefulWidget {
  const OpenTicketsOverview({super.key});

  @override
  State<OpenTicketsOverview> createState() => _OpenTicketsOverviewState();
}

class _OpenTicketsOverviewState extends State<OpenTicketsOverview> {
  @override
  Widget build(BuildContext context) {
    final houseProvider = Provider.of<SelectedHouseProvider>(context);
    final selectedHouse = houseProvider.selectedHouse!;
    return StreamProvider<List<Ticket>>(
        create: (_) => selectedHouse.streamOpenTickets(),
        initialData: const [],
        builder: (context, child) {
          return TicketList(
            tickets: Provider.of<List<Ticket>>(context),
            ticketsHaveStatusOpen: true,
          );
        });
  }
}
