import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/colors.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';

import '../../enums/ticket_status.dart';
import '../../model_classes/image.dart';
import '../../model_classes/ticket.dart';

// View for creating a new ticket.
class SingleTicketView extends StatefulWidget {
  const SingleTicketView({Key? key}) : super(key: key);

  @override
  State<SingleTicketView> createState() => _SingleTicketViewState();
}

class _SingleTicketViewState extends State<SingleTicketView> {
  late TextEditingController _topic;
  late TextEditingController _description;
  late Ticket selectedTicket;
  late bool canBeEdited;
  bool hasBeenChanged = false;
  bool isInitialized = false;
  String? _imageUrl;

  final FirestoreDataService _ticketService = FirestoreDataService();

  @override
  void initState() {
    super.initState();
    _topic = TextEditingController();
    _description = TextEditingController();
  }

  @override
  void dispose() {
    _topic.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
      selectedTicket = arguments['ticket'] as Ticket;
      canBeEdited = arguments['canBeEdited'] as bool;
      _imageUrl = selectedTicket.imageUrl;
      _topic.text = selectedTicket.topic;
      _description.text = selectedTicket.description;
      isInitialized = true;
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
              '${selectedTicket.date}, ${selectedTicket.firstName} ${selectedTicket.lastName}'),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            _displayTopic(),
            _displayDescription(),
            _displayUserImage(_imageUrl, selectedTicket),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _displaySaveButton(),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: selectedTicket.status == TicketStatus.open
                        ? const MaterialStatePropertyAll(green)
                        : MaterialStatePropertyAll(Colors.deepOrange.shade400),
                    minimumSize: MaterialStateProperty.all(const Size(170, 43)),
                  ),
                  onPressed: () async {
                    if (selectedTicket.status == TicketStatus.open) {
                      await _ticketService.updateTicketStatus(
                        selectedTicket,
                        TicketStatus.done,
                      );
                    } else {
                      await _ticketService.updateTicketStatus(
                        selectedTicket,
                        TicketStatus.open,
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: selectedTicket.status == TicketStatus.open
                      ? const Text(
                          'als fertiggestellt markieren',
                          selectionColor: Colors.green,
                        )
                      : const Text(
                          'Als offen markieren',
                          selectionColor: Colors.deepOrange,
                        ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ]),
        ));
  }

  Widget _displaySaveButton() {
    return canBeEdited
        ? ElevatedButton(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(const Size(170, 43)),
              backgroundColor: !hasBeenChanged
                  ? MaterialStatePropertyAll(Colors.blueGrey.shade200)
                  : const MaterialStatePropertyAll(Colors.blueGrey),
            ),
            onPressed: () async {
              if (hasBeenChanged) {
                if (_imageUrl != selectedTicket.imageUrl) {
                  await _ticketService.changeTicketImage(
                      selectedTicket, _imageUrl);
                }
                if (_topic.text != selectedTicket.topic) {
                  await _ticketService.changeTicketTopic(
                    selectedTicket,
                    _topic.text,
                  );
                }
                if (_description.text != selectedTicket.description) {
                  await _ticketService.changeTicketDescription(
                    selectedTicket,
                    _description.text,
                  );
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Änderungen speichern'),
          )
        : Container(height: 43);
  }

  Widget _displayTopic() {
    return Container(
      padding: const EdgeInsets.all(3.5),
      child: TextField(
        controller: _topic,
        keyboardType: TextInputType.text,
        readOnly: !canBeEdited,
        textAlign: TextAlign.left,
        onChanged: (value) {
          setState(() {
            hasBeenChanged = true;
          });
        },
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _displayDescription() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: SizedBox(
        child: SingleChildScrollView(
          child: TextField(
            controller: _description,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            readOnly: !canBeEdited,
            onChanged: (value) {
              setState(() {
                hasBeenChanged = true;
              });
            },
            decoration: _description.text == ''
                ? const InputDecoration(
                    hintText: 'Problembeschreibung',
                    border: InputBorder.none,
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _displayUserImage(String? imgUrl, Ticket ticket) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: UserImage(
        onFileChanged: (imageUrl) {
          setState(() async {
            setState(() {
              hasBeenChanged = true;
            });
            await _ticketService.deleteStorageImage(_imageUrl);
            _imageUrl = imageUrl;
          });
        },
        initialImageUrl: imgUrl,
        canBeEdited: canBeEdited,
      ),
    );
  }
}
