import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_link/util/AppRoute.dart';
import 'package:service_link/util/provider_status_service.dart';
import 'package:service_link/widgets/splash_content.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ProviderStatusService _statusService = ProviderStatusService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final user = _auth.currentUser;
    final onboardingComplete = await _statusService.isOnboardingComplete();

    if (!mounted) return;

    if (user == null) {
      final targetRoute = onboardingComplete
          ? Approutes.PROVIDER_LOGIN
          : Approutes.PROVIDER_ONBOARDING;
      _navigateTo(targetRoute);
      return;
    }

    final documentStatus = await _statusService.getDocumentStatus();
    if (!mounted) return;

    switch (documentStatus) {
      case ProviderDocumentStatus.notUploaded:
        _navigateTo(Approutes.PROVIDER_DOCUMENT_UPLOAD);
        break;
      case ProviderDocumentStatus.approved:
        _navigateTo(Approutes.PROVIDER_DASHBOARD);
        break;
      case ProviderDocumentStatus.pending:
        _navigateTo(Approutes.PROVIDER_DASHBOARD);
        break;
    }
  }

  void _navigateTo(String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return const SplashContent();
  }
}
