class Event {
  final String id;
  final String title;
  final String category;
  final String date;
  final String location;
  final String description;
  final String imageUrl;
  final double price;

  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.description,
    required this.imageUrl,
    this.price = 0.0,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final categories = json['categories'];
    final category = json['category'] ??
        (categories is List && categories.isNotEmpty ? categories.first : '');
    final picture = json['picture'];
    final imageUrl = json['imageUrl'] ??
        (picture is List && picture.isNotEmpty ? picture.first : (picture ?? ''));

    return Event(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      category: category ?? '',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      imageUrl: imageUrl ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
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
      'imageUrl': imageUrl,
      'price': price,
    };
  }
}
