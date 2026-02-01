import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseConnectionChecker {
  // Check if Firebase is properly initialized
  static Future<bool> isFirebaseInitialized() async {
    try {
      Firebase.app();
      print('✅ Firebase is initialized');
      return true;
    } catch (e) {
      print('❌ Firebase is not initialized: $e');
      return false;
    }
  }

  // Test Firestore connection
  static Future<bool> testFirestoreConnection() async {
    try {
      // Get Firebase project info
      final projectInfo = getFirebaseProjectInfo();
      print('📌 Connected to Firebase project: ${projectInfo['projectId']}');
      
      // Try to access Firestore
      final firestore = FirebaseFirestore.instance;
      
      // Try a simple read operation
      await firestore.collection('test_connection').limit(1).get();
      print('✅ Successfully connected to Firestore');
      
      return true;
    } catch (e) {
      print('❌ Firestore connection test failed: $e');
      return false;
    }
  }

  // Get Firebase project info
  static Map<String, String> getFirebaseProjectInfo() {
    try {
      final FirebaseApp app = Firebase.app();
      final FirebaseOptions options = app.options;
      
      return {
        'projectId': options.projectId,
        'appId': options.appId,
      };
    } catch (e) {
      print('❌ Failed to get Firebase project info: $e');
      return {
        'projectId': 'Unknown',
        'appId': 'Unknown',
      };
    }
  }

  // Show a simple dialog with Firebase connection status
  static void showConnectionStatus(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Checking Firebase Connection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Please wait...'),
          ],
        ),
      ),
    );
    
    try {
      // Check Firebase initialization
      final isInitialized = await isFirebaseInitialized();
      
      // Test Firestore connection
      final isConnected = await testFirestoreConnection();
      
      // Get project info
      final projectInfo = getFirebaseProjectInfo();
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show results
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Firebase Connection Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Project ID: ${projectInfo['projectId']}'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    isInitialized ? Icons.check_circle : Icons.error,
                    color: isInitialized ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text('Firebase Initialization: ${isInitialized ? 'Success' : 'Failed'}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isConnected ? Icons.check_circle : Icons.error,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text('Firestore Connection: ${isConnected ? 'Success' : 'Failed'}'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to check Firebase connection: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
