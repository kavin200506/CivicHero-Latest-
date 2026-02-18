import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Google Cloud Speech-to-Text API Service
/// Handles speech recognition with civic-specific vocabulary boost
class GoogleSpeechService {
  // Get API key from .env file
  String get _apiKey => dotenv.env['GOOGLE_SPEECH_API_KEY'] ?? '';
  
  // API endpoint
  static const String _baseUrl = 
    'https://speech.googleapis.com/v1/speech:recognize';

  /// Transcribe audio with civic-specific vocabulary boost
  Future<SpeechRecognitionResult> recognizeSpeech({
    required Uint8List audioBytes,
    String languageCode = 'en-IN', // Indian English by default
    List<String>? alternativeLanguages,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('API key not found. Check .env file');
    }

    final url = Uri.parse('$_baseUrl?key=$_apiKey');
    
    // Convert audio bytes to base64
    final base64Audio = base64Encode(audioBytes);
    
    final requestBody = {
      "config": {
        "encoding": "LINEAR16",
        "sampleRateHertz": 16000,
        "languageCode": languageCode,
        "alternativeLanguageCodes": alternativeLanguages ?? ["hi-IN", "ta-IN"], // Hindi, Tamil
        "enableAutomaticPunctuation": true,
        "model": "command_and_search", // Optimized for voice commands
        "useEnhanced": true, // Better accuracy
        
        // CIVIC-SPECIFIC VOCABULARY BOOST (English + Tamil + Hindi)
        "speechContexts": [
          {
            "phrases": [
              // Issue types - English
              "pothole", "potholes",
              "drainage", "drainage overflow",
              "garbage pile", "garbage", "trash", "waste", "rubbish",
              "streetlight", "streetlight broken", "light not working", "broken light",
              "water leak", "pipe leak", "leaking pipe", "water leaking",
              "road crack", "cracked road",
              
              // Issue types - Tamil
              "குழி", "குழி புகார்", "kuzhi", "kuzhi pugar",
              "வடிகால்", "வடிகால் புகார்", "vadigala", "vadigala pugar",
              "குப்பை", "குப்பை புகார்", "kuppai", "kuppai pugar",
              "தெரு விளக்கு", "விளக்கு", "teru vilakku", "vilakku",
              "நீர் கசிவு", "நீர் கசிவு புகார்", "neer kasivu", "neer kasivu pugar",
              "சாலை விரிசல்", "விரிசல்", "salai virisal", "virisal",
              
              // Issue types - Hindi
              "गड्ढा", "gaddha",
              "नाली", "nali",
              "कचरा", "kachra",
              "स्ट्रीट लाइट", "light",
              "पानी का रिसाव", "pani ka risav",
              "सड़क दरार", "sadak darar",
              
              // Navigation - English
              "open camera", "take photo", "take picture", "capture",
              "show reports", "view history", "my reports", "show my reports",
              "go back", "cancel", "return",
              "go home", "home", "home screen",
              "open profile", "profile", "my profile",
              "open settings", "settings",
              
              // Navigation - Tamil
              "கேமரா திற", "கேமரா", "புகைப்படம் எடு", "camera thira", "camera", "pugaippadam edu",
              "புகார்களை காட்டு", "புகார்கள்", "pugargalai kattu", "pugargal",
              "பின்னால் செல்", "பின்", "pinnale sel", "pin",
              "வீட்டிற்கு செல்", "வீட்டிற்கு", "வீடு", "veettirku sel", "veettirku", "veedu",
              "சுயவிவரம் திற", "சுயவிவரம்", "suyavivaram thira", "suyavivaram",
              "அமைப்புகள் திற", "அமைப்புகள்", "amaipugal thira", "amaipugal",
              
              // Navigation - Hindi
              "कैमरा खोलो", "फोटो लो", "camera kholo", "photo lo",
              "रिपोर्ट दिखाओ", "report dikhao",
              "वापस जाओ", "vapas jao",
              "घर जाओ", "ghar jao",
              "प्रोफ़ाइल खोलो", "profile kholo",
              "सेटिंग्स खोलो", "settings kholo",
              
              // Urgency - English
              "urgent", "critical", "emergency", "immediately",
              "high priority", "medium priority", "low priority", "important", "serious",
              
              // Urgency - Tamil
              "அவசரம்", "முக்கியம்", "அவசர", "avasaram", "mukkiyam", "avasar",
              "உயர் முன்னுரிமை", "uyar munnurimai",
              "நடுத்தர முன்னுரிமை", "naduthara munnurimai",
              "குறைந்த முன்னுரிமை", "kurainda munnurimai",
              
              // Urgency - Hindi
              "जरूरी", "महत्वपूर्ण", "jaruri", "mahatvapurn",
              "उच्च प्राथमिकता", "uchch prathamikta",
              "मध्यम प्राथमिकता", "madhyam prathamikta",
              "कम प्राथमिकता", "kam prathamikta",
              
              // Actions - English
              "submit", "submit report", "send complaint", "send",
              "add description", "add details",
              "help", "show commands", "what can you do",
              
              // Actions - Tamil
              "சமர்ப்பி", "புகார் அனுப்ப", "samarppi", "pugar anuppa",
              "ரத்து", "நீக்க", "rattu", "neekka",
              "உதவி", "கட்டளைகளை காட்டு", "uthavi", "kattalaigalai kattu",
              
              // Actions - Hindi
              "जमा करो", "रिपोर्ट भेजो", "jama karo", "report bhejo",
              "रद्द करो", "radd karo",
              "मदद", "कमांड दिखाओ", "madad", "command dikhao",
            ],
            "boost": 20.0 // 20x more likely to recognize these words
          }
        ],
        
        // Profanity filter (optional - disable if users might use strong language)
        "profanityFilter": false,
        
        // Enable word confidence scores
        "enableWordConfidence": true,
      },
      "audio": {
        "content": base64Audio
      }
    };

    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          if (data['results'] != null && data['results'].isNotEmpty) {
            final result = data['results'][0]['alternatives'][0];
            
            return SpeechRecognitionResult(
              transcript: result['transcript'] ?? '',
              confidence: (result['confidence'] ?? 0.0).toDouble(),
              words: (result['words'] as List?)
                  ?.map((w) => WordInfo(
                        word: w['word'] ?? '',
                        confidence: (w['confidence'] ?? 0.0).toDouble(),
                      ))
                  .toList() ?? [],
            );
          } else {
            throw Exception('No speech detected in audio');
          }
        } else {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
          
          // Don't retry on authentication errors
          if (response.statusCode == 401 || response.statusCode == 403) {
            throw Exception('API authentication failed: $errorMessage');
          }
          
          // Retry on server errors
          if (response.statusCode >= 500 && retryCount < maxRetries - 1) {
            retryCount++;
            await Future.delayed(Duration(seconds: retryCount * 2)); // Exponential backoff
            continue;
          }
          
          throw Exception('API Error: $errorMessage');
        }
      } catch (e) {
        if (e.toString().contains('TimeoutException') && retryCount < maxRetries - 1) {
          retryCount++;
          await Future.delayed(Duration(seconds: retryCount * 2));
          continue;
        }
        throw Exception('Speech recognition failed: $e');
      }
    }
    
    throw Exception('Speech recognition failed after $maxRetries retries');
  }

  /// Check if API key is configured
  bool get isConfigured => _apiKey.isNotEmpty && _apiKey != 'YOUR_API_KEY_HERE';
}

/// Speech recognition result
class SpeechRecognitionResult {
  final String transcript;
  final double confidence;
  final List<WordInfo> words;

  SpeechRecognitionResult({
    required this.transcript,
    required this.confidence,
    required this.words,
  });
  
  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.5 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.5;
}

/// Word-level information
class WordInfo {
  final String word;
  final double confidence;

  WordInfo({
    required this.word,
    required this.confidence,
  });
}

