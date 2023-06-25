import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/enums/ticket_status.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/ticket_service.dart';

import '../../model_classes.dart/image.dart';
import '../../model_classes.dart/ticket.dart';

class SingleTicketView extends StatefulWidget {
  final Ticket selectedTicket;
  final FirestoreTicketService _ticketService = FirestoreTicketService();

  SingleTicketView({super.key, required this.selectedTicket});

  @override
  State<SingleTicketView> createState() => _SingleTicketViewState();
}

class _SingleTicketViewState extends State<SingleTicketView> {
  String? imageUrl;

  @override
  void initState() {
    if (widget.selectedTicket.imageUrl != '') {
      imageUrl = widget.selectedTicket.imageUrl!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            textAlign: TextAlign.left,
            widget.selectedTicket.topic,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (imageUrl != null)
            Image.network(imageUrl!)
          else
            UserImage(
              onFileChanged: (imageUrl) {
                setState(() {
                  this.imageUrl = imageUrl;
                });
              },
            ),
          Text(widget.selectedTicket.description,
              style: const TextStyle(
                fontSize: 24,
              )),
          ElevatedButton(
              onPressed: () {
                if (widget.selectedTicket.status == TicketStatus.open) {
                  widget._ticketService.updateTicketStatus(
                      widget.selectedTicket, TicketStatus.done);
                } else {
                  widget._ticketService.updateTicketStatus(
                      widget.selectedTicket, TicketStatus.open);
                }
              },
              child: widget.selectedTicket.status == TicketStatus.open
                  ? const Text('als fertiggestellt markieren')
                  : const Text('Als offen markieren'))
        ],
      ),
    );
  }
}
