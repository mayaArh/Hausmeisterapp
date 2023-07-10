import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';
import 'package:mein_digitaler_hausmeister/views/single_ticket_view.dart';

import '../model_classes.dart/ticket.dart';

class TicketList extends StatelessWidget {
  final List<Ticket> tickets;
  final bool canBeEdited;

  const TicketList({
    Key? key,
    required this.tickets,
    required this.canBeEdited,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('tickets: $tickets');
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
                                canBeEdited: canBeEdited,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                      height: 70,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black87),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    ticket.topic,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Center(
                                  child:
                                      Text('erstellt am: ${ticket.dateTime}'),
                                ),
                              ],
                            ),
                          ),
                          Align(
                              alignment: Alignment.centerRight,
                              child: canBeEdited
                                  ? IconButton(
                                      onPressed: () async {
                                        print('hi');
                                        FirestoreDataService()
                                            .deleteTicket(ticket);
                                      },
                                      icon: const Icon(Icons.delete_outlined))
                                  : null),
                        ],
                      )));
            },
          )
        : const Text('');
  }
}
