import 'package:flutter_test/flutter_test.dart';
import 'package:service_link/util/validation_utils.dart';

void main() {
  group('ValidationUtils', () {
    test('validateEmail should return null for valid email', () {
      expect(ValidationUtils.validateEmail('test@example.com'), isNull);
    });

    test('validateEmail should return error for invalid email', () {
      expect(ValidationUtils.validateEmail('invalid-email'), isNotNull);
    });

    test('validateEmail should return error for empty email', () {
      expect(ValidationUtils.validateEmail(null), isNotNull);
      expect(ValidationUtils.validateEmail(''), isNotNull);
    });

    test('validatePassword should return null for valid password', () {
      expect(ValidationUtils.validatePassword('password123'), isNull);
    });

    test('validatePassword should return error for short password', () {
      expect(ValidationUtils.validatePassword('12345'), isNotNull);
    });

    test('validatePhoneNumber should return null for valid phone', () {
      expect(ValidationUtils.validatePhoneNumber('03001234567'), isNull);
    });

    test('validatePhoneNumber should return error for invalid phone', () {
      expect(ValidationUtils.validatePhoneNumber('123'), isNotNull);
    });

    test('validateRequired should return null for non-empty value', () {
      expect(ValidationUtils.validateRequired('value', 'Field'), isNull);
    });

    test('validateRequired should return error for empty value', () {
      expect(ValidationUtils.validateRequired(null, 'Field'), isNotNull);
      expect(ValidationUtils.validateRequired('', 'Field'), isNotNull);
    });

    test('validatePrice should return null for valid price', () {
      expect(ValidationUtils.validatePrice('100'), isNull);
    });

    test('validatePrice should return error for invalid price', () {
      expect(ValidationUtils.validatePrice('abc'), isNotNull);
      expect(ValidationUtils.validatePrice('-10'), isNotNull);
    });
  });
}

