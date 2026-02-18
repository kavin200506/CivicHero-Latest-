import '../models/voice_command.dart';

/// Processes voice commands and converts them to actions
class VoiceCommandProcessor {
  /// Process voice command and return action
  static VoiceCommand processCommand(String transcript, double confidence) {
    final command = transcript.toLowerCase().trim();
    
    // Navigation commands
    if (_containsAny(command, ['open camera', 'take photo', 'take picture', 'capture'])) {
      return VoiceCommand(
        type: VoiceActionType.openCamera,
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    if (_containsAny(command, ['show reports', 'view history', 'my reports', 'show my reports'])) {
      return VoiceCommand(
        type: VoiceActionType.viewHistory,
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    // Issue type detection
    if (_containsAny(command, ['pothole', 'hole in road', 'road damage'])) {
      return VoiceCommand(
        type: VoiceActionType.selectIssueType,
        data: 'Pothole',
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    if (_containsAny(command, ['garbage', 'trash', 'waste', 'rubbish', 'garbage pile'])) {
      return VoiceCommand(
        type: VoiceActionType.selectIssueType,
        data: 'Garbage Pile',
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    if (_containsAny(command, ['streetlight', 'street light', 'light broken', 'light not working', 'broken light'])) {
      return VoiceCommand(
        type: VoiceActionType.selectIssueType,
        data: 'Streetlight Broken',
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    if (_containsAny(command, ['drainage', 'drain', 'water overflow', 'flooding', 'drainage overflow'])) {
      return VoiceCommand(
        type: VoiceActionType.selectIssueType,
        data: 'Drainage Overflow',
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    if (_containsAny(command, ['water leak', 'pipe leak', 'leaking', 'water leaking', 'pipe leaking'])) {
      return VoiceCommand(
        type: VoiceActionType.selectIssueType,
        data: 'Water Leak',
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    if (_containsAny(command, ['road crack', 'cracked road', 'crack'])) {
      return VoiceCommand(
        type: VoiceActionType.selectIssueType,
        data: 'Road Crack',
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    // Urgency detection
    if (_containsAny(command, ['urgent', 'critical', 'emergency', 'immediately'])) {
      return VoiceCommand(
        type: VoiceActionType.setUrgency,
        data: 'Critical',
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    if (_containsAny(command, ['high priority', 'important', 'serious'])) {
      return VoiceCommand(
        type: VoiceActionType.setUrgency,
        data: 'High',
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    if (_containsAny(command, ['medium priority'])) {
      return VoiceCommand(
        type: VoiceActionType.setUrgency,
        data: 'Medium',
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    if (_containsAny(command, ['low priority'])) {
      return VoiceCommand(
        type: VoiceActionType.setUrgency,
        data: 'Low',
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    // Action commands
    if (_containsAny(command, ['submit', 'send', 'submit report', 'send complaint'])) {
      return VoiceCommand(
        type: VoiceActionType.submitReport,
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    if (_containsAny(command, ['cancel', 'go back', 'return'])) {
      return VoiceCommand(
        type: VoiceActionType.cancel,
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    if (_containsAny(command, ['help', 'show commands', 'what can you do'])) {
      return VoiceCommand(
        type: VoiceActionType.showHelp,
        originalTranscript: transcript,
        confidence: confidence,
      );
    }
    
    // No recognized command
    return VoiceCommand(
      type: VoiceActionType.unknown,
      data: transcript,
      originalTranscript: transcript,
      confidence: confidence,
    );
  }
  
  /// Check if text contains any of the keywords
  static bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword.toLowerCase()));
  }
  
  /// Get user-friendly description of command type
  static String getCommandDescription(VoiceActionType type) {
    switch (type) {
      case VoiceActionType.openCamera:
        return 'Open Camera';
      case VoiceActionType.viewHistory:
        return 'View Reports';
      case VoiceActionType.selectIssueType:
        return 'Select Issue Type';
      case VoiceActionType.setUrgency:
        return 'Set Urgency';
      case VoiceActionType.submitReport:
        return 'Submit Report';
      case VoiceActionType.cancel:
        return 'Cancel';
      case VoiceActionType.showHelp:
        return 'Show Help';
      case VoiceActionType.unknown:
        return 'Unknown Command';
    }
  }
}



