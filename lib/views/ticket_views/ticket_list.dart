import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/routes.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';

import '../../model_classes/ticket.dart';
import 'dart:async';

/// Displays a list of tickets and the possibility to delete them.
class TicketList extends StatefulWidget {
  final List<Ticket> tickets;
  final bool canBeEdited;

  const TicketList({
    Key? key,
    required this.tickets,
    required this.canBeEdited,
  }) : super(key: key);

  @override
  State<TicketList> createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  Timer _timer = Timer(const Duration(seconds: 1), () {});
  bool? _showNoTicketsText;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 500), () {
      if (widget.tickets.isEmpty) {
        setState(() {
          _showNoTicketsText = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tickets.isNotEmpty) {
      return ListView.builder(
        itemCount: widget.tickets.length,
        itemExtent: MediaQuery.of(context).size.height / 10,
        itemBuilder: (context, index) {
          final ticket = widget.tickets[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(singleTicketRoute, arguments: {
                'ticket': ticket,
                'canBeEdited': widget.canBeEdited
              });
            },
            child: Container(
              height: 80,
              width: double.maxFinite,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black87),
              ),
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            ticket.topic,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text('erstellt am ${ticket.date}'),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () async {
                        FirestoreDataService().deleteTicket(ticket);
                      },
                      icon: const Icon(
                        Icons.delete_outlined,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      if (_showNoTicketsText != null) {
        return const Center(child: Text('Noch keine Tickets vorhanden.'));
      } else {
        return Container();
      }
    }
  }
}
