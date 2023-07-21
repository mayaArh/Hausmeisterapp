import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:mein_digitaler_hausmeister/enums/ticket_status.dart';
import 'package:mein_digitaler_hausmeister/model_classes/house.dart';
import 'package:mein_digitaler_hausmeister/model_classes/ticket.dart';

import '../../constants/ticket_db_fields.dart';
import '../../utilities/sort.dart';
import '../auth/auth_service.dart';
import '../auth/firebase_auth_provider.dart';

mixin FirestoreTicketService {
  final storage = FirebaseStorage.instance;
  int _nrOfOpenTickets = 0;
  int _nrOfClosedTickets = 0;
  int get nrOfOpenTickets => _nrOfOpenTickets;
  int get nrOfClosedTickets => _nrOfClosedTickets;

  //returns a stream of tickets for the given house. If filterOpenTickets is true,
  //all tickets with status open are returned, otherwise all tickets
  //with status done are returned
  Stream<List<Ticket>> streamTicketsForHouse(
      {required House house,
      required bool filterOpenTickets,
      required bool showOldestFirst}) {
    filterOpenTickets ? _nrOfOpenTickets = 0 : _nrOfClosedTickets = 0;
    return house.firestoreRef.collection('Tickets').snapshots().map((data) {
      List<Ticket> ticketList = [];
      for (QueryDocumentSnapshot<Map<String, dynamic>> ticketDoc in data.docs) {
        final ticketData = ticketDoc.data();
        if (filterOpenTickets &&
            ticketData[statusField] == TicketStatus.open.name) {
          final ticket = Ticket.fromFirestore(ticketDoc);
          _nrOfOpenTickets++;
          ticketList.add(ticket);
        } else if (filterOpenTickets == false &&
            ticketDoc.data()[statusField] == TicketStatus.done.name) {
          _nrOfClosedTickets++;
          final ticket = Ticket.fromFirestore(ticketDoc);
          ticketList.add(ticket);
        }
        Sort.sortTicketsByDateTime(ticketList, showOldestFirst);
      }
      return ticketList;
    });
  }

  //adds a new ticket to the given house
  Future<void> addTicketToHouse({
    required House house,
    required String task,
    required String description,
    required String? imageUrl,
  }) async {
    final staffUser = await AuthService.firebase().currentStaff;
    final creationDateTime =
        DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.now());
    DocumentReference<Map<String, dynamic>> ticketRef =
        house.firestoreRef.collection('Tickets').doc();
    ticketRef.set({
      nameCreatorField: '${staffUser!.firstName} ${staffUser.lastName}',
      nameCompleterField: '',
      creationDateTimeField: creationDateTime,
      completionDateTimeField: '',
      taskField: task,
      descriptionField: description,
      imageUrlField: imageUrl ?? '',
      statusField: 'open',
      uIdField: FirebaseAuthProvider().currentUser!.uid,
    });
  }

  //changes the ticket topic to the given topic
  Future<void> changeTicketTask(Ticket ticket, String newTask) async {
    ticket.task = newTask;
    await ticket.firestoreRef.update({taskField: newTask});
  }

  //changes the ticket description to the given description
  Future<Ticket> changeTicketDescription(
      Ticket ticket, String newDescription) async {
    ticket.description = newDescription;
    await ticket.firestoreRef.update({descriptionField: newDescription});
    return ticket;
  }

  //updates the status of the given ticket to the new status
  //if the new status is done, the name of the staff member who
  //completed the ticket is added to the ticket
  Future<void> updateTicketStatus(Ticket ticket, TicketStatus newStatus) async {
    ticket.status = newStatus;
    final currentStaff = await FirebaseAuthProvider().currentStaff;
    if (newStatus == TicketStatus.done) {
      await _addTicketCompleter(
          ticket, '${currentStaff!.firstName} ${currentStaff.lastName}');
      await _addTicketCompletionDateTime(ticket);
    } else {
      await _removeTicketCompleter(ticket);
      await _removeTicketCompletionDateTime(ticket);
    }
    await ticket.firestoreRef.update({statusField: newStatus.name});
  }

  Future<void> _addTicketCompleter(Ticket ticket, String name) async {
    await _setTicketCompleter(ticket, name);
  }

  Future<void> _removeTicketCompleter(Ticket ticket) async {
    await _setTicketCompleter(ticket, null);
  }

  Future<void> _setTicketCompleter(Ticket ticket, String? name) async {
    ticket.nameCompleter = name;
    await ticket.firestoreRef
        .update({nameCompleterField: ticket.nameCompleter});
  }

  Future<void> _addTicketCompletionDateTime(Ticket ticket) async {
    final completionDateTime =
        DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.now());
    await _setTicketCompletionDateTime(ticket, completionDateTime);
  }

  Future<void> _removeTicketCompletionDateTime(Ticket ticket) async {
    await _setTicketCompletionDateTime(ticket, null);
  }

  Future<void> _setTicketCompletionDateTime(
      Ticket ticket, String? dateTime) async {
    ticket.completionDateTime = dateTime;
    await ticket.firestoreRef
        .update({completionDateTimeField: ticket.completionDateTime});
  }

  /// changed the image of the given ticket to the new image
  Future<Ticket> addOrChangeTicketImage(
      Ticket ticket, String? newImageUrl) async {
    ticket.imageUrl = newImageUrl;
    await ticket.firestoreRef.update({imageUrlField: newImageUrl});
    return ticket;
  }

  //deletes the ticket from the database and the corresponding image from the storage
  Future<void> deleteTicket(Ticket ticket) async {
    if (ticket.imageUrl != null) {
      deleteStorageImage(ticket.imageUrl!);
    }
    await Future.wait([ticket.firestoreRef.delete()]);
  }

  //deletes the image from the storage
  Future<void> deleteStorageImage(String? imageUrl) async {
    if (imageUrl != null) {
      final imageRef = storage.refFromURL(imageUrl);
      await imageRef.delete();
    }
  }
}
