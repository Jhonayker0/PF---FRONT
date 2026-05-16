class Event {
  final String id;
  final String title;
  final String category;
  final String date;
  final String location;
  final String description;
  final String image;

  Event({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.description,
    required this.image,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '🎭',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'date': date,
      'location': location,
      'description': description,
      'image': image,
    };
  }
}
