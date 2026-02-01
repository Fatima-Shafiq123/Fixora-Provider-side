import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_link/models/user_model.dart';
import 'package:service_link/services/storage/document_upload_service.dart';
import 'package:service_link/util/logger.dart';
import 'package:service_link/util/security_utils.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DocumentUploadService _uploadService = DocumentUploadService();

  bool _isLoading = false;
  bool _hasChanges = false;

  // Profile picture
  String? _profileBase64;
  File? _selectedProfileImage;
  bool _isUploadingProfileImage = false;

  late TextEditingController _fullNameController;
  late TextEditingController _userNameController;
  late TextEditingController _phoneController;
  late TextEditingController _serviceCategoryController;
  late TextEditingController _experienceController;
  late TextEditingController _hourlyRateController;

  @override
  void initState() {
    super.initState();

    _fullNameController = TextEditingController(text: widget.userData.fullName);
    _userNameController = TextEditingController(text: widget.userData.userName);
    _phoneController =
        TextEditingController(text: widget.userData.contactNumber);
    _serviceCategoryController =
        TextEditingController(text: widget.userData.serviceCategory ?? '');
    _experienceController =
        TextEditingController(text: widget.userData.experience ?? '');
    _hourlyRateController =
        TextEditingController(text: widget.userData.hourlyRate ?? '');

    _profileBase64 = widget.userData.profileImageBase64;

    // Detect changes
    _fullNameController.addListener(_onFormChanged);
    _userNameController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _serviceCategoryController.addListener(_onFormChanged);
    _experienceController.addListener(_onFormChanged);
    _hourlyRateController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    final hasChanges = _fullNameController.text != widget.userData.fullName ||
        _userNameController.text != widget.userData.userName ||
        _phoneController.text != widget.userData.contactNumber ||
        _serviceCategoryController.text !=
            (widget.userData.serviceCategory ?? '') ||
        _experienceController.text != (widget.userData.experience ?? '') ||
        _hourlyRateController.text != (widget.userData.hourlyRate ?? '') ||
        _selectedProfileImage != null ||
        (_profileBase64 != widget.userData.profileImageBase64);

    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _userNameController.dispose();
    _phoneController.dispose();
    _serviceCategoryController.dispose();
    _experienceController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _selectProfileImage() async {
    try {
      final XFile? pickedFile =
          await _uploadService.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedProfileImage = File(pickedFile.path);
          _isUploadingProfileImage = true;
          _hasChanges = true;
        });

        // Convert image to Base64
        String base64Image;
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          base64Image = base64Encode(bytes);
        } else {
          final bytes = await File(pickedFile.path).readAsBytes();
          base64Image = base64Encode(bytes);
        }

        // Save Base64 to Firestore
        final userId = widget.userData.userId;
        await _firestore.collection('providers').doc(userId).update({
          'profileImageBase64': base64Image,
        });

        setState(() {
          _profileBase64 = base64Image;
          _isUploadingProfileImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploadingProfileImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _profileImageWidget() {
    if (_selectedProfileImage != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(_selectedProfileImage!),
      );
    } else if (_profileBase64 != null && _profileBase64!.isNotEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: MemoryImage(base64Decode(_profileBase64!)),
      );
    } else {
      return CircleAvatar(
        radius: 60,
        child:
            Icon(Icons.person, size: 60, color: Theme.of(context).primaryColor),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> updatedData = {
        'fullName': SecurityUtils.sanitizeInput(_fullNameController.text),
        'userName': SecurityUtils.sanitizeInput(_userNameController.text),
        'contactNumber': SecurityUtils.sanitizeInput(_phoneController.text),
      };

      if (_profileBase64 != null) {
        updatedData['profileImageBase64'] = _profileBase64;
      }

      if (_serviceCategoryController.text.trim().isNotEmpty) {
        updatedData['serviceCategory'] =
            SecurityUtils.sanitizeInput(_serviceCategoryController.text);
      }

      if (_experienceController.text.trim().isNotEmpty) {
        updatedData['experience'] =
            SecurityUtils.sanitizeInput(_experienceController.text);
      }

      if (_hourlyRateController.text.trim().isNotEmpty) {
        updatedData['hourlyRate'] =
            SecurityUtils.sanitizeInput(_hourlyRateController.text);
      }

      await _firestore
          .collection('providers')
          .doc(widget.userData.userId)
          .update(updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error updating profile', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? helperText,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: isDarkMode
            ? Colors.grey.shade800.withOpacity(0.5)
            : Colors.grey.shade100,
      ),
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
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
        Divider(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.grey.shade300,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: const Text(
                'Save',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _isUploadingProfileImage
                            ? null
                            : _selectProfileImage,
                        child: Stack(
                          children: [
                            _profileImageWidget(),
                            if (!_isUploadingProfileImage)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionHeader('Personal Information'),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Full Name cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _userNameController,
                      label: 'Username',
                      icon: Icons.alternate_email,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Phone number cannot be empty';
                        }
                        if (!SecurityUtils.isValidPhoneNumber(value)) {
                          return 'Invalid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (widget.userData.userType == UserType.provider) ...[
                      _buildSectionHeader('Provider Information'),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _serviceCategoryController,
                        label: 'Service Category',
                        icon: Icons.category,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _experienceController,
                        label: 'Experience (years)',
                        icon: Icons.work,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _hourlyRateController,
                        label: 'Hourly Rate',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 32),
                    Center(
                      child: ElevatedButton(
                        onPressed:
                            (_isLoading || !_hasChanges) ? null : _saveProfile,
                        child: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
