enum LocationType { tourist, restaurant, teaSpot }

class LocationModel {
  final String id;
  final String name;
  final String description;
  final String district;
  final double latitude;
  final double longitude;
  final LocationType type;
  final String addedBy;
  final DateTime createdAt;
  final bool isApproved;
  final List<String> images;
  final String? contactInfo;
  final Map<String, dynamic>? additionalInfo;

  LocationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.addedBy,
    required this.createdAt,
    this.isApproved = false,
    this.images = const [],
    this.contactInfo,
    this.additionalInfo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'district': district,
      'latitude': latitude,
      'longitude': longitude,
      'type': type.toString(),
      'addedBy': addedBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isApproved': isApproved,
      'images': images,
      'contactInfo': contactInfo,
      'additionalInfo': additionalInfo,
    };
  }

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      district: map['district'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      type: LocationType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => LocationType.tourist,
      ),
      addedBy: map['addedBy'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isApproved: map['isApproved'] ?? false,
      images: List<String>.from(map['images'] ?? []),
      contactInfo: map['contactInfo'],
      additionalInfo: map['additionalInfo'],
    );
  }
}
