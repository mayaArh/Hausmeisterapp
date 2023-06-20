import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mein_digitaler_hausmeister/utilities/show_error_dialog.dart';

import '../../model_classes.dart/house.dart';
import 'package:image_picker/image_picker.dart';

import '../../model_classes.dart/image.dart';
import '../../services/firestore_crud/ticket_service.dart';

class ImageCouldNotBeReadAsBytes implements Exception {}

class TicketCreationView extends StatefulWidget {
  final HouseA house;

  const TicketCreationView({super.key, required this.house});

  @override
  State<TicketCreationView> createState() => _TicketCreationViewState();
}

class _TicketCreationViewState extends State<TicketCreationView> {
  //DatabaseTicket? _ticket;
  //late final TicketService _ticketService;

  late final TextEditingController _topic;
  late final TextEditingController _description;
  late final ImagePicker _imagePicker;
  final FirestoreTicketService _ticketService = FirestoreTicketService();

  XFile? _image;
  String _imageLocation = '';

  void _getImage(BuildContext context) async {
    XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      try {
        final bytes = await image.readAsBytes();
        final imageLocation = base64Encode(bytes);
        setState(() {
          _image = image;
          _imageLocation = imageLocation;
        });
      } catch (_) {
        throw ImageCouldNotBeReadAsBytes();
      }
    }
  }

  @override
  void initState() {
    _topic = TextEditingController();
    _description = TextEditingController();
    _imagePicker = ImagePicker();
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
        appBar: AppBar(title: const Text('Neues Ticket')),
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
            UserImage(),
            TextButton(
                onPressed: () async {
                  final topic = _topic.text;
                  final description = _description.text;
                  final dateTime =
                      DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.now());
                  if (topic.isEmpty) {
                    ErrorDialog.showErrorDialog(
                        context, 'Bitte geben Sie das Thema des Problems an.');
                  } else {
                    final newTicket = await widget.house
                        .addTicket(topic, description, dateTime, '');
                    if (newTicket != null) {
                      Navigator.pop(context, newTicket);
                    }
                  }
                },
                child: const Text('Ticket abschicken'))
          ],
        ));
  }
}
