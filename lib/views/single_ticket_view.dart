import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/enums/ticket_status.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/ticket_service.dart';

import '../model_classes.dart/image.dart';
import '../model_classes.dart/ticket.dart';

class SingleTicketView extends StatefulWidget {
  final Ticket selectedTicket;
  final Function(Ticket) onTicketChanged;

  const SingleTicketView(
      {super.key, required this.selectedTicket, required this.onTicketChanged});

  @override
  State<SingleTicketView> createState() => _SingleTicketViewState();
}

class _SingleTicketViewState extends State<SingleTicketView> {
  late final TextEditingController _topic;
  late final TextEditingController _description;
  String? _imageUrl;
  final FirestoreTicketService _ticketService = FirestoreTicketService();

  @override
  void initState() {
    _topic = TextEditingController(text: widget.selectedTicket.topic);
    _description =
        TextEditingController(text: widget.selectedTicket.description);
    if (widget.selectedTicket.imageUrl != null) {
      _imageUrl = widget.selectedTicket.imageUrl!;
    }
    super.initState();
  }

  @override
  void dispose() {
    _topic.dispose();
    _description.dispose();
    super.dispose();
  }

  void _executeOnDialogDismissed() async {
    Ticket changedTicket = widget.selectedTicket;
    if (_imageUrl != widget.selectedTicket.imageUrl) {
      changedTicket = await _ticketService.changeTicketImage(
        changedTicket,
        _imageUrl,
      );
    }
    if (_topic.text != widget.selectedTicket.topic) {
      changedTicket = await _ticketService.changeTicketTopic(
        changedTicket,
        _topic.text,
      );
    }
    if (_description.text != widget.selectedTicket.description) {
      changedTicket = await _ticketService.changeTicketDescription(
        changedTicket,
        _description.text,
      );
    }
    widget.onTicketChanged(changedTicket);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _executeOnDialogDismissed();
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Expanded(child: _displayTopic()),
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: _displayDescription()),
                ],
              ),
              _displayUserImage(widget.selectedTicket.imageUrl),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          widget.selectedTicket.status == TicketStatus.open
                              ? MaterialStateProperty.all(Colors.green.shade400)
                              : MaterialStateProperty.all(
                                  Colors.deepOrange.shade400)),
                  onPressed: () async {
                    Ticket ticket;
                    if (widget.selectedTicket.status == TicketStatus.open) {
                      ticket = await _ticketService.updateTicketStatus(
                          widget.selectedTicket, TicketStatus.done);
                    } else {
                      ticket = await _ticketService.updateTicketStatus(
                          widget.selectedTicket, TicketStatus.open);
                    }

                    widget.onTicketChanged(ticket);
                    Navigator.pop(context);
                  },
                  child: widget.selectedTicket.status == TicketStatus.open
                      ? const Text(
                          'als fertiggestellt markieren',
                          selectionColor: Colors.green,
                        )
                      : const Text(
                          'Als offen markieren',
                          selectionColor: Colors.deepOrange,
                        )),
              const SizedBox(
                height: 32,
              )
            ],
          ),
        ));
  }

  Widget _displayTopic() {
    return Container(
        padding: const EdgeInsets.all(3.5),
        child: TextField(
          controller: _topic,
          keyboardType: TextInputType.text,
          textAlign: TextAlign.left,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: const InputDecoration(border: InputBorder.none),
        ));
  }

  Widget _displayDescription() {
    return Container(
        height: 150,
        padding: const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey), // Add border properties here
          borderRadius:
              BorderRadius.circular(4.0), // Add border radius if desired
        ),
        child: SizedBox(
            child: SingleChildScrollView(
                child: TextField(
                    controller: _description,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: _description.text == ''
                        ? const InputDecoration(
                            hintText: 'Problembeschreibung',
                            border: InputBorder.none)
                        : null))));
  }

  Widget _displayUserImage(String? imgUrl) {
    return UserImage(
      onFileChanged: (imageUrl) {
        setState(() {
          _ticketService.deleteStorageImage(_imageUrl);
          _imageUrl = imageUrl;
        });
      },
      initialImageUrl: imgUrl,
    );
  }
}
