import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_navigation.dart';
import '../utils/constants.dart';
import '../models/complaint.dart';
import '../services/report_service.dart'; // needed!
import 'status_tracker_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text('Complaint History'),
        elevation: 0.0,
        backgroundColor: Colors.white.withOpacity(0.97),
        foregroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Add search logic if needed
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('You must be logged in to see your complaints.'))
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
                List<Complaint> filteredComplaints = _selectedFilter == 'All'
                    ? complaints
                    : complaints.where((c) => c.status == _selectedFilter).toList();

                return Column(
                  children: [
                    // Filter Tabs
                    Container(
                      height: 56,
                      margin: const EdgeInsets.all(16),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: ['All', 'In Progress', 'Assigned', 'Resolved'].map((filter) {
                          bool isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeInOut,
                              child: FilterChip(
                                label: Text(
                                  filter,
                                  style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.darkGrey,
                                      fontWeight: FontWeight.bold),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: AppColors.primaryBlue,
                                labelStyle: TextStyle(fontSize: isSelected ? 17 : 15),
                                elevation: isSelected ? 7 : 0,
                                shadowColor: isSelected
                                    ? AppColors.primaryBlue.withOpacity(0.18)
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primaryBlue
                                      : Colors.grey.withOpacity(0.08),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(11)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Statistics Row (real time)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                                'Total', complaints.length.toString(), AppColors.primaryBlue),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                                'Resolved',
                                complaints.where((c) => c.status == 'Resolved').length.toString(),
                                AppColors.primaryGreen),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildStatCard(
                                'Pending',
                                complaints.where((c) => c.status != 'Resolved').length.toString(),
                                AppColors.primaryOrange),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Complaints List
                    Expanded(
                      child: filteredComplaints.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TweenAnimationBuilder(
                                    duration: const Duration(milliseconds: 900),
                                    tween: Tween<double>(begin: 1, end: 1.15),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) =>
                                        Transform.scale(scale: value, child: child),
                                    child: Icon(
                                      Icons.inbox_rounded,
                                      size: 100,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No ${_selectedFilter.toLowerCase()} complaints found',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Your complaint history will appear here',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              itemCount: filteredComplaints.length,
                              itemBuilder: (context, index) {
                                return _buildComplaintCard(filteredComplaints[index]);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.10), Colors.white.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.09),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: color,
              shadows: [
                Shadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 7,
                    offset: const Offset(0, 1))
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.darkGrey, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    Color statusColor = _getStatusColor(complaint.status);
    IconData issueIcon = _getIssueIcon(complaint.issueType);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Card(
        elevation: 4,
        shadowColor: statusColor.withOpacity(0.16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        color: Colors.white.withOpacity(0.99),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 350),
                pageBuilder: (context, animation, secondaryAnimation) =>
                    FadeTransition(
                  opacity: animation,
                  child: StatusTrackerScreen(complainId: complaint.complainId),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [statusColor.withOpacity(0.18), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        issueIcon,
                        color: statusColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            complaint.issueType,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGrey,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            complaint.complainId,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.darkGrey.withOpacity(0.67),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withOpacity(0.13),
                            Colors.white.withOpacity(0.6)
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.1), width: 1.3),
                      ),
                      child: Text(
                        complaint.status,
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Icon(Icons.business, size: 14, color: AppColors.darkGrey.withOpacity(0.7)),
                    const SizedBox(width: 4),
                    Text(
                      complaint.department,
                      style: TextStyle(fontSize: 12, color: AppColors.darkGrey.withOpacity(0.81), fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.priority_high,
                        size: 14, color: _getUrgencyColor(complaint.urgency)),
                    const SizedBox(width: 4),
                    Text(
                      complaint.urgency,
                      style: TextStyle(fontSize: 12, color: _getUrgencyColor(complaint.urgency), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 13, color: AppColors.darkGrey),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(complaint.reportedDate),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.darkGrey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.darkGrey,
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

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'Critical':
        return AppColors.primaryPurple;
      case 'High':
        return AppColors.primaryRed;
      case 'Medium':
        return AppColors.primaryOrange;
      case 'Low':
        return AppColors.primaryGreen;
      default:
        return AppColors.darkGrey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}
