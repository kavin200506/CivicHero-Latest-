# Voice Commands Setup Guide

This guide will help you set up Google Cloud Speech-to-Text API for voice commands in CivicHero.

## 📋 Prerequisites

1. Google Cloud account
2. Firebase project (`civicissue-aae6d`)
3. Flutter development environment

## 🔑 Step 1: Enable Cloud Speech-to-Text API

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: `civicissue-aae6d`
3. Navigate to **APIs & Services** > **Library**
4. Search for "Cloud Speech-to-Text API"
5. Click **Enable**

## 🔐 Step 2: Create API Key

1. Go to **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **API Key**
3. Copy the API key
4. (Recommended) Click **Restrict Key** and:
   - Under **API restrictions**, select "Restrict key"
   - Choose "Cloud Speech-to-Text API"
   - Under **Application restrictions**, select "Android apps" or "iOS apps" based on your target platform
   - Add your app's package name and SHA-1 fingerprint

## 📝 Step 3: Configure .env File

1. In the project root (`departmentselection/departmentselection/`), create a file named `.env`
2. Add the following content:

```env
# Google Cloud Speech-to-Text API Key
GOOGLE_SPEECH_API_KEY=YOUR_API_KEY_HERE
```

3. Replace `YOUR_API_KEY_HERE` with your actual API key from Step 2

**Important:** The `.env` file is already in `.gitignore` and will NOT be committed to git.

## 🎯 Step 4: API Keys Available

You mentioned you have these API keys:

- **iOS key**: `AIzaSyAuJfJmnu4ol6h94w6-cYB0rZtCv_JYqQg`
- **Android key**: `AIzaSyAVkLjon9uXeohi279LcZDqCi0O4Toq4u8`
- **Browser key**: `AIzaSyDGO_1c2xhgPi0-m0RU_OK9oN-pxRTPSN8`

**For mobile app, use:**
- iOS app → Use iOS key
- Android app → Use Android key

## ✅ Step 5: Verify Setup

1. Run `flutter pub get` (already done)
2. Make sure `.env` file exists with your API key
3. Run the app: `flutter run`
4. Navigate to the Capture screen
5. Tap the "Voice Command" button
6. Say "help" or "show commands"
7. You should see the voice command help screen

## 🎤 Available Voice Commands

### Navigation
- "open camera" / "take photo"
- "show reports" / "view history"

### Issue Types
- "pothole"
- "garbage" / "trash"
- "streetlight" / "light broken"
- "drainage" / "water overflow"
- "water leak" / "pipe leak"

### Urgency
- "urgent" / "critical"
- "high priority"
- "medium priority"
- "low priority"

### Actions
- "submit report" / "send complaint"
- "cancel" / "go back"
- "help" / "show commands"

## 🌍 Multi-Language Support

The app supports:
- **English (India)**: `en-IN` (default)
- **Hindi (India)**: `hi-IN`
- **Tamil (India)**: `ta-IN`

To change language, modify the `languageCode` parameter in `VoiceInputButton` widget.

## 🔧 Troubleshooting

### "API key not found" error
- Check that `.env` file exists in the project root
- Verify the API key is correct (no extra spaces)
- Make sure you ran `flutter pub get`

### "Speech recognition not available"
- Check microphone permission is granted
- On iOS: Settings > Privacy > Microphone > CivicHero
- On Android: Settings > Apps > CivicHero > Permissions > Microphone

### "API authentication failed"
- Verify the API key is correct
- Check that Cloud Speech-to-Text API is enabled
- Verify API key restrictions (if any)

### Commands not recognized
- Speak clearly and naturally
- Check confidence score (green = good, red = poor)
- Try different phrasings (see help screen for variations)
- Ensure good internet connection (for Google Speech API)

## 📱 Testing

1. **Test basic commands:**
   - Say "help" → Should open help screen
   - Say "pothole" → Should select pothole issue type
   - Say "urgent" → Should set urgency to Critical

2. **Test with Indian accent:**
   - The API is optimized for Indian English
   - Try commands in natural Indian English accent

3. **Test offline fallback:**
   - The app uses device speech recognition as fallback
   - Works even without internet (lower accuracy)

## 🚀 Production Checklist

- [ ] API key is restricted to specific APIs
- [ ] API key has application restrictions (Android/iOS)
- [ ] `.env` file is NOT committed to git
- [ ] Microphone permissions are properly configured
- [ ] Tested with real users and Indian accents
- [ ] Voice commands work in noisy environments
- [ ] Error handling is tested (no internet, no permission)

## 📚 Additional Resources

- [Google Cloud Speech-to-Text Documentation](https://cloud.google.com/speech-to-text/docs)
- [Flutter Speech to Text Package](https://pub.dev/packages/speech_to_text)
- [Flutter Dotenv Package](https://pub.dev/packages/flutter_dotenv)

## 🆘 Support

If you encounter issues:
1. Check the console logs for error messages
2. Verify API key and permissions
3. Test with device speech recognition (offline mode)
4. Check microphone permissions in device settings



