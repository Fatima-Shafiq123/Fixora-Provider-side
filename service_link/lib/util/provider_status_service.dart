import 'package:shared_preferences/shared_preferences.dart';

enum ProviderDocumentStatus { notUploaded, pending, approved }

class ProviderStatusService {
  ProviderStatusService._internal();
  static final ProviderStatusService _instance =
      ProviderStatusService._internal();

  factory ProviderStatusService() => _instance;

  static const _onboardingKey = 'provider_onboarding_complete';
  static const _documentStatusKey = 'provider_document_status';

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  Future<ProviderDocumentStatus> getDocumentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString(_documentStatusKey);
    switch (status) {
      case 'pending':
        return ProviderDocumentStatus.pending;
      case 'approved':
        return ProviderDocumentStatus.approved;
      case 'not_uploaded':
      default:
        return ProviderDocumentStatus.notUploaded;
    }
  }

  Future<void> setDocumentStatus(ProviderDocumentStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_documentStatusKey, _statusToString(status));
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingKey);
    await prefs.remove(_documentStatusKey);
  }

  String _statusToString(ProviderDocumentStatus status) {
    switch (status) {
      case ProviderDocumentStatus.pending:
        return 'pending';
      case ProviderDocumentStatus.approved:
        return 'approved';
      case ProviderDocumentStatus.notUploaded:
        return 'not_uploaded';
    }
  }
}

