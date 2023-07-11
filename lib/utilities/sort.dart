import 'package:intl/intl.dart';

import '../model_classes/house.dart';
import '../model_classes/ticket.dart';

/// Class for sorting app objects.
class Sort {
  /// Sorts the given list of houses by alphabetical order of the street and
  /// then by house number starting with the lowest number.
  static void sortHouses(List<House> houses) {
    houses.sort((houseA, houseB) {
      int streetComparison = houseA.street.compareTo(houseB.street);
      if (streetComparison != 0) {
        return streetComparison;
      } else {
        return houseA.houseNumber.compareTo(houseB.houseNumber);
      }
    });
  }

  /// Sorts the given list of tickets by the date and time of the ticket creation,
  /// starting with the oldest ticket.
  static void sortTicketsByDateTime(List<Ticket> tickets) {
    tickets.sort((ticketA, ticketB) {
      final dateTimeA = DateFormat('dd.MM.yyyy, HH:mm').parse(ticketA.dateTime);
      final dateTimeB = DateFormat('dd.MM.yyyy, HH:mm').parse(ticketB.dateTime);
      return dateTimeA.compareTo(dateTimeB);
    });
  }
}
