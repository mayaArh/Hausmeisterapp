import 'package:flutter/material.dart';

class TicketOverview extends StatefulWidget {
  const TicketOverview({super.key});

  @override
  State<TicketOverview> createState() => _TicketOverviewState();
}

class _TicketOverviewState extends State<TicketOverview> {
  @override
  Widget build(BuildContext context) {
    final List<String> houseAddress =
        ModalRoute.of(context)!.settings.arguments as List<String>;
    final String houseStreet = houseAddress.elementAt(0);
    final int houseNumber = int.parse(houseAddress.elementAt(1));
    final String city = houseAddress.elementAt(2);

    return const Placeholder();
  }
}
