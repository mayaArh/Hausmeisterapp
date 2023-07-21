import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/colors.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';
import 'package:mein_digitaler_hausmeister/utilities/show_dialog.dart';
import 'package:provider/provider.dart';

import '../../model_classes/image.dart';
import '../../services/providers/selected_house_provider.dart';

// View for creating a new ticket.
class TicketCreationView extends StatefulWidget {
  const TicketCreationView({super.key});

  @override
  State<TicketCreationView> createState() => _TicketCreationViewState();
}

class _TicketCreationViewState extends State<TicketCreationView> {
  final FirestoreDataService _ticketService = FirestoreDataService();
  late final TextEditingController _topic;
  late final TextEditingController _description;
  bool saveChanges = false;
  String? _imageUrl;
  late final FocusNode _descriptionFocusNode;

  @override
  void initState() {
    _topic = TextEditingController();
    _description = TextEditingController();
    _descriptionFocusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _topic.dispose();
    _description.dispose();
    _descriptionFocusNode.dispose();
    if (!saveChanges) {
      _ticketService.deleteStorageImage(_imageUrl);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final houseProvider = Provider.of<SelectedHouseProvider>(context);
    final selectedHouse = houseProvider.selectedHouse!;
    return Scaffold(
        appBar: AppBar(title: const Text('Neues Ticket erstellen')),
        body: Column(children: [
          _displayTask(),
          Expanded(
              child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
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
              _displayDescription(),
              const SizedBox(
                height: 35,
              ),
              Center(
                  child: OutlinedButton(
                      style: const ButtonStyle(
                          minimumSize: MaterialStatePropertyAll(Size(170, 43)),
                          foregroundColor:
                              MaterialStatePropertyAll(buttonTextColor),
                          backgroundColor: MaterialStatePropertyAll(green),
                          elevation: MaterialStatePropertyAll(1.0)),
                      onPressed: () async {
                        saveChanges = true;
                        final topic = _topic.text;
                        final description = _description.text;

                        if (topic.isEmpty) {
                          DialogDisplay.showErrorDialog(
                              context, 'Bitte geben Sie das Problem an.');
                        } else {
                          await _ticketService.addTicketToHouse(
                            house: selectedHouse,
                            task: topic,
                            description: description,
                            imageUrl: _imageUrl,
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Ticket abschicken'))),
              Align(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.04),
                      child: Text(
                        selectedHouse.longAddress,
                      )))
            ],
          )),
        ]));
  }

  Widget _displayTask() {
    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        controller: _topic,
        keyboardType: TextInputType.text,
        textAlign: TextAlign.center,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        decoration: const InputDecoration(
            hintText: 'Was ist zu erledigen?', border: InputBorder.none),
      ),
    );
  }

  Widget _displayDescription() {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(_descriptionFocusNode);
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.2,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: SizedBox(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: TextField(
                  controller: _description,
                  focusNode: _descriptionFocusNode,
                  keyboardType: TextInputType.text,
                  maxLines: null,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black87),
                  decoration: _description.text == ''
                      ? const InputDecoration(
                          hintText: 'Nähere Informationen...',
                          border: InputBorder.none,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ));
  }
}
