enum EventCategory {
  concert,
  theatre,
  festival,
  expo,
  cinema,
  danse,
  other,
}

class Event {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String localImage;
  final DateTime date;
  final String time;
  final String location;
  final String venue;
  final String venueId;
  final double latitude;
  final double longitude;
  final EventCategory category;
  final double price;
  final bool isFree;
  final bool isFeatured;
  final int capacity;
  final int bookedCount;
  final String organizer;
  final String contactEmail;
  final String contactPhone;
  final List<String> tags;
  bool isFavorite;

  Event({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl = '',
    this.localImage = '',
    required this.date,
    this.time = '',
    required this.location,
    this.venue = '',
    this.venueId = '',
    this.latitude = 36.7538,
    this.longitude = 3.0588,
    this.category = EventCategory.other,
    this.price = 0,
    this.isFree = true,
    this.isFeatured = false,
    this.capacity = 100,
    this.bookedCount = 0,
    this.organizer = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.tags = const [],
    this.isFavorite = false,
  });

  String get categoryName {
    switch (category) {
      case EventCategory.concert:
        return 'Concert';
      case EventCategory.theatre:
        return 'Théâtre';
      case EventCategory.festival:
        return 'Festival';
      case EventCategory.expo:
        return 'Exposition';
      case EventCategory.cinema:
        return 'Cinéma';
      case EventCategory.danse:
        return 'Danse';
      default:
        return 'Autre';
    }
  }

  String get categoryAsset {
    switch (category) {
      case EventCategory.concert:
        return 'assets/images/concert.png';
      case EventCategory.theatre:
        return 'assets/images/theatre.png';
      case EventCategory.festival:
        return 'assets/images/festival.png';
      case EventCategory.expo:
        return 'assets/images/expo.png';
      case EventCategory.cinema:
        return 'assets/images/cinema.png';
      case EventCategory.danse:
        return 'assets/images/danse.png';
      default:
        return 'assets/images/placeholder.png';
    }
  }

  int get availableSeats => capacity - bookedCount;
  bool get isAvailable => availableSeats > 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'localImage': localImage,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'venue': venue,
      'venueId': venueId,
      'latitude': latitude,
      'longitude': longitude,
      'category': category.index,
      'price': price,
      'isFree': isFree,
      'isFeatured': isFeatured,
      'capacity': capacity,
      'bookedCount': bookedCount,
      'organizer': organizer,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'tags': tags,
      'isFavorite': isFavorite,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      localImage: json['localImage'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      time: json['time'] ?? '',
      location: json['location'] ?? '',
      venue: json['venue'] ?? '',
      venueId: json['venueId'] ?? '',
      latitude: (json['latitude'] ?? 36.7538).toDouble(),
      longitude: (json['longitude'] ?? 3.0588).toDouble(),
      category: EventCategory.values[json['category'] ?? 0],
      price: (json['price'] ?? 0).toDouble(),
      isFree: json['isFree'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      capacity: json['capacity'] ?? 100,
      bookedCount: json['bookedCount'] ?? 0,
      organizer: json['organizer'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  Event copyWith({
    String? title,
    String? description,
    String? imageUrl,
    String? localImage,
    DateTime? date,
    String? time,
    String? location,
    String? venue,
    String? venueId,
    double? latitude,
    double? longitude,
    EventCategory? category,
    double? price,
    bool? isFree,
    bool? isFeatured,
    int? capacity,
    int? bookedCount,
    bool? isFavorite,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      localImage: localImage ?? this.localImage,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      venue: venue ?? this.venue,
      venueId: venueId ?? this.venueId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      category: category ?? this.category,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      isFeatured: isFeatured ?? this.isFeatured,
      capacity: capacity ?? this.capacity,
      bookedCount: bookedCount ?? this.bookedCount,
      organizer: organizer,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      tags: tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
