import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class UltralyticsAIService {
  // ✅ NEW MODEL CONFIGURATION
  static const String _apiUrl = 'https://predict.ultralytics.com';
  static const String _apiKey = '62136b284fcca764aec069d7ddd705de453fdecce7';
  static const String _modelUrl = 'https://hub.ultralytics.com/models/VxsrWl4kOqQJHLMzd2wv'; // ✅ NEW MODEL
  
  // ✅ NEW MODEL CLASSES: 5 classes (drainage, garbage, pothole, streetlight, waterleak)
  static const Map<String, String> _classToIssueType = {
    'drainage': 'Drainage Overflow',
    'garbage': 'Garbage Pile',
    'pothole': 'Pothole',
    'streetlight': 'Streetlight Broken',
    'waterleak': 'Water Leak',
    // Note: 'Road Crack' is NOT in the model - will be handled manually
  };
  
  // Department mapping (including Road Crack for manual selection)
  static const Map<String, String> _issueToDepartment = {
    'Pothole': 'Road Department',
    'Streetlight Broken': 'Electrical Department', 
    'Garbage Pile': 'Sanitation Department',
    'Water Leak': 'Water & Sewerage',
    'Drainage Overflow': 'Water & Sewerage',
    'Road Crack': 'Road Department', // Manual selection only
  };

  /// ✅ MAIN API METHOD - Updated with 75% confidence threshold
  static Future<Map<String, dynamic>> analyzeImage(String firebaseImageUrl) async {
    try {
      print('🏆 CIVICHERO IGNITEX AI ANALYSIS - New 5-Class Model');
      print('🤖 Starting IgniteX AI Analysis...');
      print('📎 Firebase Image URL: $firebaseImageUrl');
      print('🔗 IgniteX API Endpoint: $_apiUrl');
      print('🔑 API Key: ${_apiKey.substring(0, 10)}...');
      print('🤖 Model URL: $_modelUrl');
      
      // Validate Firebase URL
      if (firebaseImageUrl.isEmpty || !firebaseImageUrl.startsWith('http')) {
        throw Exception('Invalid Firebase image URL: $firebaseImageUrl');
      }
      
      // Download image from Firebase Storage
      print('📥 IgniteX: Downloading image from Firebase Storage...');
      Uint8List imageBytes;
      try {
        imageBytes = await _downloadImageFromFirebase(firebaseImageUrl);
        print('✅ IgniteX: Image downloaded successfully: ${imageBytes.length} bytes');
        
        if (imageBytes.isEmpty) {
          throw Exception('Downloaded image is empty (0 bytes)');
        }
      } catch (e) {
        print('❌ IgniteX: Failed to download image from Firebase: $e');
        rethrow;
      }
      
      // Send to Ultralytics API (backend)
      print('🚀 IgniteX: Sending to NEW 5-class AI model...');
      print('   - Image size: ${imageBytes.length} bytes');
      print('   - Model: $_modelUrl');
      print('   - Image size param: 640');
      print('   - Confidence threshold: 0.25 (filtered to 0.75 later)');
      
      Map<String, dynamic> result;
      try {
        result = await _sendToIgniteXAPI(imageBytes);
        print('✅ IgniteX AI Analysis Complete');
        print('   - Success: ${result['success']}');
        print('   - Detected: ${result['detected_issue']}');
        print('   - Confidence: ${result['confidence']}');
        return result;
      } catch (e) {
        print('❌ IgniteX: API call failed: $e');
        print('   Error type: ${e.runtimeType}');
        print('   Error message: $e');
        rethrow;
      }
      
    } catch (e, stackTrace) {
      print('❌ IgniteX AI analysis failed: $e');
      print('📚 Stack trace: $stackTrace');
      return {
        'success': false,
        'detected_issue': null,
        'ai_department': null,
        'confidence': 0.0,
        'message': 'IgniteX AI analysis failed: $e',
        'requires_manual_selection': true,
        'is_ignitex_api_error': true,
        'error_details': e.toString(),
      };
    }
  }

  /// Download image from Firebase Storage
  static Future<Uint8List> _downloadImageFromFirebase(String imageUrl) async {
    try {
      print('   📥 Downloading from: $imageUrl');
      
      final uri = Uri.parse(imageUrl);
      if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
        throw Exception('Invalid URL scheme: ${uri.scheme}');
      }
      
      print('   ⏳ Sending HTTP GET request...');
      final response = await http.get(uri).timeout(
        const Duration(seconds: 30),
      );
      
      print('   📨 Response received:');
      print('      Status: ${response.statusCode}');
      print('      Content-Type: ${response.headers['content-type']}');
      print('      Content-Length: ${response.bodyBytes.length} bytes');
      
      if (response.statusCode != 200) {
        print('   ❌ HTTP Error: ${response.statusCode}');
        print('      Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
        throw Exception('Failed to download image: HTTP ${response.statusCode}');
      }
      
      if (response.bodyBytes.isEmpty) {
        throw Exception('Downloaded image is empty (0 bytes)');
      }
      
      print('   ✅ Image downloaded successfully: ${response.bodyBytes.length} bytes');
      return response.bodyBytes;
      
    } catch (e) {
      print('   ❌ Image download error: $e');
      print('   📎 URL was: $imageUrl');
      throw Exception('Image download failed: $e');
    }
  }

  /// ✅ Send image to NEW IgniteX AI Model
  static Future<Map<String, dynamic>> _sendToIgniteXAPI(Uint8List imageBytes) async {
    try {
      print('📤 IgniteX: Preparing API request...');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      
      // Add headers
      request.headers['x-api-key'] = _apiKey;
      print('   ✅ Header set: x-api-key');
      
      // ✅ NEW MODEL PARAMETERS
      request.fields['model'] = _modelUrl;
      request.fields['imgsz'] = '640';
      request.fields['conf'] = '0.25'; // Ultralytics will detect at 25%, we filter at 75% later
      request.fields['iou'] = '0.45';
      print('   ✅ Fields set: model, imgsz=640, conf=0.25, iou=0.45');
      
      // Add image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'ignitex_civic_image.jpg',
        ),
      );
      print('   ✅ Image file added: ${imageBytes.length} bytes');
      
      print('📤 IgniteX: Sending request to NEW 5-class model...');
      print('   URL: $_apiUrl');
      print('   Method: POST');
      print('   Content-Type: multipart/form-data');
      
      // Send request with timeout
      http.StreamedResponse streamedResponse;
      try {
        streamedResponse = await request.send().timeout(
          const Duration(seconds: 60),
        );
        print('   ✅ Request sent, waiting for response...');
      } catch (e) {
        print('❌ IgniteX: Request send failed: $e');
        throw Exception('Failed to send request to Ultralytics API: $e');
      }
      
      // Get response
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📨 IgniteX API Response received:');
      print('   Status Code: ${response.statusCode}');
      print('   Content Length: ${response.body.length} bytes');
      print('   Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        print('✅ IgniteX: API returned 200 OK');
        
        Map<String, dynamic> jsonResponse;
        try {
          jsonResponse = json.decode(response.body) as Map<String, dynamic>;
          print('✅ IgniteX: Response JSON parsed successfully');
        } catch (e) {
          print('❌ IgniteX: Failed to parse JSON response: $e');
          print('   Response body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
          throw Exception('Invalid JSON response from API: $e');
        }
        
        // Enhanced logging for debugging
        print('📊 IgniteX API Response Structure:');
        print('   - Response keys: ${jsonResponse.keys.join(", ")}');
        print('   - Has images: ${jsonResponse.containsKey('images')}');
        if (jsonResponse.containsKey('images')) {
          final images = jsonResponse['images'] as List?;
          print('   - Images count: ${images?.length ?? 0}');
          if (images != null && images.isNotEmpty) {
            final firstImg = images[0] as Map?;
            print('   - First image keys: ${firstImg?.keys.join(", ") ?? "null"}');
            print('   - First image has results: ${firstImg?.containsKey('results') ?? false}');
            if (firstImg?.containsKey('results') == true) {
              final results = firstImg!['results'] as List?;
              print('   - Results count: ${results?.length ?? 0}');
              if (results != null && results.isNotEmpty) {
                print('   - First result keys: ${(results[0] as Map?)?.keys.join(", ") ?? "null"}');
              }
            }
          }
        }
        
        return _processIgniteXAPIResponse(jsonResponse);
      } else {
        print('❌ IgniteX API Error Response:');
        print('   Status: ${response.statusCode}');
        print('   Body (first 1000 chars): ${response.body.length > 1000 ? response.body.substring(0, 1000) : response.body}');
        throw Exception('IgniteX API request failed: HTTP ${response.statusCode}\nBody: ${response.body.length > 500 ? response.body.substring(0, 500) + "..." : response.body}');
      }
      
    } catch (e, stackTrace) {
      print('❌ IgniteX: API request exception: $e');
      print('📚 Stack trace: $stackTrace');
      throw Exception('IgniteX API request failed: $e');
    }
  }

  /// ✅ Process API response with 75% confidence threshold
  static Map<String, dynamic> _processIgniteXAPIResponse(Map<String, dynamic> apiResponse) {
    try {
      print('🔄 IgniteX: Processing NEW model AI response...');
      print('📊 IgniteX Raw response keys: ${apiResponse.keys.join(', ')}');
      
      // Check if response has images
      final images = apiResponse['images'] as List<dynamic>? ?? [];
      if (images.isEmpty) {
        return _createNoDetectionResult('No images in IgniteX AI response');
      }
      
      final firstImage = images[0] as Map<String, dynamic>;
      final results = firstImage['results'] as List<dynamic>? ?? [];
      
      print('📊 IgniteX: Found ${results.length} detections from NEW model');
      
      if (results.isEmpty) {
        return _createNoDetectionResult('No civic issues detected by IgniteX AI');
      }
      
      // ✅ Find best detection with 75% confidence threshold
      Map<String, dynamic>? bestDetection;
      double highestConfidence = 0.0;
      String? detectedClass;
      
      for (var detection in results) {
        // Handle both 'name' and 'class' fields (API might return either)
        String className;
        if (detection.containsKey('name')) {
          className = (detection['name'] ?? '').toString().toLowerCase();
        } else if (detection.containsKey('class')) {
          // If only class number is provided, we'd need a mapping
          // For now, skip if no name
          print('⚠️ Detection has class number but no name: ${detection['class']}');
          continue;
        } else {
          print('⚠️ Detection missing both name and class: $detection');
          continue;
        }
        
        final confidence = (detection['confidence'] as num?)?.toDouble() ?? 0.0;
        
        print('🔍 IgniteX Detection: $className (${(confidence * 100).toStringAsFixed(1)}%)');
        
        // Check if it matches our 5 civic issue classes
        if (_classToIssueType.containsKey(className) && confidence > highestConfidence) {
          highestConfidence = confidence;
          bestDetection = detection;
          detectedClass = className;
          
          print('✅ IgniteX Best match so far: $className (${(confidence * 100).toStringAsFixed(1)}%)');
        } else if (!_classToIssueType.containsKey(className)) {
          print('⚠️ IgniteX: Unknown class detected: $className (not in our 5-class model)');
        }
      }
      
      // ✅ CRITICAL: 75% confidence threshold check
      const double MIN_CONFIDENCE = 0.75; // 75% threshold
      
      if (bestDetection == null) {
        return _createNoDetectionResult('No civic issue detected above IgniteX confidence threshold');
      }
      
      if (highestConfidence < MIN_CONFIDENCE) {
        print('⚠️ IgniteX: Confidence ${(highestConfidence * 100).toStringAsFixed(1)}% is below 75% threshold');
        return _createLowConfidenceResult(detectedClass!, highestConfidence, bestDetection);
      }
      
      return _createIgniteXSuccessResult(detectedClass!, highestConfidence, bestDetection, results);
      
    } catch (e) {
      print('❌ Error processing IgniteX AI response: $e');
      return _createNoDetectionResult('Failed to process IgniteX AI response: $e');
    }
  }

  /// ✅ Create successful detection result (>=75% confidence)
  static Map<String, dynamic> _createIgniteXSuccessResult(
    String detectedClass, 
    double confidence, 
    Map<String, dynamic> detection,
    List<dynamic> allResults,
  ) {
    final issueType = _classToIssueType[detectedClass]!;
    final department = _issueToDepartment[issueType]!;
    
    print('🎯 IGNITEX AI HIGH CONFIDENCE DETECTION: $issueType (${(confidence * 100).toStringAsFixed(1)}%)');
    print('🏢 IgniteX Department Assignment: $department');
    print('✅ IgniteX: Confidence meets 75% threshold - Auto-selecting');
    
    return {
      'success': true,
      'detected_issue': issueType,
      'ai_department': department,
      'confidence': confidence,
      'message': '🎯 HIGH CONFIDENCE IGNITEX AI DETECTION (≥75%)',
      'requires_manual_selection': false, // ✅ Auto-select because >=75%
      'is_ignitex_ai': true,
      'detection_metadata': {
        'model': 'IgniteX Custom 5-Class YOLO Model',
        'api_endpoint': _apiUrl,
        'detected_class': detectedClass,
        'raw_detection': detection,
        'total_detections': allResults.length,
        'processing': 'IgniteX Cloud-based YOLO Inference',
        'ai_engine': 'IgniteX Computer Vision Platform',
        'model_version': 'v2.0-5class',
      },
      'technical_details': {
        'confidence_threshold': '75%',
        'detection_confidence': '${(confidence * 100).toStringAsFixed(1)}%',
        'image_size': '640x640',
        'model_type': 'IgniteX YOLOv8 Custom 5-Class',
        'api_version': 'IgniteX AI Platform v2.0',
        'processing_engine': 'Advanced Computer Vision by IgniteX',
        'all_detections': allResults,
        'classes_trained': ['drainage', 'garbage', 'pothole', 'streetlight', 'waterleak'],
      },
    };
  }

  /// ✅ Create low confidence result (<75%) - requires manual selection
  static Map<String, dynamic> _createLowConfidenceResult(
    String detectedClass,
    double confidence,
    Map<String, dynamic> detection,
  ) {
    final issueType = _classToIssueType[detectedClass]!;
    final department = _issueToDepartment[issueType]!;
    
    print('📊 IGNITEX AI LOW CONFIDENCE: $issueType (${(confidence * 100).toStringAsFixed(1)}%)');
    print('⚠️ IgniteX: Below 75% threshold - Requires manual selection');
    
    return {
      'success': true, // Detection was made, but low confidence
      'detected_issue': issueType, // Show suggestion
      'ai_department': department, // Show suggested department
      'confidence': confidence,
      'message': '⚠️ LOW CONFIDENCE (${(confidence * 100).toStringAsFixed(1)}%) - Please verify and select manually',
      'requires_manual_selection': true, // ✅ Must select manually because <75%
      'is_ignitex_ai': true,
      'low_confidence_warning': true,
      'detection_metadata': {
        'model': 'IgniteX Custom 5-Class YOLO Model',
        'detected_class': detectedClass,
        'raw_detection': detection,
        'reason': 'Confidence below 75% threshold',
        'suggested_issue': issueType,
        'model_version': 'v2.0-5class',
      },
    };
  }

  /// Create no detection result with IgniteX branding
  static Map<String, dynamic> _createNoDetectionResult(String reason) {
    print('ℹ️ IgniteX: No detection - $reason');
    
    return {
      'success': false,
      'detected_issue': null,
      'ai_department': null,
      'confidence': 0.0,
      'message': 'IgniteX AI: $reason - Please select manually',
      'requires_manual_selection': true,
      'is_ignitex_ai': true,
      'detection_metadata': {
        'reason': reason,
        'model_version': 'v2.0-5class',
      },
    };
  }

  /// Get department for issue type (including Road Crack)
  static String getDepartmentForIssue(String issueType) {
    return _issueToDepartment[issueType] ?? 'Municipal Services Department';
  }

  /// ✅ Check if result has HIGH confidence (>=75%)
  static bool isHighConfidence(Map<String, dynamic> result) {
    final confidence = result['confidence'] as double? ?? 0.0;
    return confidence >= 0.75 && result['success'] == true; // ✅ 75% threshold
  }

  /// Test IgniteX AI connectivity
  static Future<bool> testAPIConnection() async {
    try {
      print('🔍 Testing IgniteX AI connectivity (NEW 5-class model)...');
      
      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'x-api-key': _apiKey},
      ).timeout(const Duration(seconds: 10));
      
      print('✅ IgniteX AI connectivity test: ${response.statusCode}');
      return response.statusCode == 200;
      
    } catch (e) {
      print('❌ IgniteX AI connectivity test failed: $e');
      return false;
    }
  }

  /// ✅ Get list of all available issue types (including manual Road Crack)
  static List<String> getAllIssueTypes() {
    return [
      'Pothole',
      'Streetlight Broken',
      'Garbage Pile',
      'Water Leak',
      'Drainage Overflow',
      'Road Crack', // Manual selection only - not in AI model
    ];
  }

  /// ✅ Check if an issue type is AI-detectable
  static bool isAIDetectable(String issueType) {
    return _classToIssueType.values.contains(issueType);
  }
}
