import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_navigation.dart';
import '../utils/constants.dart';
import '../models/complaint.dart';
import '../services/report_service.dart';
import 'capture_screen.dart';
import 'status_tracker_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Keep track of last known status for each complaint so we can
  /// detect status changes coming from the admin dashboard.
  final Map<String, String> _lastStatuses = {};

  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.location_city,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              'CivicHero',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Sign Out",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('You must be logged in to use the dashboard.'))
          : StreamBuilder<List<Complaint>>(
              stream: ReportService.getUserComplaintsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Something went wrong: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                final complaints = snapshot.data ?? [];

                // Detect status changes (Assigned / In Progress / Resolved)
                _detectStatusChangesAndNotify(complaints);

                // Compute quick stats
                final activeCount =
                    complaints.where((c) => c.status != 'Resolved').length;
                final resolvedThisWeek = complaints
                    .where((c) =>
                        c.status == 'Resolved' &&
                        c.reportedDate.isAfter(
                          DateTime.now().subtract(const Duration(days: 7)),
                        ))
                    .length;

                // Show up to 3 most recent complaints as activity
                final recentComplaints = complaints.take(3).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section with user email
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.primaryBlue.withOpacity(0.8)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Show user's email
                            if (user.email != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.account_circle,
                                      color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    user.email!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                            const Text(
                              'Welcome to CivicHero!',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Report civic issues in your area and help make your city better.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CaptureScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.camera_alt,
                                    color: AppColors.primaryBlue),
                                label: const Text(
                                  'Report New Issue',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Quick Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Active\nComplaints',
                              activeCount.toString(),
                              AppColors.primaryOrange,
                              Icons.pending_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Resolved\nThis Week',
                              resolvedThisWeek.toString(),
                              AppColors.primaryGreen,
                              Icons.check_circle_outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Recent Activity
                      const Text(
                        'Recent Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      recentComplaints.isEmpty
                          ? Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inbox_rounded,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No recent complaints filed',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: recentComplaints
                                  .map((complaint) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: _buildActivityCard(
                                          complaint.issueType,
                                          complaint.department,
                                          complaint.status,
                                          _getStatusColor(complaint.status),
                                          _getIssueIcon(complaint.issueType),
                                          () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    StatusTrackerScreen(
                                                        complainId:
                                                            complaint.complainId),
                                              ),
                                            );
                                          },
                                        ),
                                      ))
                                  .toList(),
                            ),
                      const SizedBox(height: 100), // Space for bottom navigation
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 0),
    );
  }

  /// Check for status changes coming from Firestore and show
  /// a friendly in-app notification to the user.
  void _detectStatusChangesAndNotify(List<Complaint> complaints) {
    for (final complaint in complaints) {
      final id = complaint.complainId;
      final newStatus = complaint.status;
      final previousStatus = _lastStatuses[id];

      // First time seeing this complaint in this session – just store status.
      if (previousStatus == null) {
        _lastStatuses[id] = newStatus;
        continue;
      }

      // No change
      if (previousStatus == newStatus) continue;

      // Update cache
      _lastStatuses[id] = newStatus;

      // Only notify for meaningful progress updates
      if (newStatus == 'Assigned' ||
          newStatus == 'In Progress' ||
          newStatus == 'Resolved') {
        final message = _buildStatusMessage(complaint);

        // Ensure we show SnackBar after current frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        });
      }
    }
  }

  String _buildStatusMessage(Complaint complaint) {
    switch (complaint.status) {
      case 'Assigned':
        return 'Your complaint "${complaint.issueType}" has been assigned to the department.';
      case 'In Progress':
        return 'Good news! Your complaint "${complaint.issueType}" is now In Progress.';
      case 'Resolved':
        return '🎉 Your complaint "${complaint.issueType}" has been marked as Resolved.';
      default:
        return 'Status of your complaint "${complaint.issueType}" was updated to ${complaint.status}.';
    }
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Container(
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    String title,
    String department,
    String status,
    Color statusColor,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    department,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved':
        return AppColors.primaryGreen;
      case 'In Progress':
        return AppColors.primaryOrange;
      case 'Assigned':
        return AppColors.primaryBlue;
      default:
        return AppColors.darkGrey;
    }
  }

  IconData _getIssueIcon(String issueType) {
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
}
