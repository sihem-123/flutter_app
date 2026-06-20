class Venue {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String localImage;
  final int capacity;
  final String phone;
  final String email;
  final String website;
  final List<String> facilities;
  final bool isActive;

  Venue({
    required this.id,
    required this.name,
    this.description = '',
    required this.address,
    this.city = 'Alger',
    this.latitude = 36.7538,
    this.longitude = 3.0588,
    this.imageUrl = '',
    this.localImage = '',
    this.capacity = 0,
    this.phone = '',
    this.email = '',
    this.website = '',
    this.facilities = const [],
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'localImage': localImage,
      'capacity': capacity,
      'phone': phone,
      'email': email,
      'website': website,
      'facilities': facilities,
      'isActive': isActive,
    };
  }

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? 'Alger',
      latitude: (json['latitude'] ?? 36.7538).toDouble(),
      longitude: (json['longitude'] ?? 3.0588).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      localImage: json['localImage'] ?? '',
      capacity: json['capacity'] ?? 0,
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      facilities: List<String>.from(json['facilities'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }
}
