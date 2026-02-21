import 'dart:convert';
import 'dart:async';
import 'dart:typed_data'; // For web image bytes
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'utils/clustering_helper.dart';
import 'models/camera_model.dart';

class DataService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _rawData = [];   // all individual issues
  List<Map<String, dynamic>> _filteredData = []; // data after applying filters
  List<Cluster> _clusteredData = []; // clustered issues
  List<Camera> _cameras = []; // ✅ List of cameras

  bool _isLoading = false;
  String? _error;
  bool _clusteringEnabled = true; // Enable clustering by default

  // Filters
  List<String> selectedTypes = [];
  List<String> selectedDepartments = [];
  List<String> selectedUserIds = [];
  List<String> selectedLocations = [];
  List<String> selectedUrgencies = [];
  DateTime? startDate;
  DateTime? endDate;

  // Convenience getters
  List<Map<String, dynamic>> get data => _filteredData;
  List<Cluster> get clusteredData => _clusteredData;
  List<Camera> get cameras => _cameras; // ✅ Getter for cameras
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get clusteringEnabled => _clusteringEnabled;
  
  // Toggle clustering
  void toggleClustering() {
    _clusteringEnabled = !_clusteringEnabled;
    _applyFilters();
    notifyListeners();
  }

  // Unique values for dropdowns (from raw data)
  List<String> get allTypes => _unique('issue_type');
  List<String> get allDepartments => _unique('department');
  List<String> get allUsers => _unique('user_id');
  List<String> get allLocations => _unique('address');

  // ------------------- Fetch All Issues -------------------
  Future<void> fetchData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📥 Admin: Fetching all issues from Firestore...');
      
      // Use collection('issues') instead of collectionGroup('issues')
      final snap = await _firestore
          .collection('issues')
          .orderBy('reported_date', descending: true)
          .get();

      print('✅ Admin: Fetched ${snap.docs.length} issues from Firestore');

      final List<Map<String, dynamic>> allIssues = snap.docs.map((doc) {
        final d = doc.data();
        final imageUrl = d['image_url']?.toString() ?? '';
        
        // Debug: Print image URL for first few issues
        if (snap.docs.indexOf(doc) < 3) {
          print('📸 Issue ${doc.id} - image_url: ${imageUrl.isNotEmpty ? imageUrl.substring(0, imageUrl.length > 50 ? 50 : imageUrl.length) + "..." : "EMPTY"}');
        }
        
        return {
          'id': doc.id, // Use document ID, not full path
          'complain_id': d['complain_id'] ?? doc.id,
          'issue_type': d['issue_type'] ?? 'Unknown',
          'latitude': (d['latitude'] is double) 
              ? d['latitude'] 
              : double.tryParse(d['latitude']?.toString() ?? '') ?? 0.0,
          'longitude': (d['longitude'] is double)
              ? d['longitude']
              : double.tryParse(d['longitude']?.toString() ?? '') ?? 0.0,
          'address': d['address'] ?? '',
          'description': d['description'] ?? '',
          'status': d['status'] ?? 'Reported',
          'urgency': d['urgency'] ?? 'Medium',
          'reported_date': d['reported_date'] ?? '',
          'user_id': d['user_id'] ?? '',
          'department': d['department'] ?? '',
          'image_url': imageUrl, // Ensure it's a string
          'reporter_name': d['reporter_name'] ?? '',
          'reporter_phone': d['reporter_phone'] ?? '',
          'camera_id': d['camera_id'] ?? '',
        };
      }).toList();

      // 1) Enrich with reporter name & phone from users collection when missing on issue
      final userIdsToFetch = <String>{};
      for (final issue in allIssues) {
        final uid = (issue['user_id'] ?? '').toString().trim();
        final hasName = ((issue['reporter_name'] ?? '').toString().trim().isNotEmpty);
        if (uid.isNotEmpty && !hasName) userIdsToFetch.add(uid);
      }
      if (userIdsToFetch.isNotEmpty) {
        final userSnaps = await Future.wait(
          userIdsToFetch.map((uid) => _firestore.collection('users').doc(uid).get()),
        );
        final userMap = <String, Map<String, dynamic>>{};
        for (var i = 0; i < userIdsToFetch.length; i++) {
          final uid = userIdsToFetch.elementAt(i);
          final snap = userSnaps[i];
          if (snap.exists && snap.data() != null) {
            userMap[uid] = snap.data()!;
          }
        }
        for (final issue in allIssues) {
          final uid = (issue['user_id'] ?? '').toString().trim();
          final hasName = ((issue['reporter_name'] ?? '').toString().trim().isNotEmpty);
          if (uid.isEmpty || hasName) continue;
          final userData = userMap[uid];
          if (userData != null) {
            issue['reporter_name'] = userData['fullName']?.toString().trim() ?? '';
            issue['reporter_phone'] = userData['phonenumber']?.toString().trim() ?? '';
          }
        }
        print('✅ Admin: Enriched ${userIdsToFetch.length} issues with reporter info from users collection');
      }

      // 2) If still no reporter name, try camera_id → fetch camera name (issue from camera)
      final cameraIdsToFetch = <String>{};
      for (final issue in allIssues) {
        final hasName = ((issue['reporter_name'] ?? '').toString().trim().isNotEmpty);
        final cameraId = (issue['camera_id'] ?? '').toString().trim();
        if (!hasName && cameraId.isNotEmpty) cameraIdsToFetch.add(cameraId);
      }
      if (cameraIdsToFetch.isNotEmpty) {
        final cameraSnaps = await Future.wait(
          cameraIdsToFetch.map((id) => _firestore.collection('cameras').doc(id).get()),
        );
        final cameraNameMap = <String, String>{};
        for (var i = 0; i < cameraIdsToFetch.length; i++) {
          final cid = cameraIdsToFetch.elementAt(i);
          final snap = cameraSnaps[i];
          if (snap.exists && snap.data() != null) {
            final name = snap.data()!['name']?.toString().trim() ?? '';
            if (name.isNotEmpty) cameraNameMap[cid] = name;
          }
        }
        for (final issue in allIssues) {
          final hasName = ((issue['reporter_name'] ?? '').toString().trim().isNotEmpty);
          if (hasName) continue;
          final cameraId = (issue['camera_id'] ?? '').toString().trim();
          final cameraName = cameraNameMap[cameraId];
          if (cameraName != null && cameraName.isNotEmpty) {
            issue['reporter_name'] = cameraName;
            issue['reporter_phone'] = ''; // Camera has no phone
          }
        }
        print('✅ Admin: Enriched ${cameraIdsToFetch.length} issues with camera name');
      }

      // 3) If still no reporter name (not a user, not a camera), show as Unknown
      for (final issue in allIssues) {
        final hasName = ((issue['reporter_name'] ?? '').toString().trim().isNotEmpty);
        if (!hasName) {
          issue['reporter_name'] = 'Unknown';
          issue['reporter_phone'] = '';
        }
      }

      print('✅ Admin: Processed ${allIssues.length} issues');

      _rawData = allIssues;
      _applyFilters();   // <-- immediately apply current filters
      
      // Apply clustering if enabled
      if (_clusteringEnabled) {
        _clusteredData = ClusteringHelper.clusterIssues(_filteredData);
        print('📊 Admin: Created ${_clusteredData.length} clusters from ${_filteredData.length} issues');
      } else {
        _clusteredData = [];
      }
    } catch (e, stackTrace) {
      _error = e.toString();
      print('❌ Admin: Error fetching data: $e');
      print('📚 Stack trace: $stackTrace');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ------------------- Update issue status -------------------
  Future<void> updateIssueStatus(String docId, String newStatus) async {
    try {
      print('🔄 Admin: Updating issue $docId status to $newStatus');
      
      // Find the issue to get user_id, department, and issue_type
      final issue = _rawData.firstWhere(
        (issue) => issue['id'] == docId,
        orElse: () => {},
      );
      
      final userId = issue['user_id'] ?? '';
      final department = issue['department'] ?? '';
      final issueType = issue['issue_type'] ?? '';
      
      // Update Firestore
      await _firestore.collection('issues').doc(docId).update({
        'status': newStatus,
      });
      print('✅ Admin: Status updated successfully');
      
      // Send notification (don't wait for it, fire and forget)
      _sendNotification(
        complaintId: docId,
        userId: userId,
        newStatus: newStatus,
        department: department,
        issueType: issueType,
      );
      
      // Update local data immediately
      final index = _rawData.indexWhere((issue) => issue['id'] == docId);
      if (index != -1) {
        _rawData[index]['status'] = newStatus;
        _applyFilters();
        notifyListeners();
      }
      // Refresh from server to ensure consistency
      await fetchData();
    } catch (e) {
      debugPrint('❌ Admin: Status update failed: $e');
      _error = 'Failed to update status: $e';
      notifyListeners();
    }
  }

  // ------------------- Send Notification -------------------
  Future<void> _sendNotification({
    required String complaintId,
    required String userId,
    required String newStatus,
    required String department,
    required String issueType,
  }) async {
    try {
      // Only send for specific statuses
      final notifyStatuses = ['assigned', 'in progress', 'resolved', 'completed'];
      if (!notifyStatuses.contains(newStatus.toLowerCase())) {
        print('⏭️  Status "$newStatus" not in notification list, skipping...');
        return;
      }

      if (userId.isEmpty) {
        print('⚠️  No userId found, skipping notification...');
        return;
      }

      // Notification server URL (use 127.0.0.1 for Flutter web compatibility)
      const notificationUrl = 'http://127.0.0.1:3000/notify-status-change';
      
      print('📬 Sending notification to user $userId...');
      print('   URL: $notificationUrl');
      print('   Complaint ID: $complaintId');
      print('   Status: $newStatus');
      print('   Department: $department');
      
      final response = await http.post(
        Uri.parse(notificationUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'complaintId': complaintId,
          'userId': userId,
          'newStatus': newStatus,
          'department': department,
          'issueType': issueType,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️  Notification request timeout');
          throw TimeoutException('Notification request timeout');
        },
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success'] == true) {
          print('✅ Notification sent successfully');
          if (result['results'] != null) {
            print('   SMS: ${result['results']['sms']}');
            print('   Email: ${result['results']['email']}');
          }
        } else {
          print('⚠️  Notification sent but with warnings: ${result['error'] ?? 'Unknown'}');
        }
      } else {
        print('⚠️  Notification failed with status ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e, stackTrace) {
      // Don't fail the status update if notification fails
      print('⚠️  Notification error (non-critical): $e');
      print('   Stack trace: $stackTrace');
    }
  }

  // ------------------- Filters -------------------
  void updateFilters(
    List<String> types,
    List<String> depts,
    List<String> users,
    List<String> locs,
    DateTime? start,
    DateTime? end,
    List<String> urgencies,
  ) {
    selectedTypes = types;
    selectedDepartments = depts;
    selectedUserIds = users;
    selectedLocations = locs;
    selectedUrgencies = urgencies;
    startDate = start;
    endDate = end;
    _applyFilters();
    notifyListeners();
  }

  void resetFilters() {
    selectedTypes.clear();
    selectedDepartments.clear();
    selectedUserIds.clear();
    selectedLocations.clear();
    selectedUrgencies.clear();
    startDate = null;
    endDate = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredData = _rawData.where((issue) {
      final t = selectedTypes.isEmpty || selectedTypes.contains(issue['issue_type']);
      final d = selectedDepartments.isEmpty || selectedDepartments.contains(issue['department']);
      final u = selectedUserIds.isEmpty || selectedUserIds.contains(issue['user_id']);
      final l = selectedLocations.isEmpty ||
          selectedLocations.any((loc) =>
              (issue['address'] as String).toLowerCase().contains(loc.toLowerCase()));
      final urg = selectedUrgencies.isEmpty || selectedUrgencies.contains(issue['urgency']);

      bool dateOK = true;
      if (startDate != null || endDate != null) {
        final issueDate = DateTime.tryParse(issue['reported_date'] ?? '');
        if (issueDate == null) return false;
        if (startDate != null && issueDate.isBefore(startDate!)) dateOK = false;
        if (endDate != null && issueDate.isAfter(endDate!)) dateOK = false;
      }
      return t && d && u && l && urg && dateOK;
    }).toList();
    
    // Re-apply clustering after filtering
    if (_clusteringEnabled) {
      _clusteredData = ClusteringHelper.clusterIssues(_filteredData);
      print('📊 Admin: Re-clustered into ${_clusteredData.length} clusters');
    } else {
      _clusteredData = [];
    }
  }

  // ------------------- Sorting -------------------
  void sortData(String type) {
    int compareDate(a, b) {
      final dateA = DateTime.tryParse(a['reported_date'] ?? '') ?? DateTime(1970);
      final dateB = DateTime.tryParse(b['reported_date'] ?? '') ?? DateTime(1970);
      return dateB.compareTo(dateA); // Latest first
    }

    if (type == 'Latest') {
      _filteredData.sort(compareDate);
    } else if (type == 'Oldest') {
      _filteredData.sort((a, b) => compareDate(b, a));
    } else if (type == 'Priority' || type == 'Priority Descending') {
      const priorityOrder = {'Low': 1, 'Medium': 2, 'High': 3, 'Critical': 4};
      _filteredData.sort((a, b) {
        final pa = priorityOrder[(a['urgency'] ?? 'Medium').toString()] ?? 2;
        final pb = priorityOrder[(b['urgency'] ?? 'Medium').toString()] ?? 2;
        return pb.compareTo(pa); // Higher priority first
      });
    } else if (type == 'Priority Ascending') {
      const priorityOrder = {'Low': 1, 'Medium': 2, 'High': 3, 'Critical': 4};
      _filteredData.sort((a, b) {
        final pa = priorityOrder[(a['urgency'] ?? 'Medium').toString()] ?? 2;
        final pb = priorityOrder[(b['urgency'] ?? 'Medium').toString()] ?? 2;
        return pa.compareTo(pb); // Lower priority first
      });
    }
    notifyListeners();
  }

  // ------------------- Helpers -------------------
  List<String> _unique(String field) =>
      _rawData.map((e) => e[field]?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList()
          ..sort();

  // ------------------- Camera Operations -------------------

  Future<void> fetchCameras() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      print('📷 Admin: Fetching cameras... User: ${user?.uid ?? "Not Logged In"}');
      
      final snap = await _firestore.collection('cameras').get();
      _cameras = snap.docs.map((doc) => Camera.fromMap(doc.data(), doc.id)).toList();
      
      // Fetch regions subcollections
      for (var camera in _cameras) {
         final regionSnap = await _firestore.collection('cameras').doc(camera.id).collection('regions').get();
         camera.regions = regionSnap.docs.map((d) => RegionOfInterest.fromMap(d.data())..id = d.id).toList();
      }

      print('✅ Admin: Fetched ${_cameras.length} cameras');
      notifyListeners();
    } catch (e) {
      print('❌ Admin: Error fetching cameras: $e');
    }
  }

  Future<void> addCamera(Camera camera) async {
    try {
      final docRef = await _firestore.collection('cameras').add(camera.toMap());
      camera.id = docRef.id;
      _cameras.add(camera);
      notifyListeners();
    } catch (e) {
      print('❌ Admin: Error adding camera: $e');
      throw e;
    }
  }

  Future<void> updateCamera(Camera camera) async {
    try {
      // Update main camera doc (excluding regions array)
      await _firestore.collection('cameras').doc(camera.id).update(camera.toMap());
      
      final index = _cameras.indexWhere((c) => c.id == camera.id);
      if (index != -1) {
        // Keep the local regions but update other fields
        final oldRegions = _cameras[index].regions;
        _cameras[index] = camera;
        _cameras[index].regions = oldRegions; // Restore regions as they are not in toMap() anymore
        notifyListeners();
      }
    } catch (e) {
      print('❌ Admin: Error updating camera: $e');
      throw e;
    }
  }

  Future<void> deleteCamera(String cameraId) async {
    try {
      // Delete subcollections? Firestore doesn't delete subcollections automatically.
      // We should ideally delete ROIs first, but for now we delete the camera doc. 
      await _firestore.collection('cameras').doc(cameraId).delete();
      _cameras.removeWhere((c) => c.id == cameraId);
      notifyListeners();
    } catch (e) {
      print('❌ Admin: Error deleting camera: $e');
      throw e;
    }
  }

  // ------------------- ROI Subcollection Operations -------------------

  Future<void> addRegion(String cameraId, RegionOfInterest roi) async {
    try {
      final docRef = await _firestore
          .collection('cameras')
          .doc(cameraId)
          .collection('regions')
          .add({
            ...roi.toMap(),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      
      roi.id = docRef.id; // Correctly assign the generated ID to the local object
      
      // Update local state
      final camera = _cameras.firstWhere((c) => c.id == cameraId);
      camera.regions.add(roi);
      notifyListeners();
    } catch (e) {
      print('❌ Admin: Error adding region: $e');
      throw e;
    }
  }

  Future<void> deleteRegion(String cameraId, String regionId) async {
    try {
      await _firestore
          .collection('cameras')
          .doc(cameraId)
          .collection('regions')
          .doc(regionId)
          .delete();

       // Update local state
      final camera = _cameras.firstWhere((c) => c.id == cameraId);
      camera.regions.removeWhere((r) => r.id == regionId);
      notifyListeners();
    } catch (e) {
      print('❌ Admin: Error deleting region: $e');
      throw e;
    }
  }
  
  // ------------------- Image Upload -------------------

  Future<String> uploadCameraSnapshot(Uint8List fileBytes, String fileName) async {
    try {
      print('📤 Admin: Uploading snapshot $fileName...');
      final ref = FirebaseStorage.instance.ref().child('camera_snapshots/$fileName');
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg', 
      );

      final task = await ref.putData(fileBytes, metadata);
      final downloadUrl = await task.ref.getDownloadURL();
      
      print('✅ Admin: Upload successful: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Admin: Upload failed: $e');
      throw e;
    }
  }
}
