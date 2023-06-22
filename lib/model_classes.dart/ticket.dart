class Ticket {
  final String firstName;
  final String lastName;
  final String dateTime;
  final String topic;
  final String description;
  final String? image;

  Ticket({
    required this.firstName,
    required this.lastName,
    required this.dateTime,
    required this.topic,
    required this.description,
    required this.image,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      firstName: json['Vorname'],
      lastName: json['Nachname'],
      dateTime: json['erstellt am'],
      topic: json['Thema'],
      description: json['Problembeschreibung'],
      image: json['Bild'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Vorname': firstName,
      'Nachname': lastName,
      'erstellt am': dateTime,
      'Problembeschreibung': description,
      'Thema': topic,
      'Bild': image,
    };
  }
}
