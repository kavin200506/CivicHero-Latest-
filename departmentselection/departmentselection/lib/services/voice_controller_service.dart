import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../models/voice_command_event.dart';
import 'voice_settings_service.dart';

/// Global Voice Controller Service
/// Handles voice input, command processing, and text-to-speech feedback
class VoiceControllerService {
  static final VoiceControllerService _instance = VoiceControllerService._internal();
  factory VoiceControllerService() => _instance;
  VoiceControllerService._internal();

  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isInitialized = false;
  bool _isListening = false;
  VoidCallback? _onListeningChanged;
  String _currentLanguage = 'en-IN';
  bool _hasReceivedSpeech = false; // Track if any speech was detected
  String _lastError = ''; // Track last error to avoid spam
  String? _lastRecognizedWords; // Store last recognized words for push-to-talk
  double _lastConfidence = 0.0; // Store last confidence for push-to-talk
  bool _isPushToTalkMode = false; // Track if we're in push-to-talk mode

  // Current context for navigation
  BuildContext? _context;
  
  // Language-specific TTS responses
  Map<String, Map<String, String>> _ttsResponses = {
    'en-IN': {
      'going_home': 'Going to home screen',
      'opening_camera': 'Opening camera',
      'showing_reports': 'Showing your reports',
      'opening_profile': 'Opening profile',
      'opening_settings': 'Opening settings',
      'going_back': 'Going back',
      'showing_help': 'Showing available voice commands',
      'refreshing': 'Refreshing screen',
      'pothole_selected': 'Pothole selected',
      'garbage_selected': 'Garbage issue selected',
      'streetlight_selected': 'Streetlight issue selected',
      'drainage_selected': 'Drainage issue selected',
      'water_leak_selected': 'Water leak selected',
      'road_crack_selected': 'Road crack selected',
      'marked_critical': 'Marked as critical',
      'set_high': 'Set to high priority',
      'set_medium': 'Set to medium priority',
      'set_low': 'Set to low priority',
      'submitting': 'Submitting your report',
      'cancelled': 'Cancelled',
      'description_added': 'Description added',
      'taking_photo': 'Taking photo',
      'retaking_photo': 'Retaking photo',
      'photo_confirmed': 'Photo confirmed',
      'showing_pending': 'Showing pending reports',
      'showing_resolved': 'Showing resolved reports',
      'showing_in_progress': 'Showing in progress reports',
      'showing_all': 'Showing all reports',
      'name_changed': 'Name changed to',
      'phone_updated': 'Phone updated to',
      'notifications_enabled': 'Notifications enabled',
      'notifications_disabled': 'Notifications disabled',
      'logging_out': 'Logging out',
      'opening_first': 'Opening first report',
      'opening_second': 'Opening second report',
      'opening_third': 'Opening third report',
      'scrolling_down': 'Scrolling down',
      'not_understood': "Sorry, I didn't understand. Say 'help' to see available commands.",
      'not_sure': "I'm not sure I understood. Please try again.",
      'no_context': 'Unable to process command. No screen context.',
      'speech_unavailable': 'Speech recognition is not available. Please check microphone permissions.',
      'couldnt_hear': "Sorry, I couldn't hear you. Please try again.",
    },
    'ta-IN': {
      'going_home': 'வீட்டிற்கு செல்கிறேன்',
      'opening_camera': 'கேமரா திறக்கிறேன்',
      'showing_reports': 'உங்கள் புகார்களை காட்டுகிறேன்',
      'opening_profile': 'சுயவிவரத்தை திறக்கிறேன்',
      'opening_settings': 'அமைப்புகளை திறக்கிறேன்',
      'going_back': 'பின்னால் செல்கிறேன்',
      'showing_help': 'கிடைக்கக்கூடிய குரல் கட்டளைகளை காட்டுகிறேன்',
      'refreshing': 'திரையை புதுப்பிக்கிறேன்',
      'pothole_selected': 'குழி தேர்ந்தெடுக்கப்பட்டது',
      'garbage_selected': 'குப்பை பிரச்சனை தேர்ந்தெடுக்கப்பட்டது',
      'streetlight_selected': 'தெரு விளக்கு பிரச்சனை தேர்ந்தெடுக்கப்பட்டது',
      'drainage_selected': 'வடிகால் பிரச்சனை தேர்ந்தெடுக்கப்பட்டது',
      'water_leak_selected': 'நீர் கசிவு தேர்ந்தெடுக்கப்பட்டது',
      'road_crack_selected': 'சாலை விரிசல் தேர்ந்தெடுக்கப்பட்டது',
      'marked_critical': 'முக்கியமானதாக குறிக்கப்பட்டது',
      'set_high': 'உயர் முன்னுரிமையாக அமைக்கப்பட்டது',
      'set_medium': 'நடுத்தர முன்னுரிமையாக அமைக்கப்பட்டது',
      'set_low': 'குறைந்த முன்னுரிமையாக அமைக்கப்பட்டது',
      'submitting': 'உங்கள் புகாரை சமர்ப்பிக்கிறேன்',
      'cancelled': 'ரத்து செய்யப்பட்டது',
      'description_added': 'விளக்கம் சேர்க்கப்பட்டது',
      'taking_photo': 'புகைப்படம் எடுக்கிறேன்',
      'retaking_photo': 'புகைப்படத்தை மீண்டும் எடுக்கிறேன்',
      'photo_confirmed': 'புகைப்படம் உறுதிப்படுத்தப்பட்டது',
      'showing_pending': 'நிலுவையில் உள்ள புகார்களை காட்டுகிறேன்',
      'showing_resolved': 'தீர்க்கப்பட்ட புகார்களை காட்டுகிறேன்',
      'showing_in_progress': 'நடைபெறும் புகார்களை காட்டுகிறேன்',
      'showing_all': 'அனைத்து புகார்களையும் காட்டுகிறேன்',
      'name_changed': 'பெயர் மாற்றப்பட்டது',
      'phone_updated': 'தொலைபேசி புதுப்பிக்கப்பட்டது',
      'notifications_enabled': 'அறிவிப்புகள் இயக்கப்பட்டன',
      'notifications_disabled': 'அறிவிப்புகள் முடக்கப்பட்டன',
      'logging_out': 'வெளியேறுகிறேன்',
      'opening_first': 'முதல் புகாரை திறக்கிறேன்',
      'opening_second': 'இரண்டாவது புகாரை திறக்கிறேன்',
      'opening_third': 'மூன்றாவது புகாரை திறக்கிறேன்',
      'scrolling_down': 'கீழே உருட்டுகிறேன்',
      'not_understood': 'மன்னிக்கவும், எனக்கு புரியவில்லை. கிடைக்கக்கூடிய கட்டளைகளைப் பார்க்க "உதவி" என்று சொல்லுங்கள்.',
      'not_sure': 'நான் உறுதியாக புரியவில்லை. மீண்டும் முயற்சிக்கவும்.',
      'no_context': 'கட்டளையை செயல்படுத்த முடியவில்லை. திரை சூழல் இல்லை.',
      'speech_unavailable': 'குரல் அங்கீகாரம் கிடைக்கவில்லை. மைக்ரோஃபோன் அனுமதிகளை சரிபார்க்கவும்.',
      'couldnt_hear': 'மன்னிக்கவும், உங்களை கேட்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.',
    },
    'hi-IN': {
      'going_home': 'होम स्क्रीन पर जा रहे हैं',
      'opening_camera': 'कैमरा खोल रहे हैं',
      'showing_reports': 'आपकी रिपोर्ट दिखा रहे हैं',
      'opening_profile': 'प्रोफ़ाइल खोल रहे हैं',
      'opening_settings': 'सेटिंग्स खोल रहे हैं',
      'going_back': 'वापस जा रहे हैं',
      'showing_help': 'उपलब्ध आवाज़ कमांड दिखा रहे हैं',
      'refreshing': 'स्क्रीन रिफ्रेश कर रहे हैं',
      'pothole_selected': 'गड्ढा चुना गया',
      'garbage_selected': 'कचरा समस्या चुनी गई',
      'streetlight_selected': 'स्ट्रीट लाइट समस्या चुनी गई',
      'drainage_selected': 'नाली समस्या चुनी गई',
      'water_leak_selected': 'पानी का रिसाव चुना गया',
      'road_crack_selected': 'सड़क दरार चुनी गई',
      'marked_critical': 'महत्वपूर्ण के रूप में चिह्नित',
      'set_high': 'उच्च प्राथमिकता पर सेट',
      'set_medium': 'मध्यम प्राथमिकता पर सेट',
      'set_low': 'कम प्राथमिकता पर सेट',
      'submitting': 'आपकी रिपोर्ट जमा कर रहे हैं',
      'cancelled': 'रद्द किया गया',
      'description_added': 'विवरण जोड़ा गया',
      'taking_photo': 'फोटो ले रहे हैं',
      'retaking_photo': 'फोटो फिर से ले रहे हैं',
      'photo_confirmed': 'फोटो पुष्टि की गई',
      'showing_pending': 'लंबित रिपोर्ट दिखा रहे हैं',
      'showing_resolved': 'हल की गई रिपोर्ट दिखा रहे हैं',
      'showing_in_progress': 'प्रगति में रिपोर्ट दिखा रहे हैं',
      'showing_all': 'सभी रिपोर्ट दिखा रहे हैं',
      'name_changed': 'नाम बदल दिया गया',
      'phone_updated': 'फोन अपडेट किया गया',
      'notifications_enabled': 'सूचनाएं सक्षम की गईं',
      'notifications_disabled': 'सूचनाएं अक्षम की गईं',
      'logging_out': 'लॉग आउट कर रहे हैं',
      'opening_first': 'पहली रिपोर्ट खोल रहे हैं',
      'opening_second': 'दूसरी रिपोर्ट खोल रहे हैं',
      'opening_third': 'तीसरी रिपोर्ट खोल रहे हैं',
      'scrolling_down': 'नीचे स्क्रॉल कर रहे हैं',
      'not_understood': 'क्षमा करें, मैं समझ नहीं पाया। उपलब्ध कमांड देखने के लिए "मदद" कहें।',
      'not_sure': 'मुझे यकीन नहीं है कि मैं समझ गया। कृपया पुनः प्रयास करें।',
      'no_context': 'कमांड संसाधित करने में असमर्थ। कोई स्क्रीन संदर्भ नहीं।',
      'speech_unavailable': 'स्पीच रिकग्निशन उपलब्ध नहीं है। कृपया माइक्रोफोन अनुमतियों की जांच करें।',
      'couldnt_hear': 'क्षमा करें, मैं आपको सुन नहीं सका। कृपया पुनः प्रयास करें।',
    },
  };
  
