/// Voice command data model
class VoiceCommand {
  final VoiceActionType type;
  final String? data;
  final String originalTranscript;
  final double confidence;

  VoiceCommand({
    required this.type,
    this.data,
    required this.originalTranscript,
    required this.confidence,
  });

  bool get isUnknown => type == VoiceActionType.unknown;
  bool get isValid => type != VoiceActionType.unknown;
}

/// Voice action types
enum VoiceActionType {
  openCamera,
  viewHistory,
  selectIssueType,
  setUrgency,
  submitReport,
  cancel,
  showHelp,
  unknown,
}



