import 'package:flutter/material.dart';
import '../utils/clear_firebase_data.dart';
import '../utils/constants.dart';

/// ⚠️ WARNING: This screen allows clearing all Firebase data
/// Only use for development/testing purposes!
/// 
/// To use this screen:
/// 1. Add a route to it in your app (temporarily)
/// 2. Navigate to it
/// 3. Use the buttons to clear data
/// 4. Remove the route when done
class AdminClearDataScreen extends StatefulWidget {
  const AdminClearDataScreen({super.key});

  @override
  State<AdminClearDataScreen> createState() => _AdminClearDataScreenState();
}

class _AdminClearDataScreenState extends State<AdminClearDataScreen> {
  bool _isClearing = false;
  String _statusMessage = '';
  bool _showConfirmDialog = false;

  Future<void> _clearFirestore() async {
    final confirmed = await _showConfirmationDialog(
      'Clear Firestore Data',
      'This will delete ALL documents in ALL Firestore collections. This cannot be undone!',
    );

    if (!confirmed) return;

    setState(() {
      _isClearing = true;
      _statusMessage = 'Clearing Firestore data...';
    });

    try {
      await ClearFirebaseData.clearAllFirestoreData();
      setState(() {
        _statusMessage = '✅ Firestore data cleared successfully!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isClearing = false;
      });
    }
  }

  Future<void> _clearCollection(String collectionName) async {
    final confirmed = await _showConfirmationDialog(
      'Clear Collection',
      'This will delete all documents in the "$collectionName" collection. This cannot be undone!',
    );

    if (!confirmed) return;

    setState(() {
      _isClearing = true;
      _statusMessage = 'Clearing $collectionName...';
    });

    try {
      await ClearFirebaseData.clearCollection(collectionName);
      setState(() {
        _statusMessage = '✅ Collection "$collectionName" cleared!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isClearing = false;
      });
    }
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clear Firebase Data'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200, width: 2),
              ),
              child: const Column(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 48),
                  SizedBox(height: 8),
                  Text(
                    '⚠️ DANGER ZONE ⚠️',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This will permanently delete data from Firebase!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Status Message
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _statusMessage.contains('✅')
                      ? Colors.green.shade50
                      : _statusMessage.contains('❌')
                          ? Colors.red.shade50
                          : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusMessage.contains('✅')
                        ? Colors.green
                        : _statusMessage.contains('❌')
                            ? Colors.red
                            : Colors.blue,
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(fontSize: 14),
                ),
              ),

            // Clear Specific Collections
            const Text(
              'Clear Specific Collections:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildClearButton(
              'Clear "issues" Collection',
              'Delete all complaint/issue documents',
              () => _clearCollection('issues'),
            ),
            const SizedBox(height: 8),
            _buildClearButton(
              'Clear "adminusers" Collection',
              'Delete all admin user documents',
              () => _clearCollection('adminusers'),
            ),
            const SizedBox(height: 8),
            _buildClearButton(
              'Clear "users" Collection',
              'Delete all user profile documents',
              () => _clearCollection('users'),
            ),

            const SizedBox(height: 24),

            // Clear All Firestore
            const Text(
              'Clear All Firestore Data:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildClearButton(
              '🗑️ Clear ALL Firestore Data',
              'Delete all documents in all collections',
              _clearFirestore,
              isDangerous: true,
            ),

            const SizedBox(height: 24),

            // Authentication Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Clear Authentication Users',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'To delete authentication users, use Firebase Console:',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '1. Go to Firebase Console',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    '2. Authentication > Users',
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    '3. Select all users and click Delete',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton(
    String title,
    String subtitle,
    VoidCallback onPressed, {
    bool isDangerous = false,
  }) {
    return ElevatedButton.icon(
      onPressed: _isClearing ? null : onPressed,
      icon: _isClearing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(isDangerous ? Icons.delete_forever : Icons.delete_outline),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDangerous ? Colors.red : Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        alignment: Alignment.centerLeft,
      ),
    );
  }
}






