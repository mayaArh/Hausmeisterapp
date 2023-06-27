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
  String? _imageUrl;
  bool _inChangeMode = false;
  TextEditingController? _topicController;
  TextEditingController? _descriptionController;

  @override
  void initState() {
    if (widget.selectedTicket.imageUrl != null) {
      _imageUrl = widget.selectedTicket.imageUrl!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(children: [
            _displayTopic(),
            Align(
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        _inChangeMode = true;
                      });
                    },
                    icon: const Icon(Icons.mode_edit_outlined))),
          ]),
          _displayUserImage(widget.selectedTicket.imageUrl),
          Row(
            children: [
              _displayDescription(),
              if (widget.selectedTicket.description != '')
                Align(
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          _inChangeMode = true;
                        });
                      },
                      icon: const Icon(Icons.mode_edit_outlined)),
                )
            ],
          ),
          ElevatedButton(
              onPressed: () async {
                Ticket? ticket;
                if (_inChangeMode) {
                  if (_imageUrl != widget.selectedTicket.imageUrl) {
                    print(_imageUrl);
                    ticket = await widget._ticketService
                        .changeTicketImage(widget.selectedTicket, _imageUrl!);
                    _inChangeMode = false;
                  }
                  if (_topicController!.text != widget.selectedTicket.topic) {
                    ticket = await widget._ticketService.changeTicketTopic(
                        widget.selectedTicket, _topicController!.text);
                    _inChangeMode = false;
                  }
                  if (_descriptionController!.text !=
                      widget.selectedTicket.description) {
                    ticket = await widget._ticketService
                        .changeTicketDescription(widget.selectedTicket,
                            _descriptionController!.text);
                    _inChangeMode = false;
                  }
                  if (ticket != null) {
                    widget.onTicketChanged(ticket);
                    Navigator.pop(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    !_inChangeMode ? Colors.blueGrey.shade200 : Colors.blueGrey,
              ),
              child: const Text('Ticket speichern')),
          ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: widget.selectedTicket.status ==
                          TicketStatus.open
                      ? MaterialStateProperty.all(Colors.green.shade400)
                      : MaterialStateProperty.all(Colors.deepOrange.shade400)),
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
                  ? const Text(
                      'als fertiggestellt markieren',
                      selectionColor: Colors.green,
                    )
                  : const Text(
                      'Als offen markieren',
                      selectionColor: Colors.deepOrange,
                    ))
        ],
      ),
    ));
  }

  Widget _displayTopic() {
    if (!_inChangeMode) {
      return Text(widget.selectedTicket.topic,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ));
    } else {
      _topicController =
          TextEditingController(text: widget.selectedTicket.topic);
      return Expanded(
          child: TextField(
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        controller: _topicController,
        keyboardType: TextInputType.text,
      ));
    }
  }

  Widget _displayUserImage(String? imgUrl) {
    return UserImage(
      onFileChanged: (imageUrl) {
        _inChangeMode = true;
        setState(() {
          _imageUrl = imageUrl;
        });
      },
      imageUrl: imgUrl,
    );
  }

  Widget _displayDescription() {
    if (!_inChangeMode) {
      return Text(
        widget.selectedTicket.description,
        textAlign: TextAlign.left,
      );
    } else {
      _descriptionController =
          TextEditingController(text: widget.selectedTicket.description);

      return Expanded(
          child: TextField(
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        controller: _descriptionController,
        keyboardType: TextInputType.text,
      ));
    }
  }
}
