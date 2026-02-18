import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/voice_controller_service.dart';

/// Comprehensive Voice Command Help Screen
/// Shows all available voice commands across the entire app
/// Dynamically shows commands in the selected language
class VoiceCommandHelpScreen extends StatefulWidget {
  const VoiceCommandHelpScreen({Key? key}) : super(key: key);

  @override
  State<VoiceCommandHelpScreen> createState() => _VoiceCommandHelpScreenState();
}

class _VoiceCommandHelpScreenState extends State<VoiceCommandHelpScreen> {
  final _voiceController = VoiceControllerService();
  String get _currentLanguage => _voiceController.currentLanguage;

  // Get commands based on current language
  Map<String, List<_CommandItem>> _getCommandsForLanguage(String lang) {
    if (lang == 'ta-IN') {
      return _getTamilCommands();
    } else if (lang == 'hi-IN') {
      return _getHindiCommands();
    } else {
      return _getEnglishCommands();
    }
  }

  Map<String, List<_CommandItem>> _getEnglishCommands() {
    return {
      'navigation': [
        _CommandItem(command: 'Go Home', variations: ['go home', 'take me home', 'home screen', 'home']),
        _CommandItem(command: 'Open Camera', variations: ['open camera', 'take photo', 'capture photo', 'camera']),
        _CommandItem(command: 'Show Reports', variations: ['show reports', 'my reports', 'view complaints', 'show history', 'reports']),
        _CommandItem(command: 'Open Profile', variations: ['open profile', 'my profile', 'show profile', 'profile']),
        _CommandItem(command: 'Go Back', variations: ['go back', 'return', 'previous screen', 'back']),
        _CommandItem(command: 'Refresh', variations: ['refresh', 'reload', 'update']),
      ],
      'issues': [
        _CommandItem(command: 'Pothole', variations: ['report pothole', 'select pothole', 'pothole']),
        _CommandItem(command: 'Garbage Pile', variations: ['report garbage', 'select garbage', 'garbage', 'trash', 'garbage pile']),
        _CommandItem(command: 'Streetlight Broken', variations: ['report streetlight', 'broken light', 'streetlight', 'light not working', 'streetlight broken']),
        _CommandItem(command: 'Drainage Overflow', variations: ['report drainage', 'drainage', 'water overflow', 'drain blocked', 'drainage overflow']),
        _CommandItem(command: 'Water Leak', variations: ['water leak', 'pipe leak', 'leaking pipe', 'water leaking']),
        _CommandItem(command: 'Road Crack', variations: ['road crack', 'cracked road', 'crack']),
      ],
      'urgency': [
        _CommandItem(command: 'Critical', variations: ['urgent', 'critical', 'emergency', 'very urgent', 'mark critical']),
        _CommandItem(command: 'High Priority', variations: ['high priority', 'important', 'high urgency', 'set high']),
        _CommandItem(command: 'Medium Priority', variations: ['medium priority', 'normal', 'medium urgency', 'set medium']),
        _CommandItem(command: 'Low Priority', variations: ['low priority', 'not urgent', 'low urgency', 'set low']),
      ],
      'camera': [
        _CommandItem(command: 'Take Photo', variations: ['take photo', 'capture', 'click', 'snap']),
        _CommandItem(command: 'Retake Photo', variations: ['retake', 'take again', 'retake photo']),
        _CommandItem(command: 'Confirm Photo', variations: ['use this photo', 'confirm photo', 'use photo']),
      ],
      'actions': [
        _CommandItem(command: 'Submit Report', variations: ['submit', 'send report', 'submit report', 'send complaint']),
        _CommandItem(command: 'Cancel', variations: ['cancel', 'discard', 'delete', 'cancel report']),
        _CommandItem(command: 'Add Description', variations: ['add description [text]', 'description is [text]']),
      ],
      'reports': [
        _CommandItem(command: 'Show Pending', variations: ['show pending', 'filter pending', 'pending reports', 'pending']),
        _CommandItem(command: 'Show In Progress', variations: ['show in progress', 'filter in progress', 'in progress']),
        _CommandItem(command: 'Show Resolved', variations: ['show resolved', 'filter resolved', 'completed reports', 'resolved']),
        _CommandItem(command: 'Show All', variations: ['show all', 'all reports', 'clear filter']),
        _CommandItem(command: 'Scroll Down', variations: ['scroll down', 'next page', 'scroll']),
        _CommandItem(command: 'Open First Report', variations: ['open first', 'first report', 'open first report']),
      ],
      'profile': [
        _CommandItem(command: 'Change Name', variations: ['change name to [name]']),
        _CommandItem(command: 'Change Phone', variations: ['change phone to [number]']),
        _CommandItem(command: 'Enable Notifications', variations: ['enable notifications', 'turn on notifications']),
        _CommandItem(command: 'Disable Notifications', variations: ['disable notifications', 'turn off notifications']),
        _CommandItem(command: 'Logout', variations: ['logout', 'sign out', 'log out']),
      ],
    };
  }

