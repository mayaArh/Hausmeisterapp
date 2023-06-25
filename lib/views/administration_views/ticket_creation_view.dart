import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mein_digitaler_hausmeister/enums/ticket_status.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/ticket_service.dart';
import 'package:mein_digitaler_hausmeister/utilities/show_error_dialog.dart';

import '../../model_classes.dart/house.dart';

import '../../model_classes.dart/image.dart';
import '../../model_classes.dart/ticket.dart';

class ImageCouldNotBeReadAsBytes implements Exception {}

class TicketCreationView extends StatefulWidget {
  final House house;
  final Function(Ticket) onTicketAdded;

  const TicketCreationView(
      {super.key, required this.house, required this.onTicketAdded});

  @override
  State<TicketCreationView> createState() => _TicketCreationViewState();
}

class _TicketCreationViewState extends State<TicketCreationView> {
  final FirestoreTicketService _ticketService = FirestoreTicketService();
  late final TextEditingController _topic;
  late final TextEditingController _description;
  String imageUrl = '';

  @override
  void initState() {
    _topic = TextEditingController();
    _description = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _topic.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Neues Ticket erstellen')),
        body: Column(
          children: [
            TextField(
                controller: _topic,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'Thema',
                )),
            TextField(
                controller: _description,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'Problembeschreibung',
                )),
            UserImage(
              onFileChanged: (imageUrl) {
                setState(() {
                  this.imageUrl = imageUrl;
                });
              },
            ),
            OutlinedButton(
                onPressed: () async {
                  final topic = _topic.text;
                  final description = _description.text;
                  final dateTime =
                      DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.now());
                  if (topic.isEmpty) {
                    ErrorDialog.showErrorDialog(
                        context, 'Bitte geben Sie das Thema des Problems an.');
                  } else {
                    final newTicket = await _ticketService.addTicketToHouse(
                      house: widget.house,
                      topic: topic,
                      description: description,
                      dateTime: dateTime,
                      image: imageUrl,
                      status: TicketStatus.open,
                    );
                    widget.onTicketAdded(newTicket);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Ticket abschicken'))
          ],
        ));
  }
}
