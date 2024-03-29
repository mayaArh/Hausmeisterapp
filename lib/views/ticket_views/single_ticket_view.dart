import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/colors.dart';
import 'package:mein_digitaler_hausmeister/model_classes/house.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';
import 'package:provider/provider.dart';

import '../../enums/ticket_status.dart';
import '../../model_classes/image.dart';
import '../../model_classes/ticket.dart';
import '../../services/auth/auth_service.dart';
import '../../services/providers/selected_house_provider.dart';
import '../../services/providers/selected_ticket_provider.dart';

// View for creating a new ticket.
class SingleTicketView extends StatefulWidget {
  const SingleTicketView({Key? key}) : super(key: key);

  @override
  State<SingleTicketView> createState() => _SingleTicketViewState();
}

class _SingleTicketViewState extends State<SingleTicketView> {
  late TextEditingController _task;
  late TextEditingController _description;
  late Ticket selectedTicket;
  late House selectedHouse;
  late bool userHasEditPermission;
  bool hasBeenChanged = false;
  bool isInitialized = false;
  bool saveChanges = false;
  bool canBeEdited = false;
  String? _imageUrl;
  final List<String> _imageUrls = [];

  final FirestoreDataService _firestoreDataService = FirestoreDataService();

  @override
  void initState() {
    super.initState();
    _task = TextEditingController();
    _description = TextEditingController();
  }

  @override
  void dispose() {
    _task.dispose();
    _description.dispose();
    if (!saveChanges) {
      _deleteImages();
    }
    super.dispose();
  }

  Future<void> _deleteImages() async {
    for (var image in _imageUrls) {
      await _firestoreDataService.deleteStorageImage(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      final ticketProvider = Provider.of<SelectedTicketProvider>(context);
      selectedTicket = ticketProvider.selectedTicket!;
      final houseProvider = Provider.of<SelectedHouseProvider>(context);
      selectedHouse = houseProvider.selectedHouse!;
      canBeEdited = selectedTicket.status == TicketStatus.open;
      _imageUrl = selectedTicket.imageUrl;
      _task.text = selectedTicket.task;
      _description.text = selectedTicket.description;
      isInitialized = true;
      userHasEditPermission =
          selectedTicket.uId == AuthService.firebase().currentUser!.uid ||
              AuthService.firebase().currentUser!.email ==
                  'maya.arhold11@gmail.com';
    }

    return Scaffold(
        appBar: AppBar(
            title: canBeEdited
                ? Text('${selectedTicket.creationDateTime} Uhr')
                : Text('${selectedTicket.completionDateTime} Uhr')),
        body: SingleChildScrollView(
          child: Column(children: [
            _displayTask(),
            _displayUserImage(_imageUrl),
            _displayDescription(),
            const SizedBox(height: 33),
            canBeEdited
                ? Row(
                    mainAxisAlignment: userHasEditPermission
                        ? MainAxisAlignment.spaceEvenly
                        : MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _displaySaveButton(),
                      userHasEditPermission
                          ? _displayDeleteButton()
                          : Container(
                              padding: EdgeInsets.only(
                                  top: _imageUrl == null ? imageHeight : 0),
                            ),
                    ],
                  )
                : Container(),
            Align(
                alignment: Alignment.center,
                child: Padding(
                    padding: EdgeInsets.only(
                        top: canBeEdited
                            ? MediaQuery.of(context).size.height * 0.025
                            : MediaQuery.of(context).size.height * 0.055),
                    child: Column(children: [
                      Text(
                        selectedHouse.longAddress,
                      ),
                      const SizedBox(height: 15),
                      canBeEdited
                          ? Text(
                              'erstellt von: ${selectedTicket.nameCreator}',
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
                            )
                          : Text(
                              'erstellt von ${selectedTicket.nameCreator} am ${selectedTicket.creationDate}',
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic),
                            ),
                      const SizedBox(height: 10),
                      selectedTicket.nameCompleter != '' &&
                              selectedTicket.status == TicketStatus.done
                          ? Text(
                              'erledigt von ${selectedTicket.nameCompleter} am ${selectedTicket.completionDate}',
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic))
                          : Container()
                    ])))
          ]),
        ));
  }

  Widget _displaySaveButton() {
    return userHasEditPermission
        ? ElevatedButton(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(const Size(170, 43)),
              foregroundColor: const MaterialStatePropertyAll(darkBlack),
              backgroundColor: !hasBeenChanged
                  ? const MaterialStatePropertyAll(lightGrey)
                  : const MaterialStatePropertyAll(green),
              elevation: const MaterialStatePropertyAll(1.0),
            ),
            onPressed: () async {
              if (hasBeenChanged) {
                saveChanges = true;
                if (_imageUrl != selectedTicket.imageUrl) {
                  _imageUrls.map((image) {
                    if (image != _imageUrl) {
                      _firestoreDataService.deleteStorageImage(image);
                    }
                  });
                  await selectedTicket.addOrChangeImage(_imageUrl);
                }
                if (_task.text != selectedTicket.task) {
                  await selectedTicket.changeTask(_task.text);
                }
                if (_description.text != selectedTicket.description) {
                  await selectedTicket.changeDescription(
                    _description.text,
                  );
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Änderungen speichern',
                style: TextStyle(fontWeight: FontWeight.w500)),
          )
        : Container(height: 43);
  }

  Widget _displayDeleteButton() {
    return ElevatedButton(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
              const TextStyle(fontWeight: FontWeight.w500)),
          minimumSize: MaterialStateProperty.all(const Size(170, 43)),
          foregroundColor: const MaterialStatePropertyAll(darkBlack),
          backgroundColor: const MaterialStatePropertyAll(lightOrange),
          elevation: const MaterialStatePropertyAll(1.0),
        ),
        onPressed: () async {
          await selectedTicket.delete();
          Navigator.pop(context);
        },
        child: const Text(
          'Löschen',
        ));
  }

  Widget _displayTask() {
    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: TextField(
        controller: _task,
        keyboardType: TextInputType.text,
        readOnly: !canBeEdited || !userHasEditPermission,
        textAlign: TextAlign.center,
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
    final isDescriptionEmpty = _description.text.isEmpty;

    return Container(
        height: MediaQuery.of(context).size.height * 0.2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: SizedBox(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextField(
                controller: _description,
                keyboardType: TextInputType.text,
                maxLines: null,
                readOnly: !canBeEdited || !userHasEditPermission,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  setState(() {
                    hasBeenChanged = true;
                  });
                },
                decoration: isDescriptionEmpty
                    ? InputDecoration(
                        hintText:
                            canBeEdited ? 'Nähere Informationen...' : null,
                        border: InputBorder.none,
                      )
                    : null,
              ),
            ),
          ),
        ));
  }

  Widget _displayUserImage(String? imgUrl) {
    return (canBeEdited && userHasEditPermission) || imgUrl != null
        ? Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              border: Border.all(style: BorderStyle.none),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: UserImage(
              onFileChanged: (imageUrl) {
                setState(() {
                  setState(() {
                    hasBeenChanged = true;
                  });
                  if (imageUrl != null) {
                    _imageUrls.add(imageUrl);
                  }
                  _imageUrl = imageUrl;
                });
              },
              initialImageUrl: imgUrl,
              canBeEdited: (canBeEdited && userHasEditPermission),
            ),
          )
        : Container();
  }
}
