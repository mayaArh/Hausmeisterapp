import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mein_digitaler_hausmeister/enums/ticket_status.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';
import 'package:mein_digitaler_hausmeister/utilities/show_error_dialog.dart';

import '../model_classes.dart/house.dart';

import '../model_classes.dart/image.dart';
import '../model_classes.dart/ticket.dart';

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
  final FirestoreDataService _ticketService = FirestoreDataService();
  late final TextEditingController _topic;
  late final TextEditingController _description;
  String? _imageUrl;

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
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3.5),
            child: TextField(
                controller: _topic,
                keyboardType: TextInputType.text,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                    hintText: 'Thema', border: InputBorder.none)),
          ),
          Container(
            height: 200,
            padding: const EdgeInsets.all(3.5),
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.grey), // Add border properties here
              borderRadius:
                  BorderRadius.circular(4.0), // Add border radius if desired
            ),
            child: SizedBox(
                child: SingleChildScrollView(
              child: TextField(
                  controller: _description,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                      hintText: 'Problembeschreibung',
                      border: InputBorder.none)),
            )),
          ),
          Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              border: Border.all(
                  style: BorderStyle.none), // Add border properties here
              borderRadius:
                  BorderRadius.circular(4.0), // Add border radius if desired
            ),
            child: UserImage(
              onFileChanged: (imageUrl) {
                setState(() {
                  _ticketService.deleteStorageImage(_imageUrl);

                  _imageUrl = imageUrl;
                });
              },
              initialImageUrl: null,
              canBeEdited: true,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          OutlinedButton(
              style: const ButtonStyle(
                  elevation: MaterialStatePropertyAll(1.0),
                  foregroundColor: MaterialStatePropertyAll(Colors.black54),
                  backgroundColor: MaterialStatePropertyAll(
                      Color.fromARGB(255, 126, 216, 130))),
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
                    image: _imageUrl,
                    status: TicketStatus.open,
                  );
                  widget.onTicketAdded(newTicket);
                  Navigator.pop(context);
                }
              },
              child: const Text('Ticket abschicken'))
        ],
      )),
    );
  }
}
