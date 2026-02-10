import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/status_timeline.dart';
import '../utils/constants.dart';
import '../models/complaint.dart';

class StatusTrackerScreen extends StatelessWidget {
  final String complainId;

  const StatusTrackerScreen({super.key, required this.complainId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('Complaint Status'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _showShareDialog(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issues')
            .doc(complainId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data?.data();
          if (data == null) {
            return const Center(child: Text('Complaint not found.'));
          }
          final complaint = Complaint.fromMap(data as Map<String, dynamic>);
          int currentStep = _getStepFromStatus(complaint.status);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated icon and progress bar block
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen.withOpacity(0.96),
                        AppColors.primaryGreen.withOpacity(0.7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        child: Icon(
                          _getSuccessIcon(complaint.status),
                          key: ValueKey(complaint.status),
                          color: Colors.white,
                          size: 65,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0, end: (currentStep+1)*0.25),
                        duration: const Duration(milliseconds: 900),
                        builder: (context, value, _) => LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 7,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        complaint.status == "Resolved"
                          ? 'Complaint Resolved!'
                          : 'Complaint Submitted Successfully!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ComplaintStatusMessage[complaint.status] ??
                          'Your complaint is being processed.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Complaint Details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complaint Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow('Complaint ID', complaint.complainId, Icons.confirmation_number),
                      _buildDetailRow('Issue Type', complaint.issueType, _getIssueIcon(complaint.issueType)),
                      _buildDetailRow('Department', complaint.department, Icons.business),
                      _buildDetailRow('Priority', complaint.urgency, Icons.priority_high),
                      _buildDetailRow('Submitted', complaint.reportedDate.toString().substring(0, 16), Icons.schedule),
                      _buildDetailRow('Status', complaint.status, Icons.info_outline),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Status Timeline
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progress Tracker',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(complaint.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              complaint.status,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(complaint.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      StatusTimeline(currentStep: currentStep),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 0),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.darkGrey),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static int _getStepFromStatus(String status) {
    switch (status) {
      case "Reported":
        return 0;
      case "Assigned":
        return 1;
      case "In Progress":
        return 2;
      case "Resolved":
        return 3;
      default:
        return 0;
    }
  }

  static IconData _getSuccessIcon(String status) {
    switch (status) {
      case "Resolved":
        return Icons.verified;
      case "In Progress":
        return Icons.autorenew;
      default:
        return Icons.check_circle_outline;
    }
  }

  static Color _getStatusColor(String status) {
    switch (status) {
      case "Resolved":
        return AppColors.primaryGreen;
      case "In Progress":
        return AppColors.primaryOrange;
      case "Assigned":
        return AppColors.primaryBlue;
      default:
        return AppColors.darkGrey;
    }
  }

  static IconData _getIssueIcon(String issueType) {
    switch (issueType) {
      case 'Pothole':
        return Icons.construction;
      case 'Streetlight Broken':
        return Icons.lightbulb_outline;
      case 'Drainage Overflow':
        return Icons.water_drop_outlined;
      case 'Garbage Pile':
        return Icons.delete_outline;
      default:
        return Icons.report_problem_outlined;
    }
  }

  static const Map<String, String> ComplaintStatusMessage = {
    "Reported": "Your complaint has been registered and assigned to the relevant department.",
    "Assigned": "A municipal officer has been assigned to your complaint.",
    "In Progress": "Work has started on your reported issue.",
    "Resolved": "Congratulations! Your complaint has been resolved.",
  };

  static void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share Complaint'),
          content: const Text('Share your complaint status with others?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complaint shared successfully!'),
                    backgroundColor: AppColors.primaryBlue,
                  ),
                );
              },
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
  }
}
