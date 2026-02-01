import 'package:flutter/material.dart';
import 'package:service_link/util/AppRoute.dart';
import 'package:service_link/util/provider_status_service.dart';
import 'package:service_link/util/validation_utils.dart';
import 'package:service_link/services/auth/provider_auth_service.dart';

class ProviderSignupScreen extends StatefulWidget {
  const ProviderSignupScreen({super.key});

  @override
  State<ProviderSignupScreen> createState() => _ProviderSignupScreenState();
}

class _ProviderSignupScreenState extends State<ProviderSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _selectedCategory = 'Cleaning'; // Default category
  final List<String> _categories = [
    'Cleaning',
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Gardening',
    'Moving',
    'Other'
  ];

  // Subcategories mapping
  final Map<String, List<String>> _subcategoriesMap = {
    'Cleaning': [
      'House Cleaning',
      'Office Cleaning',
      'Deep Cleaning',
      'Carpet Cleaning',
      'Window Cleaning'
    ],
    'Plumbing': [
      'Leak Repair',
      'Drain Cleaning',
      'Water Heater',
      'Pipe Installation',
      'Bathroom Fittings'
    ],
    'Electrical': [
      'Wiring',
      'Light Installation',
      'Appliance Repair',
      'Panel Maintenance',
      'Generator Service'
    ],
    'Carpentry': [
      'Furniture Repair',
      'Cabinet Installation',
      'Door & Window Repair',
      'Custom Woodwork',
      'Flooring Installation'
    ],
    'Painting': [
      'Interior Painting',
      'Exterior Painting',
      'Wallpaper Installation',
      'Texture Work',
      'Furniture Painting'
    ],
    'Gardening': [
      'Lawn Mowing',
      'Tree Trimming',
      'Garden Design',
      'Irrigation System',
      'Plant Care'
    ],
    'Moving': [
      'Local Moving',
      'Long Distance',
      'Packing Services',
      'Furniture Assembly',
      'Storage Solutions'
    ],
    'Other': [
      'General Maintenance',
      'Handyman Services',
      'Consultation',
      'Emergency Services',
      'Custom Service'
    ],
  };

  final Set<String> _selectedSubcategories = {};

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _cnicController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _userNameController.dispose();
    _contactNumberController.dispose();
    _experienceController.dispose();
    _hourlyRateController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Profile Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFF218907),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 24),

                // Headline
                const Text(
                  "Hello Provider!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Subheadline
                const Text(
                  "Create Your Account For\nBetter Experience",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 32),

                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  validator: (value) =>
                      ValidationUtils.validateName(value, 'Full Name'),
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    suffixIcon: const Icon(Icons.person_outline,
                        color: Colors.transparent),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Username
                TextFormField(
                  controller: _userNameController,
                  validator: (value) =>
                      ValidationUtils.validateName(value, 'Username'),
                  decoration: InputDecoration(
                    labelText: 'User Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    suffixIcon: const Icon(Icons.person_outline,
                        color: Colors.transparent),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  validator: ValidationUtils.validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'provider@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    suffixIcon: const Icon(Icons.check_circle_outline),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: const Color(0xFF218907).withOpacity(0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: const Color(0xFF218907).withOpacity(0.5)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 16),

                // Phone Number
                TextFormField(
                  controller: _contactNumberController,
                  validator: ValidationUtils.validatePhoneNumber,
                  decoration: InputDecoration(
                    labelText: 'Contact Number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    suffixIcon:
                        const Icon(Icons.phone, color: Colors.transparent),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 16),
                // CNIC / ID
                TextField(
                  controller: _cnicController,
                  decoration: InputDecoration(
                    labelText: 'CNIC / ID Number',
                    prefixIcon: const Icon(Icons.credit_card),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  validator: (value) =>
                      ValidationUtils.validatePassword(value, isSignUp: true),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),

                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                ),

                const SizedBox(height: 16),

                // Service Category
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Service Category',
                    prefixIcon: const Icon(Icons.category_outlined),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  initialValue: _selectedCategory,
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                      _selectedSubcategories
                          .clear(); // Reset subcategories when category changes
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Subcategories Multi-Select
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.category, color: Color(0xFF218907)),
                          const SizedBox(width: 8),
                          Text(
                            'Service Subcategories',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Select 1-5 subcategories (${_selectedSubcategories.length} selected)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (_subcategoriesMap[_selectedCategory] ?? [])
                            .map((subcategory) {
                          final isSelected =
                              _selectedSubcategories.contains(subcategory);
                          return FilterChip(
                            label: Text(subcategory),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  if (_selectedSubcategories.length < 5) {
                                    _selectedSubcategories.add(subcategory);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Maximum 5 subcategories allowed'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } else {
                                  _selectedSubcategories.remove(subcategory);
                                }
                              });
                            },
                            selectedColor:
                                const Color(0xFF218907).withOpacity(0.2),
                            checkmarkColor: const Color(0xFF218907),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF218907)
                                  : Colors.grey.shade700,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Experience
                TextFormField(
                  controller: _experienceController,
                  validator: ValidationUtils.validateExperience,
                  decoration: InputDecoration(
                    labelText: 'Experience (years)',
                    prefixIcon: const Icon(Icons.work_outline),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),

                // Hourly Rate
                TextFormField(
                  controller: _hourlyRateController,
                  validator: ValidationUtils.validatePrice,
                  decoration: InputDecoration(
                    labelText: 'Hourly Rate',
                    prefixIcon: const Icon(Icons.attach_money),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 32),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Validate form
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      // Validate subcategories
                      if (_selectedSubcategories.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Please select at least one subcategory'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      // Sanitize inputs
                      final sanitizedFullName = ValidationUtils.sanitizeText(
                          _fullNameController.text);
                      final sanitizedUserName = ValidationUtils.sanitizeText(
                          _userNameController.text);

                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF218907),
                          ),
                        ),
                      );

                      // Attempt signup
                      final authService = ProviderAuthService();
                      final result = await authService.signUpWithEmailPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                        fullName: sanitizedFullName,
                        userName: sanitizedUserName,
                        contactNumber: _contactNumberController.text.trim(),
                        experience: _experienceController.text.trim(),
                        serviceCategory: _selectedCategory,
                        hourlyRate: _hourlyRateController.text.isNotEmpty
                            ? _hourlyRateController.text.trim()
                            : null,
                        subcategories: _selectedSubcategories.toList(),
                      );

                      // Close loading dialog
                      Navigator.pop(context);

                      if (result.success) {
                        await ProviderStatusService().setDocumentStatus(
                            ProviderDocumentStatus.notUploaded);
                        // Show a success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        Navigator.pushReplacementNamed(
                            context, Approutes.PROVIDER_DOCUMENT_UPLOAD);
                      } else {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result.message),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF218907),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'NEXT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Approutes.PROVIDER_LOGIN);
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: Color(0xFF218907),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}
