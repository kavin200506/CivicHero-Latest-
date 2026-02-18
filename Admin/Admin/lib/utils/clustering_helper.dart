import 'dart:math';

/// Helper class for clustering issues by location and type
class ClusteringHelper {
  // Tolerance in degrees (approximately 100 meters)
  // 1 degree latitude ≈ 111 km, so 0.0009 ≈ 100 meters
  static const double locationTolerance = 0.0009; // ~100 meters
  
  /// Cluster issues by location and issue type
  /// Returns a list of clusters, where each cluster contains multiple issues
  static List<Cluster> clusterIssues(List<Map<String, dynamic>> issues) {
    if (issues.isEmpty) return [];
    
    final List<Cluster> clusters = [];
    final List<bool> processed = List.filled(issues.length, false);
    
    for (int i = 0; i < issues.length; i++) {
      if (processed[i]) continue;
      
      final issue = issues[i];
      final lat = (issue['latitude'] as num?)?.toDouble() ?? 0.0;
      final lng = (issue['longitude'] as num?)?.toDouble() ?? 0.0;
      final issueType = issue['issue_type']?.toString() ?? 'Unknown';
      
      // Skip issues with invalid coordinates
      if (lat == 0.0 && lng == 0.0) continue;
      
      // Create new cluster starting with this issue
      final cluster = Cluster(
        centerLat: lat,
        centerLng: lng,
        issueType: issueType,
        issues: [issue],
      );
      
      processed[i] = true;
      
      // Find all nearby issues of the same type
      for (int j = i + 1; j < issues.length; j++) {
        if (processed[j]) continue;
        
        final otherIssue = issues[j];
        final otherLat = (otherIssue['latitude'] as num?)?.toDouble() ?? 0.0;
        final otherLng = (otherIssue['longitude'] as num?)?.toDouble() ?? 0.0;
        final otherType = otherIssue['issue_type']?.toString() ?? 'Unknown';
        
        // Skip if coordinates are invalid
        if (otherLat == 0.0 && otherLng == 0.0) continue;
        
        // Check if same issue type and within tolerance
        if (otherType == issueType && 
            _isWithinTolerance(lat, lng, otherLat, otherLng)) {
          cluster.issues.add(otherIssue);
          processed[j] = true;
        }
      }
      
      // Update cluster center to average of all issues
      cluster.updateCenter();
      
      clusters.add(cluster);
    }
    
    // Sort clusters by priority (more reports = higher priority)
    clusters.sort((a, b) => b.issueCount.compareTo(a.issueCount));
    
    return clusters;
  }
  
  /// Check if two coordinates are within tolerance distance
  static bool _isWithinTolerance(
    double lat1, double lng1, 
    double lat2, double lng2
  ) {
    // Calculate distance using Haversine formula (simplified for small distances)
    final latDiff = (lat1 - lat2).abs();
    final lngDiff = (lng1 - lng2).abs();
    
    // For small distances, we can use simple Euclidean distance
    // 1 degree ≈ 111 km, so tolerance of 0.0009 ≈ 100 meters
    return latDiff <= locationTolerance && lngDiff <= locationTolerance;
  }
  
  /// Calculate distance between two points in meters (Haversine formula)
  static double calculateDistance(
    double lat1, double lng1,
    double lat2, double lng2
  ) {
    const double earthRadius = 6371000; // meters
    
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}

/// Represents a cluster of issues
class Cluster {
  double centerLat;
  double centerLng;
  String issueType;
  List<Map<String, dynamic>> issues;
  
  Cluster({
    required this.centerLat,
    required this.centerLng,
    required this.issueType,
    required this.issues,
  });
  
  /// Update center to average of all issues
  void updateCenter() {
    if (issues.isEmpty) return;
    
    double totalLat = 0;
    double totalLng = 0;
    
    for (final issue in issues) {
      totalLat += (issue['latitude'] as num?)?.toDouble() ?? 0.0;
      totalLng += (issue['longitude'] as num?)?.toDouble() ?? 0.0;
    }
    
    centerLat = totalLat / issues.length;
    centerLng = totalLng / issues.length;
  }
  
  /// Get the number of issues in this cluster
  int get issueCount => issues.length;
  
