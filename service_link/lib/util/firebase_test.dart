import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseConnectionTest {
  // Test Firebase initialization
  static Future<bool> isFirebaseInitialized() async {
    try {
      // Check if Firebase is initialized
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
      // Try to access Firestore
      final firestore = FirebaseFirestore.instance;
      
      // Create a test document
      final testDocRef = firestore.collection('test_connection').doc('test_doc');
      
      // Write data
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      await testDocRef.set({
        'timestamp': timestamp,
        'message': 'Test connection successful',
      });
      print('✅ Successfully wrote to Firestore');
      
      // Read data
      final docSnapshot = await testDocRef.get();
      if (docSnapshot.exists) {
        print('✅ Successfully read from Firestore: ${docSnapshot.data()}');
        
        // Clean up - delete test document
        await testDocRef.delete();
        print('✅ Successfully deleted test document');
        
        return true;
      } else {
        print('❌ Failed to read from Firestore: Document does not exist');
        return false;
      }
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
        'apiKey': options.apiKey,
      };
    } catch (e) {
      print('❌ Failed to get Firebase project info: $e');
      return {
        'projectId': 'Unknown',
        'appId': 'Unknown',
        'apiKey': 'Unknown',
      };
    }
  }

  // Run all tests
  static Future<void> runAllTests(BuildContext context) async {
    final results = <String, bool>{};
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Testing Firebase Connection'),
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
      // Test Firebase initialization
      results['Firebase Initialization'] = await isFirebaseInitialized();
      
      // Test Firestore connection
      results['Firestore Connection'] = await testFirestoreConnection();
      
      // Get project info
      final projectInfo = getFirebaseProjectInfo();
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show results
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Firebase Connection Test Results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Project ID: ${projectInfo['projectId']}'),
              const SizedBox(height: 8),
              Text('App ID: ${projectInfo['appId']}'),
              const SizedBox(height: 16),
              const Text('Test Results:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...results.entries.map((entry) => Row(
                children: [
                  Icon(
                    entry.value ? Icons.check_circle : Icons.error,
                    color: entry.value ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text('${entry.key}: ${entry.value ? 'Success' : 'Failed'}'),
                ],
              )),
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
          content: Text('Failed to run tests: $e'),
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
