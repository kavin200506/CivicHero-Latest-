import 'package:flutter/material.dart';
import '../services/voice_controller_service.dart';
import '../utils/constants.dart';

/// Language Selector Widget
/// Allows users to switch between English, Hindi, and Tamil for voice commands
class LanguageSelector extends StatefulWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  final _voiceController = VoiceControllerService();
  String _selectedLanguage = 'en-IN';

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _voiceController.currentLanguage;
  }

  Future<void> _changeLanguage(String languageCode) async {
    await _voiceController.setLanguage(languageCode);
    setState(() {
      _selectedLanguage = languageCode;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getLanguageChangeMessage(languageCode)),
          backgroundColor: AppColors.primaryGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getLanguageChangeMessage(String code) {
    switch (code) {
      case 'en-IN':
        return 'Language changed to English';
      case 'hi-IN':
        return 'भाषा हिंदी में बदली गई'; // Language changed to Hindi
      case 'ta-IN':
        return 'மொழி தமிழுக்கு மாற்றப்பட்டது'; // Language changed to Tamil
      default:
        return 'Language changed';
    }
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en-IN':
        return 'English';
      case 'hi-IN':
        return 'हिंदी (Hindi)';
      case 'ta-IN':
        return 'தமிழ் (Tamil)';
      default:
        return code;
    }
  }

  IconData _getLanguageIcon(String code) {
    switch (code) {
      case 'en-IN':
        return Icons.language;
      case 'hi-IN':
        return Icons.translate;
      case 'ta-IN':
        return Icons.translate;
      default:
        return Icons.language;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  'Voice Command Language',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Select language for voice commands and feedback',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            ...['en-IN', 'hi-IN', 'ta-IN'].map((langCode) {
              final isSelected = _selectedLanguage == langCode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _changeLanguage(langCode),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getLanguageIcon(langCode),
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.darkGrey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getLanguageName(langCode),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : AppColors.darkGrey,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primaryGreen,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Voice commands and feedback will be in the selected language',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



