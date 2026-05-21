import '../data/event_categories.dart';

class Event {
  final String id;
  final String title;
  final String category;
  final String categoryGroup;
  final String categorySpecific;
  final String date;
  final String location;
  final String description;
  final List<String> pictureUrls;
  final double price;
  final String organizerName;
  final String organizerId;

  const Event({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryGroup,
    required this.categorySpecific,
    required this.date,
    required this.location,
    required this.description,
    List<String>? pictureUrls,
    this.price = 0.0,
    this.organizerName = '',
    this.organizerId = '',
  }) : pictureUrls = pictureUrls ?? const [];

  String get imageUrl => pictureUrls.isNotEmpty ? pictureUrls.first : '';

  String get categoryLabel =>
      categorySpecific.isNotEmpty && categoryGroup.isNotEmpty
          ? '$categoryGroup · $categorySpecific'
          : categorySpecific.isNotEmpty
              ? categorySpecific
              : categoryGroup.isNotEmpty
                  ? categoryGroup
                  : category;

  static Map<String, String> _parseCategoryMap(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, categoryValue) => MapEntry(
          key.toString(),
          categoryValue.toString(),
        ),
      );
    }

    return const {};
  }

  static List<String> _parseCategoryList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    final parsedCategories = _parseCategoryMap(json['categories']);
    final categoryList = _parseCategoryList(json['categories']);
    String categoryGroup = '';
    String categorySpecific = '';

    if (categoryList.isNotEmpty) {
      categorySpecific = categoryList.first;
      categoryGroup = EventCategories.generalCategoryForSpecific(categorySpecific) ?? '';
    } else if (parsedCategories.isNotEmpty) {
      final firstEntry = parsedCategories.entries.first;
      categoryGroup = firstEntry.key;
      categorySpecific = firstEntry.value;
    }

    final category = json['category'] ??
        json['category_label'] ??
        json['categoryLabel'] ??
        (categorySpecific.isNotEmpty ? categorySpecific : categoryGroup);

    if (categorySpecific.isEmpty && category is String && category.isNotEmpty) {
      categorySpecific = category;
    }

    if (categoryGroup.isEmpty && categorySpecific.isNotEmpty) {
      categoryGroup = EventCategories.generalCategoryForSpecific(categorySpecific) ?? '';
    }

    if (json['category_group'] is String) {
      categoryGroup = json['category_group'] as String;
    } else if (json['categoryGroup'] is String) {
      categoryGroup = json['categoryGroup'] as String;
    }

    if (json['category_specific'] is String) {
      categorySpecific = json['category_specific'] as String;
    } else if (json['categorySpecific'] is String) {
      categorySpecific = json['categorySpecific'] as String;
    }

    if (categoryGroup.isEmpty && categorySpecific.isNotEmpty) {
      categoryGroup = EventCategories.generalCategoryForSpecific(categorySpecific) ??
          (parsedCategories.isNotEmpty ? parsedCategories.keys.first : '');
    }

    if (categorySpecific.isEmpty && categoryGroup.isNotEmpty && parsedCategories.isNotEmpty) {
      categorySpecific = parsedCategories[categoryGroup] ?? parsedCategories.values.first;
    }

    final picture = json['picture'] ?? json['pictures'] ?? json['imageUrl'];
    final organizer = json['organizer'];
    String organizerName = '';
    String organizerId = '';

    if (organizer is Map<String, dynamic>) {
      organizerName = organizer['name']?.toString() ?? '';
      organizerId = organizer['id']?.toString() ??
          organizer['_id']?.toString() ??
          organizer['user_id']?.toString() ??
          '';
    } else if (organizer is String) {
      organizerId = organizer;
      organizerName = organizer;
    }

    if (json['organizer_name'] is String && (json['organizer_name'] as String).isNotEmpty) {
      organizerName = json['organizer_name'] as String;
    }
    if (json['organizer_id'] is String && (json['organizer_id'] as String).isNotEmpty) {
      organizerId = json['organizer_id'] as String;
    }
    final pictureUrls = picture is List
        ? picture.map((item) => item.toString()).toList()
        : picture is String && picture.isNotEmpty
            ? [picture]
            : <String>[];

    return Event(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? json['name'] ?? '',
      category: category is String ? category : (categorySpecific.isNotEmpty ? categorySpecific : categoryGroup),
      categoryGroup: categoryGroup,
      categorySpecific: categorySpecific,
      date: json['date'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      pictureUrls: pictureUrls,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      organizerName: organizerName,
      organizerId: organizerId,
    );
  }

  Map<String, dynamic> toJson() {
    final categories = <Map<String, String>>[];
    if (categoryGroup.isNotEmpty && categorySpecific.isNotEmpty) {
      categories.add({categoryGroup: categorySpecific});
    }

    return {
      'id': id,
      'title': title,
      'category': category,
      'category_group': categoryGroup,
      'category_specific': categorySpecific,
      'categories': categories.isNotEmpty
          ? categories
          : (category.isNotEmpty ? [category] : const []),
      'date': date,
      'location': location,
      'description': description,
      'picture': pictureUrls,
      'price': price,
      'organizer_name': organizerName,
      'organizer_id': organizerId,
    };
  }
}
