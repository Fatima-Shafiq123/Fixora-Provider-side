import 'package:flutter/material.dart';
import 'package:service_link/widgets/custom_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Upload Terms & Conditions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              context,
              '1. Purpose of Data Collection',
              'We collect your identity documents (Affidavit, Guarantee, CNIC, and Academic Certificate) for the following purposes:\n\n'
              '• Identity verification to ensure the authenticity of service providers\n'
              '• Fraud prevention and security measures\n'
              '• Compliance with legal and regulatory requirements\n'
              '• Maintaining trust and safety in our marketplace\n'
              '• Background verification for service quality assurance',
            ),

            _buildSection(
              context,
              '2. Storage and Retention',
              '• Your documents will be stored securely in encrypted format\n'
              '• Documents will be retained for a period of 5 years from the date of upload or until account deletion, whichever is earlier\n'
              '• After the retention period, documents will be securely deleted in accordance with our data retention policy\n'
              '• You may request deletion of your documents at any time, subject to legal and regulatory requirements',
            ),

            _buildSection(
              context,
              '3. Access and Confidentiality',
              'Your documents will only be accessible to:\n\n'
              '• Authorized personnel and compliance officers\n'
              '• Automated verification systems with secure access controls\n'
              '• Legal and regulatory authorities when required by law\n\n'
              'We maintain strict confidentiality and do not share your documents with third parties except as required by law or with your explicit consent.',
            ),

            _buildSection(
              context,
              '4. Security Measures',
              'We implement the following security measures to protect your documents:\n\n'
              '• TLS encryption for data transmission\n'
              '• Encrypted storage at rest\n'
              '• Secure access controls and authentication\n'
              '• Regular security audits and monitoring\n'
              '• Compliance with industry-standard security practices',
            ),

            _buildSection(
              context,
              '5. Your Rights',
              'You have the right to:\n\n'
              '• Access your uploaded documents\n'
              '• Request correction of any inaccurate information\n'
              '• Withdraw consent and request deletion of documents (subject to legal requirements)\n'
              '• File a complaint if you believe your data is being mishandled\n'
              '• Receive information about how your documents are being used',
            ),

            _buildSection(
              context,
              '6. Consent and Acknowledgment',
              'By uploading your documents, you acknowledge and consent to:\n\n'
              '• The collection, storage, and processing of your documents as described in these terms\n'
              '• Verification checks and background screening\n'
              '• The retention period specified above\n'
              '• Access by authorized personnel for verification purposes',
            ),

            _buildSection(
              context,
              '7. Dispute Resolution',
              'If you have any concerns or disputes regarding the handling of your documents:\n\n'
              '• Contact our support team at support@servicelink.com\n'
              '• We will investigate and respond within 7 business days\n'
              '• You may file a formal complaint through our dispute resolution process\n'
              '• All disputes will be handled in accordance with applicable laws and regulations',
            ),

            _buildSection(
              context,
              '8. Changes to Terms',
              'We reserve the right to update these terms and conditions. You will be notified of any significant changes:\n\n'
              '• Via email to your registered email address\n'
              '• Through in-app notifications\n'
              '• Updated terms will be effective 30 days after notification\n'
              '• Continued use of the service after changes constitutes acceptance',
            ),

            const SizedBox(height: 32),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'By proceeding, you acknowledge that you have read, understood, and agree to these Terms & Conditions.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: Colors.grey.shade800,
                ),
          ),
        ],
      ),
    );
  }
}