  Map<String, List<_CommandItem>> _getTamilCommands() {
    return {
      'navigation': [
        _CommandItem(command: 'வீட்டிற்கு செல்', variations: ['வீட்டிற்கு செல்', 'வீட்டிற்கு', 'வீடு', 'veettirku sel', 'veettirku', 'veedu']),
        _CommandItem(command: 'கேமரா திற', variations: ['கேமரா திற', 'கேமரா', 'புகைப்படம் எடு', 'camera thira', 'camera', 'pugaippadam edu']),
        _CommandItem(command: 'புகார்களை காட்டு', variations: ['புகார்களை காட்டு', 'புகார்கள்', 'pugargalai kattu', 'pugargal']),
        _CommandItem(command: 'சுயவிவரம் திற', variations: ['சுயவிவரம் திற', 'சுயவிவரம்', 'suyavivaram thira', 'suyavivaram']),
        _CommandItem(command: 'பின்னால் செல்', variations: ['பின்னால் செல்', 'பின்', 'pinnale sel', 'pin']),
        _CommandItem(command: 'புதுப்பி', variations: ['புதுப்பி', 'puthuppi']),
      ],
      'issues': [
        _CommandItem(command: 'குழி', variations: ['குழி புகார்', 'குழி', 'kuzhi pugar', 'kuzhi']),
        _CommandItem(command: 'குப்பை', variations: ['குப்பை புகார்', 'குப்பை', 'kuppai pugar', 'kuppai']),
        _CommandItem(command: 'தெரு விளக்கு', variations: ['தெரு விளக்கு புகார்', 'விளக்கு', 'teru vilakku pugar', 'vilakku']),
        _CommandItem(command: 'வடிகால்', variations: ['வடிகால் புகார்', 'வடிகால்', 'vadigala pugar', 'vadigala']),
        _CommandItem(command: 'நீர் கசிவு', variations: ['நீர் கசிவு புகார்', 'நீர் கசிவு', 'neer kasivu pugar', 'neer kasivu']),
        _CommandItem(command: 'சாலை விரிசல்', variations: ['சாலை விரிசல்', 'விரிசல்', 'salai virisal', 'virisal']),
      ],
      'urgency': [
        _CommandItem(command: 'அவசரம்', variations: ['அவசரம்', 'முக்கியம்', 'அவசர', 'avasaram', 'mukkiyam', 'avasar']),
        _CommandItem(command: 'உயர் முன்னுரிமை', variations: ['உயர் முன்னுரிமை', 'முக்கிய', 'uyar munnurimai', 'mukkiya']),
        _CommandItem(command: 'நடுத்தர முன்னுரிமை', variations: ['நடுத்தர முன்னுரிமை', 'நடுத்தர', 'naduthara munnurimai', 'naduthara']),
        _CommandItem(command: 'குறைந்த முன்னுரிமை', variations: ['குறைந்த முன்னுரிமை', 'குறைந்த', 'kurainda munnurimai', 'kurainda']),
      ],
      'camera': [
        _CommandItem(command: 'புகைப்படம் எடு', variations: ['புகைப்படம் எடு', 'படம் எடு', 'pugaippadam edu', 'padam edu']),
        _CommandItem(command: 'மீண்டும் எடு', variations: ['மீண்டும் எடு', 'படம் மீண்டும்', 'meendum edu', 'padam meendum']),
        _CommandItem(command: 'படத்தை உறுதி', variations: ['இந்த படத்தை பயன்படுத்து', 'படத்தை உறுதி', 'inda padathai payanpaduthu', 'padathai uruthi']),
      ],
      'actions': [
        _CommandItem(command: 'சமர்ப்பி', variations: ['சமர்ப்பி', 'புகார் அனுப்ப', 'samarppi', 'pugar anuppa']),
        _CommandItem(command: 'ரத்து', variations: ['ரத்து', 'நீக்க', 'rattu', 'neekka']),
        _CommandItem(command: 'விளக்கம் சேர்', variations: ['விளக்கம் சேர்', 'விளக்கம் [உரை]', 'vilakkam ser', 'vilakkam']),
      ],
      'reports': [
        _CommandItem(command: 'நிலுவையில் காட்டு', variations: ['நிலுவையில் காட்டு', 'நிலுவை', 'niluvaiyil kattu', 'niluvai']),
        _CommandItem(command: 'நடைபெறும் காட்டு', variations: ['நடைபெறும் காட்டு', 'நடைபெறும்', 'nadaiberum kattu', 'nadaiberum']),
        _CommandItem(command: 'தீர்க்கப்பட்டவை காட்டு', variations: ['தீர்க்கப்பட்டவை காட்டு', 'தீர்க்கப்பட்ட', 'theerkkappattavai kattu', 'theerkkappatta']),
        _CommandItem(command: 'அனைத்தையும் காட்டு', variations: ['அனைத்தையும் காட்டு', 'அனைத்தும்', 'anaithaiyum kattu', 'anaithum']),
        _CommandItem(command: 'கீழே உருட்டு', variations: ['கீழே உருட்டு', 'கீழே', 'keezhe uruttu', 'keezhe']),
        _CommandItem(command: 'முதல் புகார் திற', variations: ['முதல் புகார் திற', 'முதல்', 'mudhal pugar thira', 'mudhal']),
      ],
      'profile': [
        _CommandItem(command: 'பெயர் மாற்ற', variations: ['பெயர் மாற்ற [பெயர்]', 'peyar maarra']),
        _CommandItem(command: 'தொலைபேசி மாற்ற', variations: ['தொலைபேசி மாற்ற [எண்]', 'tholaipesi maarra']),
        _CommandItem(command: 'அறிவிப்புகள் இயக்கு', variations: ['அறிவிப்புகள் இயக்கு', 'arivippugal iyakku']),
        _CommandItem(command: 'அறிவிப்புகள் முடக்கு', variations: ['அறிவிப்புகள் முடக்கு', 'arivippugal mudakku']),
        _CommandItem(command: 'வெளியேறு', variations: ['வெளியேறு', 'veliyeru']),
      ],
    };
  }

