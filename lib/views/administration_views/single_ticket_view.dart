import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/enums/ticket_status.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/ticket_service.dart';

import '../../model_classes.dart/image.dart';
import '../../model_classes.dart/ticket.dart';

class SingleTicketView extends StatefulWidget {
  final Ticket selectedTicket;
  final Function(Ticket) onTicketChanged;
  final FirestoreTicketService _ticketService = FirestoreTicketService();

  SingleTicketView(
      {super.key, required this.selectedTicket, required this.onTicketChanged});

  @override
  State<SingleTicketView> createState() => _SingleTicketViewState();
}

class _SingleTicketViewState extends State<SingleTicketView> {
  String? imageUrl;
  bool imageIsChanged = false;

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
          displayUserImage(imageUrl),
          Text(widget.selectedTicket.description,
              style: const TextStyle(
                fontSize: 24,
              )),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  if (imageUrl != null) {
                    widget._ticketService
                        .changeTicketImage(widget.selectedTicket, imageUrl!);
                  }
                });
              },
              child: const Text('Ticket bearbeiten')),
          ElevatedButton(
              onPressed: () async {
                Ticket ticket;
                if (widget.selectedTicket.status == TicketStatus.open) {
                  ticket = await widget._ticketService.updateTicketStatus(
                      widget.selectedTicket, TicketStatus.done);
                } else {
                  ticket = await widget._ticketService.updateTicketStatus(
                      widget.selectedTicket, TicketStatus.open);
                }
                widget.onTicketChanged(ticket);
                Navigator.pop(context);
              },
              child: widget.selectedTicket.status == TicketStatus.open
                  ? const Text('als fertiggestellt markieren')
                  : const Text('Als offen markieren'))
        ],
      ),
    );
  }

  Widget displayUserImage(String? imgUrl) {
    if (imgUrl != null) {
      return Image.network(imageUrl!);
    } else {
      return UserImage(
        onFileChanged: (imageUrl) {
          setState(() {
            this.imageUrl = imageUrl;
          });
        },
      );
    }
  }
}
