import 'package:service_link/util/security_utils.dart';

/// Centralized validation utilities
class ValidationUtils {
  /// Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!SecurityUtils.isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value, {bool isSignUp = false}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (isSignUp) {
      final strength = SecurityUtils.validatePasswordStrength(value);
      if (strength == PasswordStrength.weak) {
        return 'Password is too weak. Use uppercase, lowercase, numbers, and special characters';
      }
    }
    return null;
  }

  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!SecurityUtils.isValidPhoneNumber(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate name (full name, username)
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (value.length > 50) {
      return '$fieldName must be less than 50 characters';
    }
    // Sanitize and check for invalid characters
    final sanitized = SecurityUtils.sanitizeInput(value);
    if (sanitized != value) {
      return '$fieldName contains invalid characters';
    }
    return null;
  }

  /// Validate price/amount
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    if (price < 0) {
      return 'Price cannot be negative';
    }
    if (price > 1000000) {
      return 'Price is too high';
    }
    return null;
  }

  /// Validate description
  static String? validateDescription(String? value, {int minLength = 10, int maxLength = 1000}) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    if (value.length < minLength) {
      return 'Description must be at least $minLength characters';
    }
    if (value.length > maxLength) {
      return 'Description must be less than $maxLength characters';
    }
    return null;
  }

  /// Validate CNIC format
  static String? validateCNIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'CNIC is required';
    }
    // Remove dashes for validation
    final digits = value.replaceAll('-', '');
    if (digits.length != 13) {
      return 'CNIC must be 13 digits';
    }
    if (!RegExp(r'^\d{13}$').hasMatch(digits)) {
      return 'CNIC must contain only numbers';
    }
    return null;
  }

  /// Validate experience (years)
  static String? validateExperience(String? value) {
    if (value == null || value.isEmpty) {
      return 'Experience is required';
    }
    final years = int.tryParse(value);
    if (years == null) {
      return 'Please enter a valid number';
    }
    if (years < 0) {
      return 'Experience cannot be negative';
    }
    if (years > 50) {
      return 'Please enter a realistic experience value';
    }
    return null;
  }

  /// Validate discount percentage
  static String? validateDiscount(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    final discount = int.tryParse(value);
    if (discount == null) {
      return 'Please enter a valid percentage';
    }
    if (discount < 0 || discount > 100) {
      return 'Discount must be between 0 and 100';
    }
    return null;
  }

  /// Sanitize and validate text input
  static String sanitizeText(String input) {
    return SecurityUtils.sanitizeInput(input);
  }

  /// Validate file size (in bytes)
  static String? validateFileSize(int fileSize, {int maxSizeMB = 10}) {
    final maxSize = maxSizeMB * 1024 * 1024;
    if (fileSize > maxSize) {
      return 'File size exceeds ${maxSizeMB}MB limit';
    }
    return null;
  }

  /// Validate file type
  static String? validateFileType(String fileName, List<String> allowedExtensions) {
    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'File type not allowed. Allowed types: ${allowedExtensions.join(", ")}';
    }
    return null;
  }
}

