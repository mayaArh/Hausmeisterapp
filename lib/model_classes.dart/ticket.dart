class Ticket {
  final String firstName;
  final String lastName;
  final DateTime dateTime;
  final String description;
  final String? image;

  Ticket({
    required this.firstName,
    required this.lastName,
    required this.dateTime,
    required this.description,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'Vorname': firstName,
      'Nachname': lastName,
      'erstellt am': dateTime.toIso8601String(),
      'Problembeschreibung': description,
      'Bild': image,
    };
  }
}
