import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_service.dart';

import '../../services/firestore_crud/registration_service.dart';

class ImageCouldNotBeReadAsBytes implements Exception {}

class TicketCreationView extends StatefulWidget {
  const TicketCreationView({super.key});

  @override
  State<TicketCreationView> createState() => _TicketCreationViewState();
}

class _TicketCreationViewState extends State<TicketCreationView> {
  late final TicketService _ticketService;

  late final TextEditingController _topic;
  late final TextEditingController _description;
  late final ImagePicker _imagePicker;

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

  Future<DatabaseTicket> createNewTicket(
      {required String topic,
      required String description,
      required String? image}) async {
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _ticketService.getUser(email: email);
    return await _ticketService.createTicket(
        owner: owner, topic: topic, description: description, image: image);
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
                minLines: 8,
                maxLines: 20,
                controller: _description,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  hintText: 'Problembeschreibung',
                )),
            Container(
                //TODO: make it possible to put several images + save them to database
                height: 200,
                width: 400,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                child: _image == null
                    ? ElevatedButton.icon(
                        onPressed: () {
                          _getImage(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white),
                        icon: const Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.black,
                        ),
                        label: const Text(
                          'Bild hinzufügen',
                          style: TextStyle(color: Colors.black),
                        ))
                    : Image.file(
                        File(_image!.path),
                      )),
            TextButton(
              onPressed: () {
                //TODO: actually send to janitor
                //first save ticket in database
                final topic = _topic.text;
                final description = _description.text;
                createNewTicket(
                    topic: topic, description: description, image: ''); //TODO
                Fluttertoast.showToast(
                    msg: "Dein Ticket wurde erfolgreich versendet!",
                    toastLength: Toast.LENGTH_SHORT,
                    textColor: Colors.black,
                    fontSize: 16,
                    backgroundColor: Colors.grey[200]);
              },
              child: const Text('An meinen Hausmeister senden'),
            )
          ],
        ));
  }
}
