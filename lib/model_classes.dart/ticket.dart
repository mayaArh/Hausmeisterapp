class TicketA {
  final String firstName;
  final String lastName;
  final DateTime dateTime;
  final String description;
  final String? image;

  TicketA({
    required this.firstName,
    required this.lastName,
    required this.dateTime,
    required this.description,
    required this.image,
  });

  factory TicketA.fromJson(Map<String, dynamic> json) {
    return TicketA(
      firstName: json['Vorname'],
      lastName: json['Nachname'],
      dateTime: DateTime.parse(json['erstellt am']),
      description: json['Problembeschreibung'],
      image: json['Bild'],
    );
  }

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
