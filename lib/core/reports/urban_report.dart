class UrbanReport {
  UrbanReport({
    this.id,
    required this.category,
    required this.description,
    required this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
  });

  final int? id;
  final String category;
  final String description;
  final String imagePath;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'image_path': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UrbanReport.fromMap(Map<String, Object?> map) {
    return UrbanReport(
      id: map['id'] as int?,
      category: map['category'] as String,
      description: map['description'] as String,
      imagePath: map['image_path'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
