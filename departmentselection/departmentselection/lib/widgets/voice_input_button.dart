import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../utils/constants.dart';

/// Floating voice input button with animation and real-time feedback
class VoiceInputButton extends StatefulWidget {
  final Function(String transcript, double confidence) onVoiceCommand;
  final String languageCode;
  final bool useGoogleSpeech; // Use Google Speech API vs device speech
  
  const VoiceInputButton({
    Key? key,
    required this.onVoiceCommand,
    this.languageCode = 'en_IN',
    this.useGoogleSpeech = false,
  }) : super(key: key);

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isAvailable = false;
  String _currentText = '';
  double _confidence = 0.0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
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

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onError: (error) {
        print('Speech recognition error: ${error.errorMsg}');
        if (mounted) {
          _showError(error.errorMsg);
        }
      },
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        }
      },
    );
    
    if (mounted) {
      setState(() {
        _isAvailable = available;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (!_isAvailable) {
      _showError('Speech recognition not available');
      return;
    }

    // Check microphone permission
    final micPermission = await Permission.microphone.status;
    if (!micPermission.isGranted) {
      final result = await Permission.microphone.request();
      if (!result.isGranted) {
        _showError('Microphone permission is required for voice commands');
        return;
      }
    }

    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _currentText = '';
      _confidence = 0.0;
    });
    
    _speech.listen(
      onResult: (result) {
        setState(() {
          _currentText = result.recognizedWords;
          _confidence = result.confidence;
        });
        
        if (result.finalResult) {
          widget.onVoiceCommand(result.recognizedWords, result.confidence);
          _stopListening();
        }
      },
      localeId: widget.languageCode,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: true,
      partialResults: true,
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _currentText = '';
      _confidence = 0.0;
    });
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primaryRed,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Color _getConfidenceColor() {
    if (_confidence >= 0.8) return AppColors.primaryGreen;
    if (_confidence >= 0.5) return AppColors.primaryOrange;
    return AppColors.primaryRed;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAvailable) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Listening indicator with waveform
        if (_isListening)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(_pulseAnimation.value),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Listening...',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (_currentText.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _currentText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_confidence > 0) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getConfidenceColor(),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${(_confidence * 100).toStringAsFixed(0)}% confidence',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _getConfidenceColor(),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        
        // Floating action button
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isListening ? _scaleAnimation.value : 1.0,
              child: FloatingActionButton.extended(
                onPressed: _toggleListening,
                icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                label: Text(_isListening ? 'Stop Listening' : 'Voice Command'),
                backgroundColor: _isListening ? AppColors.primaryRed : AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: _isListening ? 8 : 4,
              ),
            );
          },
        ),
      ],
    );
  }
}



