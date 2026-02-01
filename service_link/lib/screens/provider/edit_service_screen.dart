import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:service_link/widgets/app_bar.dart';
import 'package:service_link/services/database/service_service.dart';
import 'package:service_link/services/storage/image_upload_service.dart';
import 'package:service_link/screens/provider/location_picker_screen.dart';
import 'package:service_link/util/logger.dart';
import 'package:service_link/util/validation_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditServiceScreen extends StatefulWidget {
  final String serviceId;

  const EditServiceScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Service data
  bool _isLoading = true;
  final ServiceService _serviceService = ServiceService();
  final ImageUploadService _imageUploadService = ImageUploadService();

  // Default duration if not available in the model
  String _selectedDuration = '01 Hour';

  // Location data
  LatLng? _selectedLocation;
  String? _selectedLocationAddress;

  // Dropdown options
  final List<String> _durationOptions = [
    '30 Min',
    '01 Hour',
    '02 Hours',
    '03 Hours',
    '04 Hours'
  ];

  // Image selection
  String? _selectedImagePath;
  XFile? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  bool _isUploading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadServiceData();
  }

  Future<void> _loadServiceData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch service data from Firestore
      final service = await _serviceService.getServiceById(widget.serviceId);

      if (service != null) {
        // Update controllers with service data
        _titleController.text = service.title;
        _priceController.text = service.price.toString();
        _discountController.text = '0'; // Add discount to your model if needed
        _descriptionController.text = service.description;

        // Set selected duration (using a default since duration is not in the model)
        _selectedDuration = _durationOptions[1];

        // Set selected image if available
        if (service.images.isNotEmpty) {
          _selectedImagePath = service.images.first;
        }

        // Set location if available
        if (service.location != null) {
          // Parse location string to LatLng if stored as string
          // You may need to adjust this based on how location is stored
        }

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      } else {
        // Handle service not found
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service not found')),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error loading service data', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load service data')),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    try {
      final imageFile = await _imageUploadService.pickImageWithSource(context);
      if (imageFile != null) {
        if (!mounted) return;
        final bytes = await imageFile.readAsBytes();
        setState(() {
          _selectedImageFile = imageFile;
          _selectedImageBytes = bytes;
          _isUploadingImage = true;
        });

        // Upload image to Firebase Storage
        final downloadUrl = await _imageUploadService.uploadServiceImage(
          imageFile,
          widget.serviceId,
        );

        if (!mounted) return;
        setState(() {
          _selectedImagePath = downloadUrl;
          _isUploadingImage = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

    if (result != null && mounted) {
      setState(() {
        _selectedLocation = result['location'] as LatLng?;
        _selectedLocationAddress = result['address'] as String?;
      });
    }
  }

  Future<void> _updateService() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isUploading = true;
      });

      try {
        String? imageUrl = _selectedImagePath;
        if (_selectedImageFile != null) {
          imageUrl = await _imageUploadService.uploadServiceImage(
              _selectedImageFile!, widget.serviceId);
        }

        final updatedData = <String, dynamic>{
          'title': ValidationUtils.sanitizeText(_titleController.text),
          'price': double.parse(_priceController.text),
          'description':
              ValidationUtils.sanitizeText(_descriptionController.text),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (imageUrl != null) {
          updatedData['images'] = [imageUrl];
        }

        if (_selectedLocationAddress != null) {
          updatedData['location'] = _selectedLocationAddress;
        }

        await _serviceService.updateServiceData(widget.serviceId, updatedData);

        if (mounted) {
          Navigator.pop(context, true); // Return success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating service: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: const ServiceAppBar(title: 'Edit Service'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: const ServiceAppBar(
        title: 'Edit Service',
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
                        : _selectedImagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: _selectedImagePath!.startsWith('http')
                                    ? Image.network(
                                        _selectedImagePath!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(Icons.error);
                                        },
                                      )
                                    : _selectedImagePath!
                                            .startsWith('data:image/')
                                        ? Image.memory(
                                            _decodeDataUri(_selectedImagePath!),
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            _selectedImagePath!,
                                            fit: BoxFit.cover,
                                          ),
                              )
                            : _selectedImageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      _selectedImageBytes!,
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
                                        'Change Photo',
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
                validator: (value) =>
                    ValidationUtils.validateRequired(value, 'Service title'),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDuration,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFF5C5CFF)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedLocationAddress ?? 'Tap to select location',
                          style: TextStyle(
                            color: _selectedLocationAddress != null
                                ? Colors.black87
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
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

              // Update button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _updateService,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C5CFF),
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
                          'UPDATE SERVICE',
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
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
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),
        prefixText: prefixText,
        suffixText: suffixText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF5C5CFF)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
      ),
      validator: validator,
    );
  }

  Uint8List _decodeDataUri(String uri) {
    final commaIndex = uri.indexOf(',');
    final base64Part = commaIndex != -1 ? uri.substring(commaIndex + 1) : uri;
    return base64Decode(base64Part);
  }
}
