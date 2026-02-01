import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_link/models/user_model.dart';
import 'package:service_link/util/AppRoute.dart';
import 'package:service_link/util/provider_status_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ProviderStatusService _statusService = ProviderStatusService();
  
  bool _isLoading = true;
  UserModel? _userData;
  ProviderDocumentStatus _documentStatus =
      ProviderDocumentStatus.notUploaded;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        final docStatus = await _statusService.getDocumentStatus();
        // Get user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userData = UserModel.fromFirestore(userDoc);
            _isLoading = false;
            _documentStatus = docStatus;
          });
        } else {
          setState(() {
            _isLoading = false;
            _documentStatus = docStatus;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _documentStatus = ProviderDocumentStatus.notUploaded;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
        _documentStatus = ProviderDocumentStatus.notUploaded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return WillPopScope(
      // Handle back button press
      onWillPop: () async {
        // Navigate to dashboard instead of going back
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_DASHBOARD);
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Navigate to dashboard when back button is pressed
              Navigator.pushReplacementNamed(context, Approutes.PROVIDER_DASHBOARD);
            },
          ),
        ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _userData == null 
          ? const Center(child: Text('User data not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header with avatar
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userData!.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userData!.userType == UserType.provider ? 'Service Provider' : 'Client',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade600,
                          ),
                        ),
                        if (_userData!.serviceCategory != null && _userData!.serviceCategory!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              _userData!.serviceCategory!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Personal Information Section
                  _buildSectionHeader('Personal Information'),
                  const SizedBox(height: 16),
                  _buildInfoItem(Icons.email, 'Email', _userData!.email),
                  _buildInfoItem(Icons.phone, 'Phone', _userData!.contactNumber),
                  _buildInfoItem(Icons.person, 'Username', _userData!.userName),
                  
                  const SizedBox(height: 32),
                  
                  // Provider Specific Information
                  if (_userData!.userType == UserType.provider) ...[
                    _buildSectionHeader('Provider Information'),
                    const SizedBox(height: 16),
                    if (_userData!.experience != null)
                      _buildInfoItem(Icons.work, 'Experience', '${_userData!.experience} Years'),
                    if (_userData!.hourlyRate != null)
                      _buildInfoItem(Icons.attach_money, 'Hourly Rate', _userData!.hourlyRate!),
                    _buildInfoItem(Icons.star, 'Rating', '${_userData!.rating ?? 0.0} ★'),
                    _buildInfoItem(Icons.reviews, 'Total Reviews', '${_userData!.totalReviews ?? 0}'),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Account Information
                  _buildSectionHeader('Account Information'),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    Icons.calendar_today, 
                    'Member Since', 
                    _formatTimestamp(_userData!.createdAt)
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader('Verification Status'),
                  const SizedBox(height: 16),
                  _buildInfoItem(
                    Icons.verified_user,
                    'Documents',
                    _documentStatusLabel(),
                  ),
                  if (_documentStatus != ProviderDocumentStatus.approved)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, Approutes.PROVIDER_DOCUMENT_UPLOAD);
                        },
                        child: Text(
                          _documentStatus ==
                                  ProviderDocumentStatus.notUploaded
                              ? 'Upload Documents'
                              : 'Check Review Status',
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Edit Profile Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Navigate to edit profile screen
                        final updated = await Navigator.pushNamed(
                          context, 
                          Approutes.PROVIDER_EDIT_PROFILE,
                          arguments: _userData,
                        );
                        
                        // If profile was updated, reload the data
                        if (updated == true) {
                          _loadUserData();
                        }
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Divider(color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.grey.shade700 
            : Colors.grey.shade300),
      ],
    );
  }
  
  Widget _buildInfoItem(IconData icon, String label, String value) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.day}/${date.month}/${date.year}';
  }

  String _documentStatusLabel() {
    switch (_documentStatus) {
      case ProviderDocumentStatus.notUploaded:
        return 'Pending upload';
      case ProviderDocumentStatus.pending:
        return 'Under review';
      case ProviderDocumentStatus.approved:
        return 'Approved';
    }
  }
}
