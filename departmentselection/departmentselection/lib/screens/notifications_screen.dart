import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import '../utils/constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Complaint Assigned',
        'message': 'Your pothole complaint has been assigned to Rajesh Kumar',
        'time': '2 hours ago',
        'type': 'assigned',
        'isRead': false,
      },
      {
        'title': 'Status Update',
        'message': 'Work has started on your streetlight complaint',
        'time': '1 day ago',
        'type': 'progress',
        'isRead': false,
      },
      {
        'title': 'Complaint Resolved',
        'message': 'Your drainage issue has been marked as resolved',
        'time': '3 days ago',
        'type': 'resolved',
        'isRead': true,
      },
      {
        'title': 'Feedback Request',
        'message': 'Please rate your experience for complaint CPT-001231',
        'time': '1 week ago',
        'type': 'feedback',
        'isRead': true,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: () {
              // Mark all as read
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You\'ll receive updates about your complaints here',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 3),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    Color typeColor = _getTypeColor(notification['type']);
    IconData typeIcon = _getTypeIcon(notification['type']);
    bool isRead = notification['isRead'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: isRead ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isRead 
                ? null 
                : Border.all(color: AppColors.primaryBlue.withOpacity(0.3), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    typeIcon,
                    color: typeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                color: AppColors.darkGrey,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['message'],
                        style: TextStyle(
                          fontSize: 14,
                          color: isRead ? Colors.grey[600] : AppColors.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['time'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'assigned':
        return AppColors.primaryBlue;
      case 'progress':
        return AppColors.primaryOrange;
      case 'resolved':
        return AppColors.primaryGreen;
      case 'feedback':
        return AppColors.primaryPurple;
      default:
        return AppColors.darkGrey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'assigned':
        return Icons.assignment;
      case 'progress':
        return Icons.update;
      case 'resolved':
        return Icons.check_circle;
      case 'feedback':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }
}
