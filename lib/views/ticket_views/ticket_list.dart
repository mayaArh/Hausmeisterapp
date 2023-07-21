import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/colors.dart';
import 'package:mein_digitaler_hausmeister/constants/routes.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';
import 'package:provider/provider.dart';

import '../../enums/ticket_status.dart';
import '../../model_classes/ticket.dart';
import 'dart:async';

import '../../services/providers/selected_ticket_provider.dart';

/// Displays a list of tickets and the possibility to delete them.
class TicketList extends StatefulWidget {
  final List<Ticket> tickets;
  final bool ticketsHaveStatusOpen;

  const TicketList({
    Key? key,
    required this.tickets,
    required this.ticketsHaveStatusOpen,
  }) : super(key: key);

  @override
  State<TicketList> createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  Timer _timer = Timer(const Duration(seconds: 1), () {});
  bool? _showNoTicketsText;
  final FirestoreDataService _ticketService = FirestoreDataService();

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
        itemCount: widget.tickets.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.tickets.length) {
            return Container(
                height: 80,
                width: double.maxFinite,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: middleBlack, width: 1.3),
                  ),
                ));
          } else {
            final ticket = widget.tickets[index];
            bool isChecked = !widget.ticketsHaveStatusOpen;
            return GestureDetector(
              onTap: () {
                final ticketProvider =
                    Provider.of<SelectedTicketProvider>(context, listen: false);
                ticketProvider.selectedTicket = ticket;
                Navigator.of(context).pushNamed(singleTicketRoute);
              },
              child: Container(
                height: 80,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    border: Border(
                        top: const BorderSide(color: middleBlack, width: 1.3),
                        right: _ticketService.nrOfOpenTickets >
                                    _ticketService.nrOfClosedTickets &&
                                widget.ticketsHaveStatusOpen
                            ? const BorderSide(color: middleBlack, width: 1.3)
                            : BorderSide.none,
                        left: _ticketService.nrOfClosedTickets >
                                    _ticketService.nrOfOpenTickets &&
                                !widget.ticketsHaveStatusOpen
                            ? const BorderSide(color: middleBlack, width: 1.3)
                            : BorderSide.none)),
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
                              ticket.task,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: widget.ticketsHaveStatusOpen
                                ? Text('erstellt am ${ticket.creationDate}')
                                : Text('erledigt am ${ticket.completionDate}'),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: widget.ticketsHaveStatusOpen
                          ? Checkbox(
                              value: isChecked,
                              onChanged: (bool? value) async {
                                setState(() {
                                  isChecked = value ?? false;
                                });
                                if (isChecked) {
                                  await ticket.updateStatus(TicketStatus.done);
                                }
                              })
                          : Checkbox(
                              value: isChecked,
                              onChanged: (bool? value) async {
                                setState(() {
                                  isChecked =
                                      value ?? !widget.ticketsHaveStatusOpen;
                                });
                                if (isChecked) {
                                  await ticket.updateStatus(TicketStatus.done);
                                } else {
                                  await ticket.updateStatus(TicketStatus.open);
                                }
                              }),
                    )
                  ],
                ),
              ),
            );
          }
        },
      );
    } else {
      if (_showNoTicketsText != null) {
        return const Center(
          child: Text(
            'Noch keine Tickets vorhanden.',
            style: TextStyle(fontSize: 15),
          ),
        );
      } else {
        return Container();
      }
    }
  }
}
