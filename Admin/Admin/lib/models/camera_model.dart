import 'package:cloud_firestore/cloud_firestore.dart';

class Point {
  final double x;
  final double y;

  Point({required this.x, required this.y});

  Map<String, dynamic> toMap() => {'x': x, 'y': y};

  factory Point.fromMap(Map<String, dynamic> map) {
    return Point(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
    );
  }
}

class RegionOfInterest {
  String id; // Local use only
  final String label;
  final String type; // 'road', 'garbage', 'streetlight'
  final List<Point> points;
  final bool enabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RegionOfInterest({
    required this.id,
    required this.label,
    required this.type,
    required this.points,
    this.enabled = true,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Excluded from storage
      'label': label,
      'type': type,
      'points': points.map((p) => p.toMap()).toList(),
      'enabled': enabled,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory RegionOfInterest.fromMap(Map<String, dynamic> map) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return RegionOfInterest(
      id: '', // ID set externally from doc.id
      label: map['label'] ?? '',
      type: map['type'] ?? 'road',
      points: (map['points'] as List<dynamic>?)
              ?.map((e) => Point.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      enabled: map['enabled'] ?? true,
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
    );
  }
}

class Camera {
  String id;
  final String name;
  final String locationName;
  final double latitude;
  final double longitude;
  final String snapshotUrl;
  List<RegionOfInterest> regions;

  Camera({
    required this.id,
    required this.name,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.snapshotUrl,
    List<RegionOfInterest>? regions,
  }) : regions = regions ?? [];

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Excluded from storage
      'name': name,
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'snapshotUrl': snapshotUrl,
      // 'regions': regions... // Excluded (subcollection)
    };
  }

  factory Camera.fromMap(Map<String, dynamic> map, String id) {
    return Camera(
      id: id,
      name: map['name'] ?? '',
      locationName: map['locationName'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      snapshotUrl: map['snapshotUrl'] ?? '',
      // Regions fetched separately
      regions: [], 
    );
  }
}
