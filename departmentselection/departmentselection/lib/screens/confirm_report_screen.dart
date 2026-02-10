import 'dart:io';
import 'package:flutter/material.dart';
import '../services/report_service.dart';
import '../utils/constants.dart';

class ConfirmReportScreen extends StatefulWidget {
  final File image;
  final String issueType;
  final String department;
  final String urgency;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final VoidCallback onEdit;
  final VoidCallback onSubmit;

  const ConfirmReportScreen({
    super.key,
    required this.image,
    required this.issueType,
    required this.department,
    required this.urgency,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.onEdit,
    required this.onSubmit,
  });

  @override
  State<ConfirmReportScreen> createState() => _ConfirmReportScreenState();
}

class _ConfirmReportScreenState extends State<ConfirmReportScreen> {
  bool _isSubmitting = false;
  String? _submitError;

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });
    try {
      await ReportService.submitReport(
        issueType: widget.issueType,
        department: widget.department,
        urgency: widget.urgency,
        description: widget.description,
        imageFile: widget.image,
      );
      widget.onSubmit();
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Report Submitted'),
            content: const Text('Your civic issue has been reported successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _submitError = 'Submission failed: $e';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Confirm & Submit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting ? null : widget.onEdit,
        ),
        elevation: 0.0,
        backgroundColor: Colors.white.withOpacity(0.9),
        foregroundColor: AppColors.primaryBlue,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 430,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.97),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.07),
                  blurRadius: 36,
                  offset: const Offset(0, 14),
                ),
              ],
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.12), width: 2)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(widget.image, width: 280, height: 180, fit: BoxFit.cover),
                ),
                const SizedBox(height: 24),
                _frostedInfoRow(Icons.category, 'Issue Type', widget.issueType),
                _frostedInfoRow(Icons.business, 'Department', widget.department),
                _frostedInfoRow(Icons.priority_high, 'Urgency', widget.urgency),
                _frostedInfoRow(Icons.location_on, 'Address', widget.address),
                _frostedInfoRow(Icons.text_snippet, 'Description', widget.description),
                const SizedBox(height: 12),
                if (_submitError != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      _submitError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[50],
                          foregroundColor: AppColors.primaryOrange,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          minimumSize: const Size(0, 50),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : widget.onEdit,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: const Text('Confirm & Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          minimumSize: const Size(0, 50),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          shadowColor: AppColors.primaryBlue.withOpacity(0.2),
                          elevation: 2,
                        ),
                        onPressed: _isSubmitting ? null : _handleSubmit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _frostedInfoRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.055),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
