class Complaint {
  final String complainId;      // Unique complaint/report ID
  final String issueType;       // Category (Pothole, Garbage, etc.)
  final String department;
  final String urgency;
  final double latitude;
  final double longitude;
  final String address;         // Human-readable location (e.g., "Sri Krishna College MCA Block")
  final String description;     // User-provided issue details
  final String status;          // e.g., "Reported", "In Progress"
  final DateTime reportedDate;  // When issue was filed
  final String imageUrl;        // Firebase Storage download URL
  final String userId;          // ID of user who filed it

  Complaint({
    required this.complainId,
    required this.issueType,
    required this.department,
    required this.urgency,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.description,
    required this.status,
    required this.reportedDate,
    required this.imageUrl,
    required this.userId,
  });

  // Convert model to a Firestore map
  Map<String, dynamic> toMap() {
    return {
      'complain_id': complainId,
      'issue_type': issueType,
      'department': department,
      'urgency': urgency,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'description': description,
      'status': status,
      'reported_date': reportedDate.toIso8601String(),
      'image_url': imageUrl,
      'user_id': userId,
    };
  }

  // Create model from a Firestore map
  factory Complaint.fromMap(Map<String, dynamic> map) {
    return Complaint(
      complainId: map['complain_id'] ?? '',
      issueType: map['issue_type'] ?? '',
      department: map['department'] ?? '',
      urgency: map['urgency'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      address: map['address'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? '',
      reportedDate: DateTime.tryParse(map['reported_date'] ?? '') ?? DateTime.now(),
      imageUrl: map['image_url'] ?? '',
      userId: map['user_id'] ?? '',
    );
  }
}
