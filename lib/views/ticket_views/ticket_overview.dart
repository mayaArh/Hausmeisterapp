import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/routes.dart';
import 'package:mein_digitaler_hausmeister/views/ticket_views/closed_tickets_overview.dart';
import 'package:provider/provider.dart';

import '../../model_classes/ticket.dart';
import '../../services/providers/selected_house_provider.dart';
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
    final houseProvider = Provider.of<SelectedHouseProvider>(context);
    final selectedHouse = houseProvider.selectedHouse!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(selectedHouse.shortAddress),
        actions: [
          _currentIndex == 0
              ? IconButton(
                  onPressed: () async {
                    await Navigator.of(context).pushNamed(ticketCreationRoute);
                    setState(() {});
                  },
                  padding: const EdgeInsets.only(right: 32),
                  icon: const Icon(
                    Icons.add,
                    size: 29,
                  ),
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
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.check_box_outline_blank_sharp,
              color: Colors.deepOrange.shade400,
            ),
            label: 'Offen',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outlined, color: Colors.green),
            label: 'Fertiggestellt',
          )
        ],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 15,
        unselectedFontSize: 14,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
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
