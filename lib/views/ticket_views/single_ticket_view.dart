import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';

import '../../constants/colors.dart';
import '../../enums/ticket_status.dart';
import '../../model_classes/image.dart';
import '../../model_classes/ticket.dart';

// View for creating a new ticket.
class SingleTicketView extends StatefulWidget {
  const SingleTicketView({super.key});

  @override
  State<SingleTicketView> createState() => _SingleTicketViewState();
}

class _SingleTicketViewState extends State<SingleTicketView> {
  late TextEditingController _topic;
  late TextEditingController _description;
  late bool canBeEdited;
  String? _imageUrl;
  final FirestoreDataService _ticketService = FirestoreDataService();

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
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final Ticket selectedTicket = arguments['ticket'] as Ticket;
    canBeEdited = arguments['canBeEdited'] as bool;
    _topic = TextEditingController(text: selectedTicket.topic);
    _description = TextEditingController(text: selectedTicket.description);
    final initialImageUrl = selectedTicket.imageUrl;
    _imageUrl = selectedTicket.imageUrl;
    bool hasBeenChanged = false;
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${selectedTicket.date}, ${selectedTicket.firstName} ${selectedTicket.lastName}')),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
              padding: const EdgeInsets.all(3.5),
              child: TextField(
                controller: _topic,
                keyboardType: TextInputType.text,
                readOnly: !canBeEdited,
                onChanged: (value) => hasBeenChanged = true,
                textAlign: TextAlign.left,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(border: InputBorder.none),
              )),
          Container(
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
                          onChanged: (value) => hasBeenChanged = true,
                          decoration: _description.text == ''
                              ? const InputDecoration(
                                  hintText: 'Problembeschreibung',
                                  border: InputBorder.none)
                              : null)))),
          Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              border: Border.all(style: BorderStyle.none),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: UserImage(
              onFileChanged: (imageUrl) {
                setState(() {
                  hasBeenChanged = true;
                  _ticketService.deleteStorageImage(_imageUrl);
                  _imageUrl = imageUrl;
                });
              },
              initialImageUrl: initialImageUrl,
              canBeEdited: canBeEdited,
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          canBeEdited
              ? ElevatedButton(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(170, 43)),
                    backgroundColor: !hasBeenChanged
                        ? MaterialStatePropertyAll(Colors.blueGrey.shade200)
                        : const MaterialStatePropertyAll(Colors.blueGrey),
                  ),
                  onPressed: () async {
                    if (canBeEdited && hasBeenChanged) {
                      if (_imageUrl != selectedTicket.imageUrl) {
                        await _ticketService.changeTicketImage(
                          selectedTicket,
                          _imageUrl,
                        );
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
                  child: const Text('Änderungen speichern'))
              : Container(),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: selectedTicket.status == TicketStatus.open
                    ? const MaterialStatePropertyAll(green)
                    : MaterialStateProperty.all(Colors.deepOrange.shade400),
                minimumSize: MaterialStateProperty.all(const Size(170, 43)),
              ),
              onPressed: () async {
                if (selectedTicket.status == TicketStatus.open) {
                  await _ticketService.updateTicketStatus(
                      selectedTicket, TicketStatus.done);
                } else {
                  await _ticketService.updateTicketStatus(
                      selectedTicket, TicketStatus.open);
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
                    )),
          const SizedBox(
            height: 10,
          ),
        ],
      )),
    );
  }
}

/*


  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    final Ticket selectedTicket = arguments['ticket'] as Ticket;
    canBeEdited = arguments['canBeEdited'] as bool;
    _topic = TextEditingController(text: selectedTicket.topic);
    _description = TextEditingController(text: selectedTicket.description);
    _imageUrl = selectedTicket.imageUrl;
    return Align(
        alignment: AlignmentDirectional.topStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 1, child: _displayTopic()),
            Expanded(flex: canBeEdited ? 2 : 7, child: _displayDescription()),
            Expanded(
                flex: canBeEdited ? 5 : 0,
                child: _displayUserImage(selectedTicket.imageUrl)),
            Align(
              alignment: Alignment.center,
              child: Column(children: [
                canBeEdited
                    ? ElevatedButton(
                        style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(170, 43)),
                        ),
                        onPressed: () async {
                          if (canBeEdited) {
                            if (_imageUrl != selectedTicket.imageUrl) {
                              await _ticketService.changeTicketImage(
                                selectedTicket,
                                _imageUrl,
                              );
                            }
                            if (_topic.text != selectedTicket.topic) {
                              await _ticketService.changeTicketTopic(
                                selectedTicket,
                                _topic.text,
                              );
                            }
                            if (_description.text !=
                                selectedTicket.description) {
                              await _ticketService.changeTicketDescription(
                                selectedTicket,
                                _description.text,
                              );
                            }
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Änderungen speichern'))
                    : Container(),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          selectedTicket.status == TicketStatus.open
                              ? const MaterialStatePropertyAll(green)
                              : MaterialStateProperty.all(
                                  Colors.deepOrange.shade400),
                      minimumSize:
                          MaterialStateProperty.all(const Size(170, 43)),
                    ),
                    onPressed: () async {
                      if (selectedTicket.status == TicketStatus.open) {
                        await _ticketService.updateTicketStatus(
                            selectedTicket, TicketStatus.done);
                      } else {
                        await _ticketService.updateTicketStatus(
                            selectedTicket, TicketStatus.open);
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
                          )),
              ]),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${selectedTicket.dateTime},',
                ),
                const SizedBox(width: 8),
                Text(
                  '${selectedTicket.firstName} ${selectedTicket.lastName}',
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ));
  }

  /// Display the topic of the ticket in a text field
  /// that can be edited if the ticket status is open.
  Widget _displayTopic() {
    
  }

  /// Display the description of the ticket in a text field
  /// that can be edited if the ticket status is open.
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
                    readOnly: !canBeEdited,
                    decoration: _description.text == ''
                        ? const InputDecoration(
                            hintText: 'Problembeschreibung',
                            border: InputBorder.none)
                        : null))));
  }

  /// Display the image of the ticket as a [UserImage] widget.
  Widget _displayUserImage(String? imgUrl) {
    return SizedBox(
        height: 200,
        child: ListView(reverse: true, children: [
          UserImage(
            onFileChanged: (imageUrl) {
              setState(() {
                _ticketService.deleteStorageImage(_imageUrl);
                _imageUrl = imageUrl;
              });
            },
            initialImageUrl: imgUrl,
            canBeEdited: canBeEdited,
          )
        ]));
  }
}*/
