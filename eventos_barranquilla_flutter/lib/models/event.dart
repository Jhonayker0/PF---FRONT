class Event {
  final String id;
  final String title;
  final String category;
  final String date;
  final String location;
  final String description;
  final List<String> pictureUrls;
  final double price;

  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.description,
    List<String>? pictureUrls,
    this.price = 0.0,
  }) : pictureUrls = pictureUrls ?? const [];

  String get imageUrl => pictureUrls.isNotEmpty ? pictureUrls.first : '';

  factory Event.fromJson(Map<String, dynamic> json) {
    final categories = json['categories'];
    final category = json['category'] ??
        (categories is List && categories.isNotEmpty ? categories.first : '');
    final picture = json['picture'] ?? json['pictures'] ?? json['imageUrl'];
    final pictureUrls = picture is List
        ? picture.map((item) => item.toString()).toList()
        : picture is String && picture.isNotEmpty
            ? [picture]
            : <String>[];

    return Event(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      category: category ?? '',
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      pictureUrls: pictureUrls,
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
      'picture': pictureUrls,
      'price': price,
    };
  }
}
