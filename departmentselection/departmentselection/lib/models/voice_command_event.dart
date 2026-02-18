/// Voice Command Event System
/// Used for communication between voice controller and screens

enum VoiceAction {
  // Navigation
  navigateHome,
  navigateCamera,
  navigateReports,
  navigateProfile,
  navigateSettings,
  goBack,
  refresh,
  
  // Report Actions
  selectIssueType,
  setUrgency,
  addDescription,
  submitReport,
  cancel,
  
  // Camera
  takePhoto,
  retakePhoto,
  confirmPhoto,
  
  // Reports Screen
  filterReports,
  openReportAtIndex,
  scrollDown,
  
  // Profile/Settings
  updateName,
  updatePhone,
  enableNotifications,
  disableNotifications,
  logout,
  
  // Accessibility
  readScreen,
}

class VoiceCommand {
  final VoiceAction action;
  final dynamic data;

  VoiceCommand({
    required this.action,
    this.data,
  });
}

/// Event bus for voice commands
class VoiceCommandEvent {
  static final List<Function(VoiceCommand)> _listeners = [];

  /// Listen to voice command events
  static void listen(Function(VoiceCommand) callback) {
    _listeners.add(callback);
  }

  /// Broadcast a voice command event
  static void broadcast(VoiceCommand command) {
    print('📢 Broadcasting voice command: ${command.action} with data: ${command.data}');
    for (var listener in _listeners) {
      try {
        listener(command);
      } catch (e) {
        print('❌ Error in voice command listener: $e');
      }
    }
  }

  /// Remove a listener
  static void removeListener(Function(VoiceCommand) callback) {
    _listeners.remove(callback);
  }

  /// Clear all listeners
  static void clear() {
    _listeners.clear();
  }
}