  Map<String, List<_CommandItem>> _getHindiCommands() {
    return {
      'navigation': [
        _CommandItem(command: 'घर जाओ', variations: ['घर जाओ', 'होम', 'ghar jao', 'home']),
        _CommandItem(command: 'कैमरा खोलो', variations: ['कैमरा खोलो', 'फोटो लो', 'camera kholo', 'photo lo']),
        _CommandItem(command: 'रिपोर्ट दिखाओ', variations: ['रिपोर्ट दिखाओ', 'मेरी रिपोर्ट', 'report dikhao', 'meri report']),
        _CommandItem(command: 'प्रोफ़ाइल खोलो', variations: ['प्रोफ़ाइल खोलो', 'मेरी प्रोफ़ाइल', 'profile kholo', 'meri profile']),
        _CommandItem(command: 'वापस जाओ', variations: ['वापस जाओ', 'पीछे', 'vapas jao', 'piche']),
        _CommandItem(command: 'रिफ्रेश', variations: ['रिफ्रेश', 'refresh']),
      ],
      'issues': [
        _CommandItem(command: 'गड्ढा', variations: ['गड्ढा रिपोर्ट', 'गड्ढा', 'gaddha report', 'gaddha']),
        _CommandItem(command: 'कचरा', variations: ['कचरा रिपोर्ट', 'कचरा', 'kachra report', 'kachra']),
        _CommandItem(command: 'स्ट्रीट लाइट', variations: ['स्ट्रीट लाइट रिपोर्ट', 'लाइट', 'street light report', 'light']),
        _CommandItem(command: 'नाली', variations: ['नाली रिपोर्ट', 'नाली', 'nali report', 'nali']),
        _CommandItem(command: 'पानी का रिसाव', variations: ['पानी का रिसाव', 'रिसाव', 'pani ka risav', 'risav']),
        _CommandItem(command: 'सड़क दरार', variations: ['सड़क दरार', 'दरार', 'sadak darar', 'darar']),
      ],
      'urgency': [
        _CommandItem(command: 'अत्यावश्यक', variations: ['जरूरी', 'महत्वपूर्ण', 'आपातकाल', 'jaruri', 'mahatvapurn', 'apatkal']),
        _CommandItem(command: 'उच्च प्राथमिकता', variations: ['उच्च प्राथमिकता', 'महत्वपूर्ण', 'uchch prathamikta', 'mahatvapurn']),
        _CommandItem(command: 'मध्यम प्राथमिकता', variations: ['मध्यम प्राथमिकता', 'सामान्य', 'madhyam prathamikta', 'samany']),
        _CommandItem(command: 'कम प्राथमिकता', variations: ['कम प्राथमिकता', 'कम', 'kam prathamikta', 'kam']),
      ],
      'camera': [
        _CommandItem(command: 'फोटो लो', variations: ['फोटो लो', 'photo lo']),
        _CommandItem(command: 'फिर से लो', variations: ['फिर से लो', 'phir se lo']),
        _CommandItem(command: 'फोटो पुष्टि करो', variations: ['इस फोटो का उपयोग करो', 'फोटो पुष्टि करो', 'is photo ka upyog karo', 'photo pushti karo']),
      ],
      'actions': [
        _CommandItem(command: 'जमा करो', variations: ['जमा करो', 'रिपोर्ट भेजो', 'jama karo', 'report bhejo']),
        _CommandItem(command: 'रद्द करो', variations: ['रद्द करो', 'हटाओ', 'radd karo', 'hatao']),
        _CommandItem(command: 'विवरण जोड़ो', variations: ['विवरण जोड़ो [पाठ]', 'vivaran jodo']),
      ],
      'reports': [
        _CommandItem(command: 'लंबित दिखाओ', variations: ['लंबित दिखाओ', 'lambit dikhao']),
        _CommandItem(command: 'प्रगति में दिखाओ', variations: ['प्रगति में दिखाओ', 'pragati mein dikhao']),
        _CommandItem(command: 'हल की गई दिखाओ', variations: ['हल की गई दिखाओ', 'hal ki gayi dikhao']),
        _CommandItem(command: 'सभी दिखाओ', variations: ['सभी दिखाओ', 'sabhi dikhao']),
        _CommandItem(command: 'नीचे स्क्रॉल', variations: ['नीचे स्क्रॉल', 'niche scroll']),
        _CommandItem(command: 'पहली रिपोर्ट', variations: ['पहली रिपोर्ट', 'pehli report']),
      ],
      'profile': [
        _CommandItem(command: 'नाम बदलो', variations: ['नाम बदलो [नाम]', 'nam badlo']),
        _CommandItem(command: 'फोन बदलो', variations: ['फोन बदलो [नंबर]', 'phone badlo']),
        _CommandItem(command: 'सूचनाएं सक्षम करो', variations: ['सूचनाएं सक्षम करो', 'suchnayen saksham karo']),
        _CommandItem(command: 'सूचनाएं अक्षम करो', variations: ['सूचनाएं अक्षम करो', 'suchnayen aksham karo']),
        _CommandItem(command: 'लॉग आउट', variations: ['लॉग आउट', 'log out']),
      ],
    };
  }

