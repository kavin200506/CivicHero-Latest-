import 'package:flutter/material.dart';
import '../services/voice_controller_service.dart';
import '../utils/constants.dart';

/// Global Voice Button Widget
/// Push-to-talk mode: Press and hold to speak, release to execute
class GlobalVoiceButton extends StatefulWidget {
  const GlobalVoiceButton({Key? key}) : super(key: key);

  @override
  State<GlobalVoiceButton> createState() => _GlobalVoiceButtonState();
}

class _GlobalVoiceButtonState extends State<GlobalVoiceButton>
    with SingleTickerProviderStateMixin {
  final _voiceController = VoiceControllerService();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  bool _isLongPressing = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize voice controller
    _voiceController.initialize();
    _voiceController.setListeningCallback(() {
      if (mounted) {
        setState(() {});
      }
    });

    // Set context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _voiceController.setContext(context);
    });

    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  /// Check and enforce push-to-talk mode (stop listening if not from long press)
  Future<void> _checkAndEnforceMode() async {
    // If listening but not from long press, stop it (push-to-talk only)
    if (_voiceController.isListening && !_isLongPressing) {
      print('🛑 Enforcing push-to-talk mode: stopping listening');
      await _voiceController.stopListening();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLongPressStart() async {
    print('🎤 Hold start - Starting push-to-talk listening');
    setState(() {
      _isLongPressing = true;
    });
    _voiceController.setContext(context);
    
    // Make sure any existing listening is stopped first
    if (_voiceController.isListening) {
      await _voiceController.stopListening();
    }
    
    _voiceController.startListening(isContinuous: false).then((_) {
      print('✅ Voice listening started');
    }).catchError((e) {
      print('❌ Error starting voice: $e');
      if (mounted) {
        setState(() {
          _isLongPressing = false;
        });
      }
    });
  }

  void _handleLongPressEnd() async {
    print('🎤 Hold end - isLongPressing: $_isLongPressing');
    if (_isLongPressing) {
      print('✅ Stopping push-to-talk listening');
      
      // Stop listening and process any captured speech
      await _voiceController.stopListening();
      
      if (mounted) {
        setState(() {
          _isLongPressing = false;
        });
      }
      print('✅ Voice listening stopped and command processed');
    } else {
      // Force stop if we're listening but not in long press state
      if (_voiceController.isListening) {
        print('⚠️ Force stopping - listening but not in long press state');
        await _voiceController.stopListening();
        if (mounted) {
          setState(() {
            _isLongPressing = false;
          });
        }
      }
    }
  }
  

  @override
  Widget build(BuildContext context) {
    // Check and enforce mode on every build (async, but doesn't block)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndEnforceMode();
    });
    
    final isListening = _voiceController.isListening || _isLongPressing;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing ring when listening
        if (isListening)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 90 + (40 * _pulseAnimation.value),
                height: 90 + (40 * _pulseAnimation.value),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryRed.withOpacity(0.8 - (0.5 * _pulseAnimation.value)),
                    width: 4,
                  ),
                ),
              );
            },
          ),
        
        // Visual feedback text when holding
        if (isListening)
          Positioned(
            bottom: 90,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryRed.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Listening... Release to execute',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Main button
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isListening ? _scaleAnimation.value : 1.0,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPressStart: (details) {
                  print('🔴 Long press START - starting listening');
                  if (!_isLongPressing) {
                    _handleLongPressStart();
                  }
                },
                onLongPressEnd: (details) {
                  print('🔴 Long press END - stopping listening');
                  if (_isLongPressing) {
                    _handleLongPressEnd();
                  }
                },
                onLongPressCancel: () {
                  print('🔴 Long press CANCELLED - stopping listening');
                  if (_isLongPressing) {
                    _handleLongPressEnd();
                  }
                },
                child: Material(
                  elevation: isListening ? 12 : 4,
                  color: isListening 
                      ? AppColors.primaryRed 
                      : AppColors.primaryBlue,
                  shape: const CircleBorder(),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isListening
                          ? LinearGradient(
                              colors: [
                                AppColors.primaryRed,
                                AppColors.primaryRed.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          size: 36,
                          color: Colors.white,
                        ),
                        if (isListening)
                          Positioned(
                            bottom: 8,
                            child: Container(
                              width: 20,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        
        // Listening indicator badge
        if (isListening)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Icon(
                  Icons.fiber_manual_record,
                  size: 8,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