  String _getTTSResponse(String key) {
    return _ttsResponses[_currentLanguage]?[key] ?? _ttsResponses['en-IN']![key]!;
  }

  /// Initialize the voice controller
  Future<void> initialize() async {
    if (_isInitialized) return;

    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    
    // Configure TTS for Indian English
    await _tts.setLanguage("en-IN");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    // Set TTS completion handler
    _tts.setCompletionHandler(() {
      // Auto-restart listening after TTS finishes
      if (_isListening == false) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_context != null) {
            startListening();
          }
        });
      }
    });

    _isInitialized = true;
    print('✅ Voice Controller initialized');
  }

  /// Set the current build context for navigation
  void setContext(BuildContext context) {
    _context = context;
  }

  /// Set callback for listening state changes
  void setListeningCallback(VoidCallback callback) {
    _onListeningChanged = callback;
  }

  bool get isListening => _isListening;

  /// Start global voice listening
  /// [isContinuous] - if true, will auto-restart after processing
  Future<void> startListening({bool? isContinuous}) async {
    if (!_isInitialized) await initialize();
    
    // Check current mode and override isContinuous if needed
    final currentMode = await VoiceSettingsService.getVoiceMode();
    if (currentMode == 'push_to_talk' && (isContinuous ?? false)) {
      print('⚠️ Cannot start continuous listening in push-to-talk mode');
      return;
    }
    
    if (_isListening) {
      // If already listening and mode changed, stop first
      if (currentMode == 'push_to_talk' && (isContinuous ?? false)) {
        await stopListening();
      } else {
        return;
      }
    }

    // Reset speech detection flag
    _hasReceivedSpeech = false;

    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Voice status: $status');
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          _onListeningChanged?.call();
          
          // Only auto-restart in continuous mode and if no error occurred
          if (isContinuous ?? false) {
            VoiceSettingsService.getVoiceMode().then((mode) {
              // Double check mode is still continuous before auto-restarting
              if (mode == 'continuous' && _lastError.isEmpty && isContinuous == true) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_context != null && !_isListening) {
                    // Verify mode again before restarting
                    VoiceSettingsService.getVoiceMode().then((currentMode) {
                      if (currentMode == 'continuous') {
                        startListening(isContinuous: true);
                      }
                    });
                  }
                });
              }
            });
          }
        }
      },
      onError: (error) {
        print('Voice error: ${error.errorMsg}');
        _isListening = false;
        _onListeningChanged?.call();
        
        // Only show error if speech was actually detected but failed
        // Don't show error for "no speech detected" or "timeout" when no speech was received
        if (_hasReceivedSpeech || error.errorMsg.contains('error') || error.errorMsg.contains('network')) {
          _lastError = error.errorMsg;
          speak(_getTTSResponse('couldnt_hear'));
        } else {
          // Silent failure for "no speech detected" scenarios
          _lastError = '';
        }
      },
    );

    if (available) {
      _isListening = true;
      _onListeningChanged?.call();
      _lastError = ''; // Reset error on successful start
      
      // Track if we're in push-to-talk mode
      _isPushToTalkMode = !(isContinuous ?? false);
      _lastRecognizedWords = null; // Reset
      _lastConfidence = 0.0;
      
      await _speech.listen(
        onResult: (result) {
          // Mark that we received speech
          if (result.recognizedWords.isNotEmpty) {
            _hasReceivedSpeech = true;
            _lastRecognizedWords = result.recognizedWords;
            _lastConfidence = result.confidence;
          }
          
          if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
            _lastRecognizedWords = result.recognizedWords;
            _lastConfidence = result.confidence;
            // In continuous mode, process immediately
            if (isContinuous ?? false) {
              _processGlobalCommand(result.recognizedWords, result.confidence, isContinuous: isContinuous);
            }
            // In push-to-talk mode, store for processing when button is released
          }
        },
        localeId: _currentLanguage,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        partialResults: true,
      );
    } else {
      speak(_getTTSResponse('speech_unavailable'));
    }
  }

  /// Stop listening
  /// In push-to-talk mode, processes any captured command before stopping
  Future<void> stopListening() async {
    print('🛑 stopListening called - isListening: $_isListening, isPushToTalk: $_isPushToTalkMode');
    
    // Force stop speech recognition
    try {
      await _speech.stop();
      await _speech.cancel(); // Also cancel to ensure it stops
    } catch (e) {
      print('⚠️ Error stopping speech: $e');
    }
    
    _isListening = false;
    _onListeningChanged?.call();
    
    // If in push-to-talk mode and we have recognized words, process the command
    if (_isPushToTalkMode && _lastRecognizedWords != null && _lastRecognizedWords!.trim().isNotEmpty) {
      final words = _lastRecognizedWords!;
      final confidence = _lastConfidence;
      _lastRecognizedWords = null; // Clear after processing
      _lastConfidence = 0.0;
      
      print('📝 Processing push-to-talk command: "$words" (confidence: ${(confidence * 100).toStringAsFixed(1)}%)');
      
      // Process the command
      Future.delayed(const Duration(milliseconds: 300), () {
        _processGlobalCommand(words, confidence, isContinuous: false);
      });
    }
    
    _isPushToTalkMode = false; // Reset flag
    print('✅ stopListening completed');
  }

  /// Speak text to user
  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    await _tts.stop(); // Stop any ongoing speech
    await _tts.speak(text);
    print('🔊 TTS: $text');
  }

  /// Set language for speech recognition and TTS
  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await _tts.setLanguage(languageCode);
    print('🌍 Language changed to: $languageCode');
  }
  
  /// Get current language
  String get currentLanguage => _currentLanguage;

  /// Process global voice commands
  void _processGlobalCommand(String command, double confidence, {bool? isContinuous}) {
    final cmd = command.toLowerCase().trim();
    print('🎤 Processing command: "$cmd" (confidence: ${(confidence * 100).toStringAsFixed(1)}%)');

    // Only process if confidence is above threshold
    if (confidence < 0.5) {
      // Only speak error if we're in continuous mode and user actually spoke
      if (isContinuous ?? false) {
        // Don't spam errors - only if confidence is very low and command is not empty
        if (cmd.isNotEmpty && confidence > 0.1) {
          speak(_getTTSResponse('not_sure'));
        }
      }
      return;
    }
    
    // Reset error flag on successful command
    _lastError = '';

    if (_context == null) {
      speak(_getTTSResponse('no_context'));
      return;
    }

    // Global Navigation Commands (English + Tamil + Hindi)
    if (_containsAny(cmd, [
      // English
      'go home', 'take me home', 'home screen', 'home',
      // Tamil
      'வீட்டிற்கு செல்', 'வீட்டிற்கு', 'வீடு', 'veettirku sel', 'veettirku', 'veedu',
      // Hindi
      'घर जाओ', 'होम', 'ghar jao', 'home'
    ])) {
      _navigateToHome();
      speak(_getTTSResponse('going_home'));
    }
    else if (_containsAny(cmd, [
      // English
      'open camera', 'take photo', 'capture photo', 'camera',
      // Tamil
      'கேமரா திற', 'கேமரா', 'புகைப்படம் எடு', 'camera thira', 'camera', 'pugaippadam edu',
      // Hindi
      'कैमरा खोलो', 'फोटो लो', 'camera kholo', 'photo lo'
    ])) {
      _navigateToCamera();
      speak(_getTTSResponse('opening_camera'));
    }
    else if (_containsAny(cmd, [
      // English
      'show reports', 'my reports', 'view complaints', 'show history', 'reports',
      // Tamil
      'புகார்களை காட்டு', 'புகார்கள்', 'pugargalai kattu', 'pugargal',
      // Hindi
      'रिपोर्ट दिखाओ', 'मेरी रिपोर्ट', 'report dikhao', 'meri report'
    ])) {
      _navigateToReports();
      speak(_getTTSResponse('showing_reports'));
    }
    else if (_containsAny(cmd, [
      // English
      'open profile', 'my profile', 'show profile', 'profile',
      // Tamil
      'சுயவிவரம் திற', 'சுயவிவரம்', 'suyavivaram thira', 'suyavivaram',
      // Hindi
      'प्रोफ़ाइल खोलो', 'मेरी प्रोफ़ाइल', 'profile kholo', 'meri profile'
    ])) {
      _navigateToProfile();
      speak(_getTTSResponse('opening_profile'));
    }
    else if (_containsAny(cmd, [
      // English
      'open settings', 'show settings', 'settings',
      // Tamil
      'அமைப்புகள் திற', 'அமைப்புகள்', 'amaipugal thira', 'amaipugal',
      // Hindi
      'सेटिंग्स खोलो', 'settings kholo'
    ])) {
      _navigateToSettings();
      speak(_getTTSResponse('opening_settings'));
    }
    else if (_containsAny(cmd, [
      // English
      'go back', 'return', 'previous screen', 'back',
      // Tamil
      'பின்னால் செல்', 'பின்', 'pinnale sel', 'pin',
      // Hindi
      'वापस जाओ', 'पीछे', 'vapas jao', 'piche'
    ])) {
      _goBack();
      speak(_getTTSResponse('going_back'));
    }
    else if (_containsAny(cmd, [
      // English
      'help', 'show commands', 'what can i say', 'voice commands', 'commands',
      // Tamil
      'உதவி', 'கட்டளைகளை காட்டு', 'uthavi', 'kattalaigalai kattu',
      // Hindi
      'मदद', 'कमांड दिखाओ', 'madad', 'command dikhao'
    ])) {
      _showHelp();
      speak(_getTTSResponse('showing_help'));
    }
    else if (_containsAny(cmd, [
      // English
      'refresh', 'reload', 'update',
      // Tamil
      'புதுப்பி', 'puthuppi',
      // Hindi
      'रिफ्रेश', 'refresh'
    ])) {
      speak(_getTTSResponse('refreshing'));
      VoiceCommandEvent.broadcast(VoiceCommand(
        action: VoiceAction.refresh,
      ));
    }
    
    // Issue Type Selection Commands (English + Tamil + Hindi)
    else if (_containsAny(cmd, [
      // English
      'report pothole', 'select pothole', 'pothole',
      // Tamil
      'குழி புகார்', 'குழி', 'kuzhi pugar', 'kuzhi',
      // Hindi
      'गड्ढा रिपोर्ट', 'गड्ढा', 'gaddha report', 'gaddha'
    ])) {
      _selectIssueType('Pothole');
      speak(_getTTSResponse('pothole_selected'));
    }
    else if (_containsAny(cmd, [
      // English
      'report garbage', 'select garbage', 'garbage', 'trash', 'garbage pile',
      // Tamil
      'குப்பை புகார்', 'குப்பை', 'kuppai pugar', 'kuppai',
      // Hindi
      'कचरा रिपोर्ट', 'कचरा', 'kachra report', 'kachra'
    ])) {
      _selectIssueType('Garbage Pile');
      speak(_getTTSResponse('garbage_selected'));
    }
    else if (_containsAny(cmd, [
      // English
      'report streetlight', 'broken light', 'streetlight', 'light not working', 'streetlight broken',
      // Tamil
      'தெரு விளக்கு புகார்', 'விளக்கு', 'teru vilakku pugar', 'vilakku',
      // Hindi
      'स्ट्रीट लाइट रिपोर्ट', 'लाइट', 'street light report', 'light'
    ])) {
      _selectIssueType('Streetlight Broken');
      speak(_getTTSResponse('streetlight_selected'));
    }
    else if (_containsAny(cmd, [
      // English
      'report drainage', 'drainage', 'water overflow', 'drain blocked', 'drainage overflow',
      // Tamil
      'வடிகால் புகார்', 'வடிகால்', 'vadigala pugar', 'vadigala',
      // Hindi
      'नाली रिपोर्ट', 'नाली', 'nali report', 'nali'
    ])) {
      _selectIssueType('Drainage Overflow');
      speak(_getTTSResponse('drainage_selected'));
    }
    else if (_containsAny(cmd, [
      // English
      'water leak', 'pipe leak', 'leaking pipe', 'water leaking',
      // Tamil
      'நீர் கசிவு புகார்', 'நீர் கசிவு', 'neer kasivu pugar', 'neer kasivu',
      // Hindi
      'पानी का रिसाव', 'रिसाव', 'pani ka risav', 'risav'
    ])) {
      _selectIssueType('Water Leak');
      speak(_getTTSResponse('water_leak_selected'));
    }
    else if (_containsAny(cmd, [
      // English
      'road crack', 'cracked road', 'crack',
      // Tamil
      'சாலை விரிசல்', 'விரிசல்', 'salai virisal', 'virisal',
      // Hindi
      'सड़क दरार', 'दरार', 'sadak darar', 'darar'
    ])) {
      _selectIssueType('Road Crack');
      speak(_getTTSResponse('road_crack_selected'));
    }
    
    // Urgency Commands (English + Tamil + Hindi)
    else if (_containsAny(cmd, [
      // English
      'urgent', 'critical', 'emergency', 'very urgent', 'mark critical',
      // Tamil
      'அவசரம்', 'முக்கியம்', 'அவசர', 'avasaram', 'mukkiyam', 'avasar',
      // Hindi
      'जरूरी', 'महत्वपूर्ण', 'आपातकाल', 'jaruri', 'mahatvapurn', 'apatkal'
    ])) {
      _setUrgency('Critical');
      speak(_getTTSResponse('marked_critical'));
    }
    else if (_containsAny(cmd, [
      // English
      'high priority', 'important', 'high urgency', 'set high',
      // Tamil
      'உயர் முன்னுரிமை', 'முக்கிய', 'uyar munnurimai', 'mukkiya',
      // Hindi
      'उच्च प्राथमिकता', 'महत्वपूर्ण', 'uchch prathamikta', 'mahatvapurn'
    ])) {
      _setUrgency('High');
      speak(_getTTSResponse('set_high'));
    }
    else if (_containsAny(cmd, [
      // English
      'medium priority', 'normal', 'medium urgency', 'set medium',
      // Tamil
      'நடுத்தர முன்னுரிமை', 'நடுத்தர', 'naduthara munnurimai', 'naduthara',
      // Hindi
      'मध्यम प्राथमिकता', 'सामान्य', 'madhyam prathamikta', 'samany'
    ])) {
      _setUrgency('Medium');
      speak(_getTTSResponse('set_medium'));
    }
    else if (_containsAny(cmd, [
      // English
      'low priority', 'not urgent', 'low urgency', 'set low',
      // Tamil
      'குறைந்த முன்னுரிமை', 'குறைந்த', 'kurainda munnurimai', 'kurainda',
      // Hindi
      'कम प्राथमिकता', 'कम', 'kam prathamikta', 'kam'
    ])) {
      _setUrgency('Low');
      speak(_getTTSResponse('set_low'));
    }
    
    // Action Commands (English + Tamil + Hindi)
    else if (_containsAny(cmd, [
      // English
      'submit', 'send report', 'submit report', 'send complaint',
      // Tamil
      'சமர்ப்பி', 'புகார் அனுப்ப', 'samarppi', 'pugar anuppa',
      // Hindi
      'जमा करो', 'रिपोर्ट भेजो', 'jama karo', 'report bhejo'
    ])) {
      _submitReport();
      speak(_getTTSResponse('submitting'));
    }
    else if (_containsAny(cmd, [
      // English
      'cancel', 'discard', 'delete', 'cancel report',
      // Tamil
      'ரத்து', 'நீக்க', 'rattu', 'neekka',
      // Hindi
      'रद्द करो', 'हटाओ', 'radd karo', 'hatao'
    ])) {
      _cancelAction();
      speak(_getTTSResponse('cancelled'));
    }
    
    // Description Commands (extract description after keywords)
    else if (cmd.startsWith('add description') || cmd.startsWith('description is') ||
             cmd.startsWith('விளக்கம் சேர்') || cmd.startsWith('விளக்கம்')) {
      final description = cmd
          .replaceFirst('add description', '')
          .replaceFirst('description is', '')
          .replaceFirst('விளக்கம் சேர்', '')
          .replaceFirst('விளக்கம்', '')
          .trim();
      if (description.isNotEmpty) {
        _addDescription(description);
        speak(_getTTSResponse('description_added'));
      }
    }
    
    // Camera Commands (English + Tamil + Hindi)
    else if (_containsAny(cmd, [
      // English
      'take photo', 'capture', 'click', 'snap',
      // Tamil
      'புகைப்படம் எடு', 'படம் எடு', 'pugaippadam edu', 'padam edu',
      // Hindi
      'फोटो लो', 'photo lo'
    ])) {
      VoiceCommandEvent.broadcast(VoiceCommand(
        action: VoiceAction.takePhoto,
      ));
      speak(_getTTSResponse('taking_photo'));
    }
    else if (_containsAny(cmd, [
      // English
      'retake', 'take again', 'retake photo',
      // Tamil
      'மீண்டும் எடு', 'படம் மீண்டும்', 'meendum edu', 'padam meendum',
      // Hindi
      'फिर से लो', 'phir se lo'
    ])) {
      VoiceCommandEvent.broadcast(VoiceCommand(
        action: VoiceAction.retakePhoto,
      ));
      speak(_getTTSResponse('retaking_photo'));
    }
    else if (_containsAny(cmd, [
      // English
      'use this photo', 'confirm photo', 'use photo',
      // Tamil
      'இந்த படத்தை பயன்படுத்து', 'படத்தை உறுதி', 'inda padathai payanpaduthu', 'padathai uruthi',
      // Hindi
      'इस फोटो का उपयोग करो', 'फोटो पुष्टि करो', 'is photo ka upyog karo', 'photo pushti karo'
    ])) {
      VoiceCommandEvent.broadcast(VoiceCommand(
        action: VoiceAction.confirmPhoto,
      ));
      speak(_getTTSResponse('photo_confirmed'));
    }
    
    // Filter Commands (for reports screen) - English + Tamil + Hindi
    else if (_containsAny(cmd, [
      // English
      'show pending', 'filter pending', 'pending reports', 'pending',
      // Tamil
      'நிலுவையில் காட்டு', 'நிலுவை', 'niluvaiyil kattu', 'niluvai',
      // Hindi
      'लंबित दिखाओ', 'lambit dikhao'
    ])) {
      _filterReports('reported');
      speak(_getTTSResponse('showing_pending'));
    }
    else if (_containsAny(cmd, [
      // English
      'show resolved', 'filter resolved', 'completed reports', 'resolved',
      // Tamil
      'தீர்க்கப்பட்டவை காட்டு', 'தீர்க்கப்பட்ட', 'theerkkappattavai kattu', 'theerkkappatta',
      // Hindi
      'हल की गई दिखाओ', 'hal ki gayi dikhao'
    ])) {
      _filterReports('resolved');
      speak(_getTTSResponse('showing_resolved'));
    }
    else if (_containsAny(cmd, [
      // English
      'show in progress', 'filter in progress', 'in progress',
      // Tamil
      'நடைபெறும் காட்டு', 'நடைபெறும்', 'nadaiberum kattu', 'nadaiberum',
      // Hindi
      'प्रगति में दिखाओ', 'pragati mein dikhao'
    ])) {
      _filterReports('in_progress');
      speak(_getTTSResponse('showing_in_progress'));
    }
    else if (_containsAny(cmd, [
      // English
      'show all', 'all reports', 'clear filter',
      // Tamil
      'அனைத்தையும் காட்டு', 'அனைத்தும்', 'anaithaiyum kattu', 'anaithum',
      // Hindi
      'सभी दिखाओ', 'sabhi dikhao'
    ])) {
      _filterReports('all');
      speak(_getTTSResponse('showing_all'));
    }
    
    // Profile/Settings Commands (English + Tamil + Hindi)
    else if (cmd.startsWith('change name to') || cmd.startsWith('பெயர் மாற்ற') || cmd.startsWith('peyar maarra')) {
      final name = cmd
          .replaceFirst('change name to', '')
          .replaceFirst('பெயர் மாற்ற', '')
          .replaceFirst('peyar maarra', '')
          .trim();
      if (name.isNotEmpty) {
        _updateName(name);
        speak('${_getTTSResponse('name_changed')} $name');
      }
    }
    else if (cmd.startsWith('change phone to') || cmd.startsWith('தொலைபேசி மாற்ற') || cmd.startsWith('tholaipesi maarra')) {
      final phone = cmd
          .replaceFirst('change phone to', '')
          .replaceFirst('தொலைபேசி மாற்ற', '')
          .replaceFirst('tholaipesi maarra', '')
          .trim();
      if (phone.isNotEmpty) {
        _updatePhone(phone);
        speak('${_getTTSResponse('phone_updated')} $phone');
      }
    }
    else if (_containsAny(cmd, [
      // English
      'enable notifications', 'turn on notifications',
      // Tamil
      'அறிவிப்புகள் இயக்கு', 'arivippugal iyakku',
      // Hindi
      'सूचनाएं सक्षम करो', 'suchnayen saksham karo'
    ])) {
      VoiceCommandEvent.broadcast(VoiceCommand(
        action: VoiceAction.enableNotifications,
      ));
      speak(_getTTSResponse('notifications_enabled'));
    }
    else if (_containsAny(cmd, [
      // English
      'disable notifications', 'turn off notifications',
      // Tamil
      'அறிவிப்புகள் முடக்கு', 'arivippugal mudakku',
      // Hindi
      'सूचनाएं अक्षम करो', 'suchnayen aksham karo'
    ])) {
      VoiceCommandEvent.broadcast(VoiceCommand(
        action: VoiceAction.disableNotifications,
      ));
      speak(_getTTSResponse('notifications_disabled'));
    }
    else if (_containsAny(cmd, [
      // English
      'logout', 'sign out', 'log out',
      // Tamil
      'வெளியேறு', 'veliyeru',
      // Hindi
      'लॉग आउट', 'log out'
    ])) {
      _logout();
      speak(_getTTSResponse('logging_out'));
    }
    
    // List Navigation Commands (English + Tamil + Hindi)
    else if (_containsAny(cmd, [
      // English
      'open first', 'first report', 'open first report',
      // Tamil
      'முதல் புகார் திற', 'முதல்', 'mudhal pugar thira', 'mudhal',
      // Hindi
      'पहली रिपोर्ट खोलो', 'pehli report kholo'
    ])) {
      VoiceCommandEvent.broadcast(VoiceCommand(
        action: VoiceAction.openReportAtIndex,
        data: 0,
      ));
      speak(_getTTSResponse('opening_first'));
    }
    else if (_containsAny(cmd, [
      // English
      'open second', 'second report',
      // Tamil
      'இரண்டாவது புகார்', 'இரண்டாவது', 'irandavathu pugar', 'irandavathu',
      // Hindi
      'दूसरी रिपोर्ट', 'dusri report'
    ])) {
      VoiceCommandEvent.broadcast(VoiceCommand(
        action: VoiceAction.openReportAtIndex,
        data: 1,
      ));
      speak(_getTTSResponse('opening_second'));
    }
    else if (_containsAny(cmd, [
      // English
      'open third', 'third report',
      // Tamil
      'மூன்றாவது புகார்', 'மூன்றாவது', 'munravathu pugar', 'munravathu',
      // Hindi
      'तीसरी रिपोर्ट', 'tisri report'
    ])) {
      VoiceCommandEvent.broadcast(VoiceCommand(
        action: VoiceAction.openReportAtIndex,
        data: 2,
      ));
      speak(_getTTSResponse('opening_third'));
    }
    else if (_containsAny(cmd, [
      // English
      'scroll down', 'next page', 'scroll',
      // Tamil
      'கீழே உருட்டு', 'கீழே', 'keezhe uruttu', 'keezhe',
      // Hindi
      'नीचे स्क्रॉल', 'niche scroll'
    ])) {
      VoiceCommandEvent.broadcast(VoiceCommand(
        action: VoiceAction.scrollDown,
      ));
      speak(_getTTSResponse('scrolling_down'));
    }
    
    // Screen Reading (English + Tamil + Hindi)
    else if (_containsAny(cmd, [
      // English
      "what's on screen", 'read screen', 'what can i see',
      // Tamil
      'திரையில் என்ன இருக்கிறது', 'திரையைப் படி', 'thiraiyil enna irukkirathu', 'thiraiyai padi',
      // Hindi
      'स्क्रीन पर क्या है', 'स्क्रीन पढ़ो', 'screen par kya hai', 'screen padho'
    ])) {
      VoiceCommandEvent.broadcast(VoiceCommand(
        action: VoiceAction.readScreen,
      ));
    }
    
    // Language Switching Commands
    else if (_containsAny(cmd, [
      // English
      'set language to english', 'switch to english', 'english language',
      // Tamil
      'மொழியை ஆங்கிலத்திற்கு மாற்று', 'ஆங்கிலத்திற்கு மாறு', 'moliya angilathirku maarru', 'angilathirku maru',
      // Hindi
      'भाषा अंग्रेजी पर सेट करो', 'अंग्रेजी पर स्विच करो', 'bhasha angrezi par set karo', 'angrezi par switch karo'
    ])) {
      setLanguage('en-IN');
    }
    else if (_containsAny(cmd, [
      // English
      'set language to hindi', 'switch to hindi', 'hindi language',
      // Tamil
      'மொழியை இந்திக்கு மாற்று', 'இந்திக்கு மாறு', 'moliya indikku maarru', 'indikku maru',
      // Hindi
      'भाषा हिंदी पर सेट करो', 'हिंदी पर स्विच करो', 'bhasha hindi par set karo', 'hindi par switch karo'
    ])) {
      setLanguage('hi-IN');
    }
    else if (_containsAny(cmd, [
      // English
      'set language to tamil', 'switch to tamil', 'tamil language',
      // Tamil
      'மொழியை தமிழுக்கு மாற்று', 'தமிழுக்கு மாறு', 'moliya thamilukku maarru', 'thamilukku maru',
      // Hindi
      'भाषा तमिल पर सेट करो', 'तमिल पर स्विच करो', 'bhasha tamil par set karo', 'tamil par switch karo'
    ])) {
      setLanguage('ta-IN');
    }
    
    // Unknown command
    else {
      speak(_getTTSResponse('not_understood'));
    }

    // Auto-restart listening after processing (only in continuous mode)
    if (isContinuous ?? false) {
      VoiceSettingsService.getVoiceMode().then((mode) {
        // Double-check mode is still continuous before auto-restarting
        if (mode == 'continuous' && isContinuous == true) {
          Future.delayed(const Duration(seconds: 2), () {
            if (!_isListening && _context != null) {
              // Verify mode one more time before restarting
              VoiceSettingsService.getVoiceMode().then((currentMode) {
                if (currentMode == 'continuous') {
                  startListening(isContinuous: true);
                } else {
                  print('⚠️ Mode changed to $currentMode, not auto-restarting');
                }
              });
            }
          });
        } else {
          print('⚠️ Not in continuous mode ($mode), not auto-restarting');
        }
      });
    }
  }
  
  /// Check if continuous mode is enabled
  Future<bool> isContinuousMode() async {
    final mode = await VoiceSettingsService.getVoiceMode();
    return mode == 'continuous';
  }
  
  /// Start continuous listening (if enabled in settings)
  Future<void> startContinuousListening() async {
    final mode = await VoiceSettingsService.getVoiceMode();
    final autoStart = await VoiceSettingsService.isAutoStartEnabled();
    
    if (mode == 'continuous' && autoStart) {
      if (_context == null) {
        throw Exception('No context set');
      }
      setContext(_context!);
      await startListening(isContinuous: true);
    }
  }

  // Navigation methods
  void _navigateToHome() {
    if (_context != null && Navigator.of(_context!).canPop()) {
      Navigator.of(_context!).popUntil((route) => route.isFirst);
    }
  }

  void _navigateToCamera() {
    if (_context != null) {
      Navigator.of(_context!).pushNamed('/capture');
    }
  }

  void _navigateToReports() {
    if (_context != null) {
      Navigator.of(_context!).pushNamed('/history');
    }
  }

  void _navigateToProfile() {
    if (_context != null) {
      Navigator.of(_context!).pushNamed('/profile');
    }
  }

  void _navigateToSettings() {
    if (_context != null) {
      Navigator.of(_context!).pushNamed('/settings');
    }
  }

  void _goBack() {
    if (_context != null && Navigator.of(_context!).canPop()) {
      Navigator.of(_context!).pop();
    } else {
      speak("Cannot go back");
    }
  }

  void _showHelp() {
    if (_context != null) {
      Navigator.of(_context!).pushNamed('/voice-help');
    }
  }

  // Action methods - broadcast events
  void _selectIssueType(String type) {
    VoiceCommandEvent.broadcast(VoiceCommand(
      action: VoiceAction.selectIssueType,
      data: type,
    ));
  }

  void _setUrgency(String urgency) {
    VoiceCommandEvent.broadcast(VoiceCommand(
      action: VoiceAction.setUrgency,
      data: urgency,
    ));
  }

  void _submitReport() {
    VoiceCommandEvent.broadcast(VoiceCommand(
      action: VoiceAction.submitReport,
    ));
  }

  void _cancelAction() {
    VoiceCommandEvent.broadcast(VoiceCommand(
      action: VoiceAction.cancel,
    ));
  }

  void _addDescription(String description) {
    VoiceCommandEvent.broadcast(VoiceCommand(
      action: VoiceAction.addDescription,
      data: description,
    ));
  }

  void _filterReports(String filter) {
    VoiceCommandEvent.broadcast(VoiceCommand(
      action: VoiceAction.filterReports,
      data: filter,
    ));
  }

  void _updateName(String name) {
    VoiceCommandEvent.broadcast(VoiceCommand(
      action: VoiceAction.updateName,
      data: name,
    ));
  }

  void _updatePhone(String phone) {
    VoiceCommandEvent.broadcast(VoiceCommand(
      action: VoiceAction.updatePhone,
      data: phone,
    ));
  }

  void _logout() {
    VoiceCommandEvent.broadcast(VoiceCommand(
      action: VoiceAction.logout,
    ));
  }

  /// Check if text contains any of the keywords
  /// This function is flexible and works with variations:
  /// - "I want to report a pothole" will match "pothole"
  /// - "Please open the camera for me" will match "open camera"
  /// - "Can you take me home" will match "go home"
  /// The matching is case-insensitive and looks for keywords anywhere in the sentence
  bool _containsAny(String text, List<String> keywords) {
    final lowerText = text.toLowerCase();
    return keywords.any((keyword) => lowerText.contains(keyword.toLowerCase()));
  }

  /// Dispose resources
  void dispose() {
    _speech.stop();
    _tts.stop();
  }
}

