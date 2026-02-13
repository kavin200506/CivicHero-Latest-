import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

/// Helper class to get authenticated Firebase Storage URLs
/// For Flutter web, we download images as bytes to avoid CORS issues
class ImageHelper {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get image as data URL (base64) to avoid CORS issues on Flutter web
  /// This downloads the image using Firebase Storage SDK and converts to data URL
  static Future<String?> getImageAsDataUrl(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      print('⚠️ ImageHelper: Empty image URL');
      return null;
    }

    // If user is not authenticated, return null
    if (_auth.currentUser == null) {
      print('⚠️ ImageHelper: User not authenticated, cannot get image');
      return null;
    }

    print('📸 ImageHelper: Downloading image as bytes to avoid CORS...');

    try {
      // Extract the file path from the Storage URL
      final uri = Uri.parse(imageUrl);
      
      // Check if it's a Firebase Storage URL
      if (!uri.host.contains('firebasestorage.googleapis.com')) {
        print('⚠️ ImageHelper: Not a Firebase Storage URL');
        return null;
      }

      final pathSegments = uri.pathSegments;
      
      // Find the path after '/o/'
      final pathIndex = pathSegments.indexOf('o');
      if (pathIndex == -1 || pathIndex >= pathSegments.length - 1) {
        print('❌ ImageHelper: Could not find path segment "o"');
        return null;
      }

      // Reconstruct the path
      final pathParts = pathSegments.sublist(pathIndex + 1);
      final decodedPath = pathParts.map((segment) => Uri.decodeComponent(segment)).join('/');
      print('📸 ImageHelper: Decoded path: $decodedPath');

      // Get reference to the file
      final ref = _storage.ref(decodedPath);

      // Download image as bytes (this avoids CORS issues)
      print('   Downloading image bytes from Storage...');
      final Uint8List? imageBytes = await ref.getData();
      
      if (imageBytes == null || imageBytes.isEmpty) {
        print('❌ ImageHelper: Downloaded image is null or empty');
        return null;
      }

      // Convert to base64 data URL
      final base64Image = base64Encode(imageBytes);
      final dataUrl = 'data:image/jpeg;base64,$base64Image';
      
      print('✅ ImageHelper: Image downloaded and converted to data URL (${imageBytes.length} bytes)');
      return dataUrl;
    } catch (e, stackTrace) {
      print('❌ ImageHelper: Error downloading image: $e');
      print('   Error type: ${e.runtimeType}');
      print('   Stack trace: $stackTrace');
      return null;
    }
  }

  /// Get an authenticated download URL from a Firebase Storage URL
  /// For Flutter web, we need to get a fresh URL with auth tokens
  static Future<String?> getAuthenticatedUrl(String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) {
      print('⚠️ ImageHelper: Empty image URL');
      return null;
    }

    // If user is not authenticated, return null
    if (_auth.currentUser == null) {
      print('⚠️ ImageHelper: User not authenticated, cannot get image URL');
      return null;
    }

    print('📸 ImageHelper: Processing URL: ${imageUrl.substring(0, imageUrl.length > 100 ? 100 : imageUrl.length)}...');

    try {
      // Extract the file path from the Storage URL
      // URL format: https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{encodedPath}?alt=media&token={token}
      final uri = Uri.parse(imageUrl);
      
      // Check if it's a Firebase Storage URL
      if (!uri.host.contains('firebasestorage.googleapis.com')) {
        print('⚠️ ImageHelper: Not a Firebase Storage URL, using as-is');
        return imageUrl;
      }

      final pathSegments = uri.pathSegments;
      print('   Path segments: $pathSegments');
      
      // Find the path after '/o/'
      final pathIndex = pathSegments.indexOf('o');
      if (pathIndex == -1 || pathIndex >= pathSegments.length - 1) {
        // If we can't parse the path, try using the URL directly
        // For web, the original URL might work if it has a valid token
        print('📸 ImageHelper: Could not find path segment "o", using original URL');
        return imageUrl;
      }

      // Reconstruct the path (all segments after 'o')
      // The path is URL-encoded in the segments, so we need to decode it
      final pathParts = pathSegments.sublist(pathIndex + 1);
      print('   Path parts: $pathParts');
      
      // Join and decode each segment
      final decodedPath = pathParts.map((segment) => Uri.decodeComponent(segment)).join('/');
      print('📸 ImageHelper: Decoded path: $decodedPath');

      // Get reference to the file
      final ref = _storage.ref(decodedPath);

      // Get download URL (this will include fresh auth token for current user)
      print('   Getting fresh download URL from Storage...');
      final downloadUrl = await ref.getDownloadURL();
      
      print('✅ ImageHelper: Got authenticated URL successfully');
      return downloadUrl;
    } catch (e, stackTrace) {
      print('❌ ImageHelper: Error getting authenticated URL: $e');
      print('   Error type: ${e.runtimeType}');
      print('   Stack trace: $stackTrace');
      print('   Original URL: ${imageUrl.substring(0, imageUrl.length > 150 ? 150 : imageUrl.length)}...');
      
      // Fallback: return original URL
      // For web, sometimes the original URL works if it has a valid token
      print('   ⚠️ Falling back to original URL');
      return imageUrl;
    }
  }

  /// Check if a URL is a Firebase Storage URL
  static bool isFirebaseStorageUrl(String url) {
    return url.contains('firebasestorage.googleapis.com');
  }
}

