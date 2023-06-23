import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/views/administration_views/closed_tickets_overview.dart';

import '../../enums/ticket_status.dart';
import '../../model_classes.dart/house.dart';
import '../../model_classes.dart/ticket.dart';
import 'create_ticket_view.dart';
import 'open_tickets_overview.dart';

class TicketOverview extends StatefulWidget {
  const TicketOverview({super.key});

  @override
  State<TicketOverview> createState() => TicketOverviewState();
}

class TicketOverviewState extends State<TicketOverview> {
  final _bottomNavigationBarItems = const [
    BottomNavigationBarItem(
        icon: Icon(Icons.check_box_outline_blank_sharp),
        label: 'Offen',
        backgroundColor: Colors.deepOrange),
    BottomNavigationBarItem(
        icon: Icon(Icons.check_box_outlined),
        label: 'Fertiggestellt',
        backgroundColor: Colors.green)
  ];
  int _currentIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final House house = ModalRoute.of(context)!.settings.arguments as House;
    return Scaffold(
      appBar: AppBar(
        title: Text(house.longAddress),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TicketCreationView(
                      house: house,
                      onTicketAdded: (Ticket newTicket) {
                        setState(() {});
                      }),
                ),
              );
              setState(() {});
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: PageView(
          controller: _pageController,
          onPageChanged: (newIndex) {
            setState(() {
              _currentIndex = newIndex;
            });
          },
          children: [
            OpenTicketsOverview(onTicketAdded: (Ticket newTicket) {
              setState(() {});
            }),
            const ClosedTicketsOverview(),
          ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _bottomNavigationBarItems,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _pageController.animateToPage(index,
                duration: const Duration(milliseconds: 550),
                curve: Curves.fastEaseInToSlowEaseOut);
          });
        },
      ),
    );
  }
}
