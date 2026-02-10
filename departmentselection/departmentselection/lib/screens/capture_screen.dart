import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../widgets/bottom_navigation.dart';
import '../utils/constants.dart';
import '../services/report_service.dart';
import '../services/ultralytics_ai_service.dart';
import 'confirm_report_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with SingleTickerProviderStateMixin {
  
  // Camera variables
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  XFile? _capturedImage;
  
  // Firebase upload state
  bool _isUploadingToFirebase = false;
  String? _firebaseImageUrl;
  
  // Form data (AI-enhanced)
  String _issueType = '';
  String _department = '';
  String _urgency = '';
  String _description = '';

  // Location variables
  bool _isFetchingLocation = false;
  String? _address;
  double? _latitude;
  double? _longitude;
  String? _locationError;

  // AI Analysis State
  bool _isAnalyzingWithAI = false;
  bool _aiAnalysisComplete = false;
  Map<String, dynamic>? _aiResult;
  String? _aiError;

  final _formKey = GlobalKey<FormState>();
  AnimationController? _fadeInController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 800), 
      vsync: this,
    );
    _fadeInController?.forward();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras!.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
          _fadeInController?.forward(from: 0);
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
      _showCameraError();
    }
  }

  void _showCameraError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera not available. Please check permissions.'),
          backgroundColor: AppColors.primaryRed,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  /// ✅ ENHANCED: Capture image and immediately upload + analyze
  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() => _isCapturing = true);
    
    try {
      // Step 1: Capture image
      print('📸 Capturing image...');
      final XFile image = await _cameraController!.takePicture();
      
      setState(() {
        _capturedImage = image;
        _isCapturing = false;
      });
      
      // Step 2: Start parallel processes immediately
      await Future.wait([
        _fetchLocation(),
        _uploadImageAndAnalyze(File(image.path)), // ✅ Upload immediately
      ]);
      
    } catch (e) {
      print('Error capturing image: $e');
      setState(() => _isCapturing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: $e'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    }
  }

  /// ✅ ENHANCED: Upload to Firebase immediately, then run AI analysis
  Future<void> _uploadImageAndAnalyze(File imageFile) async {
    try {
      // Step 1: Upload to Firebase Storage immediately
      setState(() {
        _isUploadingToFirebase = true;
        _firebaseImageUrl = null;
        _aiError = null;
      });
      
      print('☁️ Uploading to Firebase Storage immediately...');
      print('   📁 Image file path: ${imageFile.path}');
      print('   📏 Image file size: ${await imageFile.length()} bytes');
      
      final String complaintId = ReportService.generateComplainId();
      print('   🆔 Generated complaint ID: $complaintId');
      
      String imageUrl;
      try {
        imageUrl = await ReportService.uploadPhoto(imageFile, complaintId);
        print('✅ Image uploaded to Firebase successfully!');
        print('   📎 Firebase Storage URL: $imageUrl');
      } catch (e) {
        print('❌ Firebase Storage upload failed: $e');
        throw Exception('Failed to upload image to Firebase: $e');
      }
      
      setState(() {
        _firebaseImageUrl = imageUrl;
        _isUploadingToFirebase = false;
      });
      
      // Step 2: Now run AI analysis with Firebase URL
      print('🤖 Starting AI analysis with uploaded image...');
      await _runAIAnalysis(imageUrl);
      
    } catch (e, stackTrace) {
      print('❌ Upload and analyze failed: $e');
      print('📚 Stack trace: $stackTrace');
      setState(() {
        _isUploadingToFirebase = false;
        _aiError = 'Upload failed: $e';
      });
    }
  }

  /// ✅ ENHANCED: AI Analysis using Firebase Storage URL
  Future<void> _runAIAnalysis(String firebaseImageUrl) async {
    setState(() {
      _isAnalyzingWithAI = true;
      _aiAnalysisComplete = false;
      _aiResult = null;
      _aiError = null;
    });

    try {
      print('🤖 Running AI analysis with Firebase Storage URL...');
      print('📎 URL: $firebaseImageUrl');
      
      // Use the actual Firebase Storage URL for AI analysis
      final aiResult = await UltralyticsAIService.analyzeImage(firebaseImageUrl);
      
      if (mounted) {
        setState(() {
          _aiResult = aiResult;
          _isAnalyzingWithAI = false;
          _aiAnalysisComplete = true;
          
          // Pre-populate form with AI results if successful
          if (aiResult['success'] == true && (aiResult['confidence'] ?? 0.0) >= 0.3) {
            _issueType = aiResult['detected_issue'] ?? '';
            _department = aiResult['ai_department'] ?? '';
            
            print('🎯 AI pre-populated: $_issueType → $_department');
            print('📊 Confidence: ${((aiResult['confidence'] ?? 0.0) * 100).toStringAsFixed(1)}%');
          }
        });
      }
      
    } catch (e, stackTrace) {
      print('❌ AI analysis failed: $e');
      print('📚 Stack trace: $stackTrace');
      
      String errorMessage = 'AI analysis failed';
      if (e.toString().contains('Failed to download image')) {
        errorMessage = 'Failed to download image from Firebase. Please try again.';
      } else if (e.toString().contains('HTTP')) {
        errorMessage = 'API request failed. Check your internet connection.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timed out. Please try again.';
      } else {
        errorMessage = 'AI analysis failed: ${e.toString()}';
      }
      
      if (mounted) {
        setState(() {
          _aiError = errorMessage;
          _isAnalyzingWithAI = false;
          _aiAnalysisComplete = false;
        });
      }
    }
  }

  Future<void> _fetchLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _address = null;
      _locationError = null;
      _latitude = null;
      _longitude = null;
    });
    
    try {
      print('📍 Fetching location...');
      final loc = await ReportService.getCurrentLocation();
      
      if (mounted) {
        setState(() {
          _address = loc["address"];
          _latitude = loc["latitude"];
          _longitude = loc["longitude"];
          _isFetchingLocation = false;
        });
        print('✅ Location fetched: $_address');
      }
    } catch (e) {
      print('❌ Location fetch failed: $e');
      if (mounted) {
        setState(() {
          _locationError = 'Failed to fetch location: $e';
          _isFetchingLocation = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _fadeInController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('🤖 AI-Powered Capture'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _capturedImage == null 
          ? _buildCameraUI() 
          : _buildReportFormUI(),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildCameraUI() {
    return Stack(
      children: [
        // Camera Preview
        FadeTransition(
          opacity: _fadeInController!,
          child: _isCameraInitialized && _cameraController != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: CameraPreview(_cameraController!),
                  ),
                )
              : Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppColors.primaryBlue),
                        SizedBox(height: 16),
                        Text(
                          'Initializing Camera...',
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 16, 
                            letterSpacing: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        
        // Capture Button
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _isCapturing ? null : _captureImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isCapturing ? 78 : 100,
                height: _isCapturing ? 78 : 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: _isCapturing
                        ? [AppColors.primaryOrange, Colors.orange.withOpacity(0.2)]
                        : [AppColors.primaryBlue, Colors.blueAccent.withOpacity(0.12)],
                    center: Alignment.center,
                    radius: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isCapturing
                          ? AppColors.primaryOrange.withOpacity(0.5)
                          : AppColors.primaryBlue.withOpacity(0.32),
                      blurRadius: 16,
                    )
                  ],
                ),
                child: _isCapturing
                    ? const CircularProgressIndicator(
                        color: Colors.white, 
                        strokeWidth: 4,
                      )
                    : const Icon(
                        Icons.smart_toy, // AI capture icon
                        color: Colors.white, 
                        size: 40,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportFormUI() {
    return Container(
      alignment: Alignment.center,
      color: Colors.black.withOpacity(0.05),
      child: SingleChildScrollView(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 250),
          padding: MediaQuery.of(context).viewInsets +
              const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          child: Center(
            child: Container(
              width: 420,
              constraints: const BoxConstraints(maxWidth: 480),
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.94),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withOpacity(0.06),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.1), 
                  width: 2,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Captured Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_capturedImage!.path), 
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    const SizedBox(height: 16),

                    // ✅ Enhanced Status Cards
                    if (_isUploadingToFirebase) _buildUploadingCard(),
                    if (_isAnalyzingWithAI) _buildAIAnalysisCard(),
                    if (_aiAnalysisComplete && _aiResult != null) _buildAIResultCard(),
                    if (_aiError != null) _buildAIErrorCard(),

                    const SizedBox(height: 16),

                    // Location Section
                    _buildLocationSection(),
                    
                    const SizedBox(height: 16),

                    // Issue Type Dropdown (AI-enhanced)
                    _buildIssueTypeDropdown(),
                    
                    const SizedBox(height: 16),

                    // Department Dropdown (AI-enhanced)
                    _buildDepartmentDropdown(),

                    const SizedBox(height: 16),

                    // Urgency Dropdown
                    _buildUrgencyDropdown(),
                    
                    const SizedBox(height: 16),
                    
                    // Description Field
                    _buildDescriptionField(),

                    const SizedBox(height: 24),

                    // Submit Button
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Enhanced Status Cards
  Widget _buildUploadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '☁️ Uploading to Firebase Storage...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Preparing image for AI analysis',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primaryGreen,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🤖 IgniteX AI Analyzing...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Running YOLO detection on your custom model',
                  style: TextStyle(
                    color: AppColors.primaryGreen,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIResultCard() {
  final isSuccess = _aiResult!['success'] == true;
  final confidence = _aiResult!['confidence'] as double? ?? 0.0;
  
  return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: isSuccess 
          ? AppColors.primaryGreen.withOpacity(0.1)
          : AppColors.primaryOrange.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isSuccess 
            ? AppColors.primaryGreen.withOpacity(0.3)
            : AppColors.primaryOrange.withOpacity(0.3),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.help_outline,
              color: isSuccess ? AppColors.primaryGreen : AppColors.primaryOrange,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              isSuccess ? '✅ IgniteX AI Detection Successful' : '⚠️ IgniteX AI Detection Uncertain',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSuccess ? AppColors.primaryGreen : AppColors.primaryOrange,
                fontSize: 16,
              ),
            ),
          ],
        ),
        if (isSuccess) ...[
          const SizedBox(height: 8),
          Text(
            'Detected: ${_aiResult!['detected_issue']}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Form pre-populated with IgniteX AI results. You can modify if needed.',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    ),
  );
}

  Widget _buildAIErrorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.primaryRed),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '❌ IgniteX AI Analysis Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                  ),
                ),
                Text(
                  'Please select issue type manually',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        child: _isFetchingLocation
            ? Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, 
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Fetching location...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.09
                    ),
                  ),
                ],
              )
            : _locationError != null
                ? Row(
                    children: [
                      Icon(Icons.error, color: Colors.red[200]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _locationError!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _address ?? 'Unknown location',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildIssueTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _issueType.isNotEmpty ? _issueType : null,
      decoration: InputDecoration(
        labelText: 'Issue Type',
        prefixIcon: Icon(_getIconForIssueType(_issueType)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: _aiResult?['success'] == true && _issueType.isNotEmpty
            ? AppColors.primaryGreen.withOpacity(0.05)
            : Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an issue type';
        }
        return null;
      },
      items: DummyData.issueTypes.map<DropdownMenuItem<String>>((value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: [
              Icon(_getIconForIssueType(value), size: 20),
              const SizedBox(width: 8),
              Text(value),
              if (_aiResult?['detected_issue'] == value) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _issueType = newValue ?? '';
          if (_issueType.isNotEmpty) {
            _department = UltralyticsAIService.getDepartmentForIssue(_issueType);
          }
        });
      },
    );
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<String>(
      value: _department.isNotEmpty ? _department : null,
      decoration: InputDecoration(
        labelText: 'Department',
        prefixIcon: const Icon(Icons.business),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: _aiResult?['success'] == true && _department.isNotEmpty
            ? AppColors.primaryGreen.withOpacity(0.05)
            : Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a department';
        }
        return null;
      },
      items: DummyData.departments.map<DropdownMenuItem<String>>((value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: [
              Text(value),
              if (_aiResult?['ai_department'] == value) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() => _department = newValue ?? '');
      },
    );
  }

  Widget _buildUrgencyDropdown() {
    return DropdownButtonFormField<String>(
      value: _urgency.isNotEmpty ? _urgency : null,
      decoration: InputDecoration(
        labelText: 'Urgency Level',
        prefixIcon: const Icon(Icons.priority_high),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select urgency level';
        }
        return null;
      },
      items: DummyData.urgencyLevels.map<DropdownMenuItem<String>>((value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() => _urgency = newValue ?? '');
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      onChanged: (value) => _description = value,
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        prefixIcon: const Icon(Icons.text_snippet),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        hintText: 'Describe the issue in detail...',
      ),
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton() {
    final bool canSubmit = _issueType.isNotEmpty && 
                          _department.isNotEmpty && 
                          _urgency.isNotEmpty && 
                          _address != null &&
                          _firebaseImageUrl != null &&  // ✅ Ensure image is uploaded
                          !_isAnalyzingWithAI &&
                          !_isFetchingLocation &&
                          !_isUploadingToFirebase;  // ✅ Wait for upload

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canSubmit ? _navigateToConfirmScreen : null,
        icon: (_isAnalyzingWithAI || _isFetchingLocation || _isUploadingToFirebase)
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.smart_toy),
        label: Text(
          _isUploadingToFirebase 
              ? 'Uploading to Cloud...'
              : _isAnalyzingWithAI 
                  ? 'AI Analyzing...'
                  : _isFetchingLocation 
                      ? 'Getting Location...'
                      : 'Continue with Results',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  IconData _getIconForIssueType(String issueType) {
    switch (issueType.toLowerCase()) {
      case 'pothole':
        return Icons.construction;
      case 'streetlight broken':
        return Icons.lightbulb_outline;
      case 'drainage overflow':
        return Icons.water_drop_outlined;
      case 'garbage pile':
        return Icons.delete_outline;
      case 'water leak':
        return Icons.water_damage;
      case 'road crack':
        return Icons.timeline;
      default:
        return Icons.report_problem;
    }
  }

  void _navigateToConfirmScreen() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_address == null || _latitude == null || _longitude == null || _firebaseImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for upload and location to complete.'),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmReportScreen(
          image: File(_capturedImage!.path),
          issueType: _issueType,
          department: _department,
          urgency: _urgency,
          description: _description,
          address: _address!,
          latitude: _latitude!,
          longitude: _longitude!,
          onEdit: () => Navigator.pop(context),
          onSubmit: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
    );
  }
}
