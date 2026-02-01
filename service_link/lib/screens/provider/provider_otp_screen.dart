import 'package:flutter/material.dart';
import 'package:service_link/util/AppRoute.dart';
import 'package:service_link/util/provider_status_service.dart';
import 'package:service_link/screens/provider/pending_verification_screen.dart';

class ProviderOtpArguments {
  final String contact;
  final bool isFromSignup;

  const ProviderOtpArguments({
    required this.contact,
    this.isFromSignup = false,
  });
}

class ProviderOtpScreen extends StatefulWidget {
  final String contact;
  final bool isFromSignup;

  const ProviderOtpScreen({
    super.key,
    required this.contact,
    this.isFromSignup = false,
  });

  @override
  State<ProviderOtpScreen> createState() => _ProviderOtpScreenState();
}

class _ProviderOtpScreenState extends State<ProviderOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  String? _error;
  final ProviderStatusService _statusService = ProviderStatusService();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      setState(() => _error = 'Enter the 6-digit code sent to you.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    if (_otpController.text == '123456') {
      _resolveNextStep();
    } else {
      setState(() {
        _isVerifying = false;
        _error = 'Invalid code. Try 123456 for demo.';
      });
    }
  }

  Future<void> _resolveNextStep() async {
    final docStatus = await _statusService.getDocumentStatus();
    if (!mounted) return;

    switch (docStatus) {
      case ProviderDocumentStatus.notUploaded:
        Navigator.pushReplacementNamed(
            context, Approutes.PROVIDER_DOCUMENT_UPLOAD);
        break;
      case ProviderDocumentStatus.pending:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PendingVerificationScreen()),
        );
        break;
      case ProviderDocumentStatus.approved:
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_DASHBOARD);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Verification Code',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a 6-digit code to ${widget.contact}.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              maxLength: 6,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                errorText: _error,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isVerifying
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Demo: OTP resent (use 123456).'),
                          ),
                        );
                      },
                child: const Text('Resend Code'),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOtp,
                child: _isVerifying
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Verify & Continue',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