  /// Get the most common urgency (or highest if tied)
  String get priorityUrgency {
    if (issues.isEmpty) return 'Medium';
    
    final urgencyCounts = <String, int>{};
    for (final issue in issues) {
      final urgency = (issue['urgency'] ?? 'Medium').toString();
      urgencyCounts[urgency] = (urgencyCounts[urgency] ?? 0) + 1;
    }
    
    // Priority order: Critical > High > Medium > Low
    const priorityOrder = {'Critical': 4, 'High': 3, 'Medium': 2, 'Low': 1};
    
    String maxUrgency = 'Medium';
    int maxCount = 0;
    int maxPriority = 0;
    
    urgencyCounts.forEach((urgency, count) {
      final priority = priorityOrder[urgency] ?? 2;
      if (count > maxCount || (count == maxCount && priority > maxPriority)) {
        maxCount = count;
        maxPriority = priority;
        maxUrgency = urgency;
      }
    });
    
    return maxUrgency;
  }
  
  /// Get the most common status
  String get mostCommonStatus {
    if (issues.isEmpty) return 'Reported';
    
    final statusCounts = <String, int>{};
    for (final issue in issues) {
      final status = (issue['status'] ?? 'Reported').toString();
      statusCounts[status] = (statusCounts[status] ?? 0) + 1;
    }
    
    String maxStatus = 'Reported';
    int maxCount = 0;
    
    statusCounts.forEach((status, count) {
      if (count > maxCount) {
        maxCount = count;
        maxStatus = status;
      }
    });
    
    return maxStatus;
  }
  
  /// Get the most common department
  String get mostCommonDepartment {
    if (issues.isEmpty) return '';
    
    final deptCounts = <String, int>{};
    for (final issue in issues) {
      final dept = (issue['department'] ?? '').toString();
      if (dept.isNotEmpty) {
        deptCounts[dept] = (deptCounts[dept] ?? 0) + 1;
      }
    }
    
    if (deptCounts.isEmpty) return '';
    
    String maxDept = '';
    int maxCount = 0;
    
    deptCounts.forEach((dept, count) {
      if (count > maxCount) {
        maxCount = count;
        maxDept = dept;
      }
    });
    
    return maxDept;
  }
  
  /// Get the earliest reported date
  String get earliestReportDate {
    if (issues.isEmpty) return '';
    
    DateTime? earliest;
    for (final issue in issues) {
      final dateStr = issue['reported_date']?.toString() ?? '';
      final date = DateTime.tryParse(dateStr);
      if (date != null && (earliest == null || date.isBefore(earliest))) {
        earliest = date;
      }
    }
    
    return earliest?.toIso8601String() ?? '';
  }
  
  /// Get the most recent reported date
  String get latestReportDate {
    if (issues.isEmpty) return '';
    
    DateTime? latest;
    for (final issue in issues) {
      final dateStr = issue['reported_date']?.toString() ?? '';
      final date = DateTime.tryParse(dateStr);
      if (date != null && (latest == null || date.isAfter(latest))) {
        latest = date;
      }
    }
    
    return latest?.toIso8601String() ?? '';
  }
  
  /// Get representative address (most common or first)
  String get representativeAddress {
    if (issues.isEmpty) return 'Unknown location';
    
    final addrCounts = <String, int>{};
    for (final issue in issues) {
      final addr = (issue['address'] ?? '').toString();
      if (addr.isNotEmpty) {
        addrCounts[addr] = (addrCounts[addr] ?? 0) + 1;
      }
    }
    
    if (addrCounts.isEmpty) {
      return issues.first['address']?.toString() ?? 'Unknown location';
    }
    
    String maxAddr = '';
    int maxCount = 0;
    
    addrCounts.forEach((addr, count) {
      if (count > maxCount) {
        maxCount = count;
        maxAddr = addr;
      }
    });
    
    return maxAddr.isNotEmpty ? maxAddr : 'Unknown location';
  }
  
  /// Get a representative image URL (first available)
  String get representativeImageUrl {
    for (final issue in issues) {
      final imageUrl = issue['image_url']?.toString() ?? '';
      if (imageUrl.isNotEmpty) {
        return imageUrl;
      }
    }
    return '';
  }
}




