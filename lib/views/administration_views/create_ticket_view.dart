import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model_classes.dart/house.dart';
import '../../model_classes.dart/ticket.dart';
//import 'package:image_picker/image_picker.dart';

class ImageCouldNotBeReadAsBytes implements Exception {}

class TicketCreationView extends StatefulWidget {
  const TicketCreationView({super.key});

  @override
  State<TicketCreationView> createState() => _TicketCreationViewState();
}

class _TicketCreationViewState extends State<TicketCreationView> {
  //DatabaseTicket? _ticket;
  //late final TicketService _ticketService;

  late final TextEditingController _topic;
  late final TextEditingController _description;
  //late final ImagePicker _imagePicker;
  //final FirestoreTicketService _ticketService = FirestoreTicketService();

  //XFile? _image;
  //String _imageLocation = '';

  /*void _getImage(BuildContext context) async {
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
  }*/

  @override
  void initState() {
    _topic = TextEditingController();
    _description = TextEditingController();
    //_imagePicker = ImagePicker();
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
    final HouseA house = ModalRoute.of(context)!.settings.arguments as HouseA;

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
            SizedBox(
              height: 100,
              child: ElevatedButton.icon(
                  onPressed: () {
                    //_getImage(context);
                    //Image.file(File(_image!.path), height: 200);
                  },
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text('Bild hinzufügen')),
            ),
            TextButton(
                onPressed: () {
                  final topic = _topic.text;
                  final description = _description.text;
                  final dateTime =
                      DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.now());
                  house.addTicket(topic, description, dateTime, '');
                },
                child: const Text('Ticket abschicken'))
          ],
        ));
  }
}