  String _getTitle(String lang) {
    switch (lang) {
      case 'ta-IN':
        return 'குரல் கட்டளைகள் உதவி';
      case 'hi-IN':
        return 'वॉयस कमांड सहायता';
      default:
        return 'Voice Commands Help';
    }
  }

  String _getSubtitle(String lang) {
    switch (lang) {
      case 'ta-IN':
        return 'உங்கள் முழு பயன்பாட்டையும் குரல் கட்டளைகளுடன் கட்டுப்படுத்தவும்';
      case 'hi-IN':
        return 'वॉयस कमांड के साथ अपने पूरे ऐप को नियंत्रित करें';
      default:
        return 'Control your entire app with voice commands';
    }
  }

  @override
  Widget build(BuildContext context) {
    final commands = _getCommandsForLanguage(_currentLanguage);
    final isTamil = _currentLanguage == 'ta-IN';
    final isHindi = _currentLanguage == 'hi-IN';

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentLanguage)),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Card(
            color: AppColors.primaryBlue.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.mic,
                    size: 48,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTamil ? 'முழு குரல் கட்டுப்பாடு' : (isHindi ? 'पूर्ण वॉयस नियंत्रण' : 'Complete Voice Control'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getSubtitle(_currentLanguage),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Global Navigation Commands
          _buildCommandSection(
            title: isTamil ? '🌐 உலகளாவிய வழிசெலுத்தல்' : (isHindi ? '🌐 वैश्विक नेविगेशन' : '🌐 Global Navigation'),
            icon: Icons.navigation,
            color: AppColors.primaryBlue,
            commands: commands['navigation']!,
          ),
          
          const SizedBox(height: 16),
          
          // Report Issue Commands
          _buildCommandSection(
            title: isTamil ? '📝 பிரச்சனை வகைகளைப் புகாரளிக்கவும்' : (isHindi ? '📝 समस्या प्रकार रिपोर्ट करें' : '📝 Report Issue Types'),
            icon: Icons.report_problem,
            color: AppColors.primaryRed,
            commands: commands['issues']!,
          ),
          
          const SizedBox(height: 16),
          
          // Urgency Commands
          _buildCommandSection(
            title: isTamil ? '⚡ அவசரத்தை அமைக்கவும்' : (isHindi ? '⚡ तात्कालिकता सेट करें' : '⚡ Set Urgency'),
            icon: Icons.priority_high,
            color: AppColors.primaryOrange,
            commands: commands['urgency']!,
          ),
          
          const SizedBox(height: 16),
          
          // Camera Commands
          _buildCommandSection(
            title: isTamil ? '📷 கேமரா கட்டுப்பாடு' : (isHindi ? '📷 कैमरा नियंत्रण' : '📷 Camera Control'),
            icon: Icons.camera_alt,
            color: AppColors.primaryPurple,
            commands: commands['camera']!,
          ),
          
          const SizedBox(height: 16),
          
          // Action Commands
          _buildCommandSection(
            title: isTamil ? '✅ செயல்கள்' : (isHindi ? '✅ कार्रवाई' : '✅ Actions'),
            icon: Icons.check_circle,
            color: AppColors.primaryGreen,
            commands: commands['actions']!,
          ),
          
          const SizedBox(height: 16),
          
          // Reports Screen Commands
          _buildCommandSection(
            title: isTamil ? '📋 புகார்களைக் காண்க' : (isHindi ? '📋 रिपोर्ट देखें' : '📋 View Reports'),
            icon: Icons.list,
            color: AppColors.primaryBlue,
            commands: commands['reports']!,
          ),
          
          const SizedBox(height: 16),
          
          // Profile/Settings Commands
          _buildCommandSection(
            title: isTamil ? '👤 சுயவிவரம் மற்றும் அமைப்புகள்' : (isHindi ? '👤 प्रोफ़ाइल और सेटिंग्स' : '👤 Profile & Settings'),
            icon: Icons.person,
            color: AppColors.primaryPurple,
            commands: commands['profile']!,
          ),
          
          const SizedBox(height: 16),
          
          // Language Switching Commands
          _buildCommandSection(
            title: isTamil ? '🌍 மொழி மாற்றம்' : (isHindi ? '🌍 भाषा बदलें' : '🌍 Language Switching'),
            icon: Icons.language,
            color: Colors.teal,
            commands: [
              _CommandItem(
                command: isTamil ? 'ஆங்கிலத்திற்கு மாற்று' : (isHindi ? 'अंग्रेजी पर स्विच करें' : 'Switch to English'),
                variations: isTamil 
                  ? ['மொழியை ஆங்கிலத்திற்கு மாற்று', 'ஆங்கிலத்திற்கு மாறு', 'moliya angilathirku maarru', 'angilathirku maru']
                  : (isHindi ? ['भाषा अंग्रेजी पर सेट करो', 'अंग्रेजी पर स्विच करो', 'bhasha angrezi par set karo', 'angrezi par switch karo']
                  : ['set language to english', 'switch to english', 'english language']),
              ),
              _CommandItem(
                command: isTamil ? 'இந்திக்கு மாற்று' : (isHindi ? 'हिंदी पर स्विच करें' : 'Switch to Hindi'),
                variations: isTamil
                  ? ['மொழியை இந்திக்கு மாற்று', 'இந்திக்கு மாறு', 'moliya indikku maarru', 'indikku maru']
                  : (isHindi ? ['भाषा हिंदी पर सेट करो', 'हिंदी पर स्विच करो', 'bhasha hindi par set karo', 'hindi par switch karo']
                  : ['set language to hindi', 'switch to hindi', 'hindi language']),
              ),
              _CommandItem(
                command: isTamil ? 'தமிழுக்கு மாற்று' : (isHindi ? 'तमिल पर स्विच करें' : 'Switch to Tamil'),
                variations: isTamil
                  ? ['மொழியை தமிழுக்கு மாற்று', 'தமிழுக்கு மாறு', 'moliya thamilukku maarru', 'thamilukku maru']
                  : (isHindi ? ['भाषा तमिल पर सेट करो', 'तमिल पर स्विच करो', 'bhasha tamil par set karo', 'tamil par switch karo']
                  : ['set language to tamil', 'switch to tamil', 'tamil language']),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Tips
          Card(
            color: AppColors.primaryGreen.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isTamil ? 'நிபுணர் குறிப்புகள்' : (isHindi ? 'विशेषज्ञ युक्तियाँ' : 'Pro Tips'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip(isTamil ? '🎤 குரல் கட்டுப்பாட்டைத் தொடங்க மிதக்கும் மைக் பொத்தானைத் தட்டவும்' : (isHindi ? '🎤 वॉयस कंट्रोल शुरू करने के लिए फ्लोटिंग माइक बटन पर टैप करें' : '🎤 Tap the floating mic button to start voice control')),
                  _buildTip(isTamil ? '🔊 பயன்பாடு உங்கள் கட்டளைகளை உறுதிப்படுத்த பேசும்' : (isHindi ? '🔊 ऐप आपके कमांड की पुष्टि करने के लिए बोलेगा' : '🔊 The app will speak back to confirm your commands')),
                  _buildTip(isTamil ? '🌍 கட்டளைகள் ஆங்கிலம், இந்தி மற்றும் தமிழில் வேலை செய்கின்றன' : (isHindi ? '🌍 कमांड अंग्रेजी, हिंदी और तमिल में काम करते हैं' : '🌍 Commands work in English, Hindi, and Tamil')),
                  _buildTip(isTamil ? '✅ நம்பிக்கை மதிப்பெண் அங்கீகார துல்லியத்தைக் காட்டுகிறது (பச்சை = நல்லது)' : (isHindi ? '✅ आत्मविश्वास स्कोर मान्यता सटीकता दिखाता है (हरा = अच्छा)' : '✅ Confidence score shows recognition accuracy (green = good)')),
                  _buildTip(isTamil ? '🔄 குரல் கட்டுப்பாடு ஒவ்வொரு கட்டளையின் பிறகும் தானாக மீண்டும் தொடங்கும்' : (isHindi ? '🔄 वॉयस कंट्रोल प्रत्येक कमांड के बाद स्वचालित रूप से पुनः आरंभ होता है' : '🔄 Voice control auto-restarts after each command')),
                  _buildTip(isTamil ? '📱 கைகளில்லாமல் வேலை செய்கிறது - அணுகலுக்கு சிறந்தது' : (isHindi ? '📱 हाथों से मुक्त काम करता है - पहुंच के लिए एकदम सही' : '📱 Works hands-free - perfect for accessibility')),
                  _buildTip(isTamil ? '🔇 இந்த திரையைக் காண "உதவி" என்று எப்போதும் சொல்லவும்' : (isHindi ? '🔇 इस स्क्रीन को देखने के लिए कभी भी "मदद" कहें' : '🔇 Say "help" anytime to see this screen')),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // How to Use
          Card(
            color: AppColors.primaryOrange.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primaryOrange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isTamil ? 'எவ்வாறு பயன்படுத்துவது' : (isHindi ? 'कैसे उपयोग करें' : 'How to Use'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip(isTamil ? '1. மிதக்கும் நீல மைக் பொத்தானைத் தட்டவும்' : (isHindi ? '1. फ्लोटिंग नीले माइक बटन पर टैप करें' : '1. Tap the floating blue mic button')),
                  _buildTip(isTamil ? '2. "கேட்கிறது..." குறிகாட்டிக்காக காத்திருக்கவும்' : (isHindi ? '2. "सुन रहा है..." संकेतक के लिए प्रतीक्षा करें' : '2. Wait for "Listening..." indicator')),
                  _buildTip(isTamil ? '3. உங்கள் கட்டளையை தெளிவாக பேசவும்' : (isHindi ? '3. अपना कमांड स्पष्ट रूप से बोलें' : '3. Speak your command clearly')),
                  _buildTip(isTamil ? '4. பயன்பாடு குரல் பின்னூட்டத்துடன் உறுதிப்படுத்தும்' : (isHindi ? '4. ऐप वॉयस फीडबैक के साथ पुष्टि करेगा' : '4. App will confirm with voice feedback')),
                  _buildTip(isTamil ? '5. குரல் கட்டுப்பாடு தானாக தொடர்கிறது' : (isHindi ? '5. वॉयस कंट्रोल स्वचालित रूप से जारी रहता है' : '5. Voice control continues automatically')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<_CommandItem> commands,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...commands.map((cmd) => _buildCommandItem(cmd)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandItem(_CommandItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.command,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: item.variations.map((variation) {
              return Chip(
                label: Text(
                  '"$variation"',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: AppColors.lightGrey,
                padding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandItem {
  final String command;
  final List<String> variations;

  _CommandItem({
    required this.command,
    required this.variations,
  });
}
