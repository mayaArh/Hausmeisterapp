import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/views/single_ticket_view.dart';

import '../model_classes.dart/ticket.dart';

class TicketList extends StatelessWidget {
  final List<Ticket> tickets;
  final Function(Ticket) onTicketChanged;

  const TicketList({
    Key? key,
    required this.tickets,
    required this.onTicketChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return tickets.isNotEmpty
        ? ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return GestureDetector(
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        insetPadding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 80,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black87,
                              width: 2.0,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: SingleTicketView(
                              selectedTicket: ticket,
                              onTicketChanged: onTicketChanged,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black87),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          ticket.topic,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Text('erstellt am: ${ticket.dateTime}'),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        : const Text('Es sind noch keine Tickets vorhanden');
  }
}
