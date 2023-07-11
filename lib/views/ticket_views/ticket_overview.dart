import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/routes.dart';
import 'package:mein_digitaler_hausmeister/views/ticket_views/closed_tickets_overview.dart';

import '../../model_classes.dart/house.dart';
import '../../model_classes.dart/ticket.dart';
import 'open_tickets_overview.dart';

//Controls the view of the tickets for a house and allows the user
//to switch between open and closed tickets as well as to create new tickets.
class TicketViewChanger extends StatefulWidget {
  const TicketViewChanger({super.key});

  @override
  State<TicketViewChanger> createState() => TicketViewChangerState();
}

class TicketViewChangerState extends State<TicketViewChanger> {
  List<Ticket> ticketList = [];
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final House house = ModalRoute.of(context)!.settings.arguments as House;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(house.longAddress),
        actions: [
          _currentIndex == 0
              ? IconButton(
                  onPressed: () async {
                    await Navigator.of(context)
                        .pushNamed(ticketCreationRoute, arguments: house);
                    setState(() {});
                  },
                  icon: const Icon(Icons.add),
                )
              : Container(),
        ],
      ),
      body: PageView(
          controller: _pageController,
          onPageChanged: (newIndex) {
            setState(() {
              _currentIndex = newIndex;
            });
          },
          children: const [
            OpenTicketsOverview(),
            ClosedTicketsOverview(),
          ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.check_box_outline_blank_sharp,
              color: Colors.deepOrange,
            ),
            label: 'Offen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined, color: Colors.green),
            label: 'Fertiggestellt',
          )
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
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
