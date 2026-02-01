import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_link/widgets/app_bar.dart';
import 'package:service_link/services/database/service_service.dart';
import 'package:service_link/services/storage/image_upload_service.dart';
import 'package:service_link/screens/provider/location_picker_screen.dart';
import 'package:service_link/models/service_model.dart';
import 'package:service_link/util/logger.dart';
import 'package:service_link/util/validation_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final ServiceService _serviceService = ServiceService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  // Form controllers
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Dropdown options
  final List<String> _durationOptions = [
    '30 Min',
    '01 Hour',
    '02 Hours',
    '03 Hours',
    '04 Hours'
  ];
  String _selectedDuration = '01 Hour';

  // Image selection
  String? _selectedImagePath;
  XFile? _selectedImageFile;
  bool _isUploading = false;
  bool _isUploadingImage = false;

  // Location data
  LatLng? _selectedLocation;
  String? _selectedLocationAddress;

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    try {
      final imageFile = await _imageUploadService.pickImageWithSource(context);
      if (imageFile != null) {
        setState(() {
          _selectedImageFile = imageFile;
          _isUploadingImage = true;
        });

        // Upload image to Firebase Storage (we'll get serviceId after creation)
        // For now, just store the file
        setState(() {
          _isUploadingImage = false;
        });
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error uploading image', e, stackTrace);
      setState(() {
        _isUploadingImage = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerScreen(
          initialLocation: _selectedLocation,
          initialAddress: _selectedLocationAddress,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result['location'] as LatLng?;
        _selectedLocationAddress = result['address'] as String?;
      });
    }
  }

  Future<void> _saveService() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      try {
        String? imageUrl;
        if (_selectedImageFile != null) {
          imageUrl = await _imageUploadService.uploadServiceImage(
              _selectedImageFile!, '');
        }

        final newService = ServiceModel(
          providerId: _serviceService.currentUserId ?? '',
          title: ValidationUtils.sanitizeText(_titleController.text),
          description:
              ValidationUtils.sanitizeText(_descriptionController.text),
          category: 'General',
          price: double.parse(_priceController.text),
          priceType: 'fixed',
          images: imageUrl != null ? [imageUrl] : [],
          isAvailable: true,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          rating: 0.0,
          totalReviews: 0,
          location: _selectedLocationAddress,
        );

        final serviceId = await _serviceService.addService(newService);

        if (serviceId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception('Failed to save service to Firestore.');
        }
      } catch (e, stackTrace) {
        AppLogger.error('Error adding service', e, stackTrace);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey.shade100,
      appBar: ServiceAppBar(
        title: 'Add New Service',
        backgroundColor: isDarkMode ? Colors.black : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service image selection
              Center(
                child: GestureDetector(
                  onTap: _selectImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _isUploadingImage
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF5C5CFF),
                            ),
                          )
                        : _selectedImageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(_selectedImageFile!.path),
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _selectedImagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      _selectedImagePath!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 40,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Add Photo',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Service title
              _buildInputLabel('Service Title'),
              _buildTextFormField(
                controller: _titleController,
                hintText: 'e.g. TV Wall Mount Installation',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a service title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Price and discount row
              Row(
                children: [
                  // Price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('Price (Rs)'),
                        _buildTextFormField(
                          controller: _priceController,
                          hintText: 'e.g. 500',
                          keyboardType: TextInputType.number,
                          prefixText: 'Rs ',
                          validator: ValidationUtils.validatePrice,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Discount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('Discount (%)'),
                        _buildTextFormField(
                          controller: _discountController,
                          hintText: 'e.g. 10',
                          keyboardType: TextInputType.number,
                          suffixText: '%',
                          validator: ValidationUtils.validateDiscount,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Duration dropdown
              _buildInputLabel('Service Duration'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDuration,
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    dropdownColor:
                        isDarkMode ? Colors.grey.shade900 : Colors.white,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedDuration = newValue!;
                      });
                    },
                    items: _durationOptions.map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Location selection
              _buildInputLabel('Service Location'),
              GestureDetector(
                onTap: _selectLocation,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDarkMode
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedLocationAddress ?? 'Tap to select location',
                          style: TextStyle(
                            color: _selectedLocationAddress != null
                                ? (isDarkMode ? Colors.white : Colors.black87)
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              _buildInputLabel('Service Description'),
              _buildTextFormField(
                controller: _descriptionController,
                hintText: 'Describe your service...',
                maxLines: 4,
                validator: (value) =>
                    ValidationUtils.validateDescription(value ?? ''),
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _saveService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'SAVE SERVICE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? prefixText,
    String? suffixText,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
          fontSize: 14,
        ),
        prefixText: prefixText,
        suffixText: suffixText,
        filled: true,
        fillColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: TextStyle(
          color: isDarkMode ? Colors.red.shade300 : Colors.red,
        ),
      ),
      validator: validator,
    );
  }
}
