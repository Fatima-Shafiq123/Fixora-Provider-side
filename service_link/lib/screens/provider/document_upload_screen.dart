import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_link/services/storage/document_upload_service.dart';
import 'package:service_link/util/AppRoute.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final DocumentUploadService _uploadService = DocumentUploadService();
  final Set<DocumentType> _pendingUploads = {};

  Map<DocumentType, Map<String, dynamic>> _uploadedDocuments = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDocuments());
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final docs = await _uploadService.getUploadedDocuments();
      if (!mounted) return;
      setState(() {
        _uploadedDocuments = docs;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load documents: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAndUpload(DocumentType type, ImageSource source) async {
    final xfile = await _uploadService.pickImage(source: source);
    if (xfile == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
      return;
    }

    setState(() {
      _pendingUploads.add(type);
      _error = null;
    });

    try {
      final result = await _uploadService.uploadDocument(
        file: xfile,
        documentType: type,
      );

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
        await _loadDocuments();
      } else {
        setState(() {
          _error = result.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unexpected error uploading document: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error uploading document: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _pendingUploads.remove(type);
        });
      }
    }
  }

  Future<void> _submitForReview() async {
    if (!_hasAllRequiredDocs) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please upload all required documents before submitting'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final success = await _uploadService.submitDocumentsForReview();
    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documents submitted for review')),
      );

      /// 🚀 Navigate to Provider Dashboard Screen
      Navigator.pushReplacementNamed(
        context,
        Approutes.PROVIDER_DASHBOARD,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission failed')),
      );
    }
  }

  void _showUploadOptions(DocumentType type) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select from gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUpload(type, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndUpload(type, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool get _hasAllRequiredDocs {
    const requiredDocs = {
      DocumentType.cnicFront,
      DocumentType.cnicBack,
      DocumentType.profilePhoto,
      DocumentType.affidavit,
      DocumentType.guarantee,
    };
    return requiredDocs.every(_uploadedDocuments.containsKey);
  }

  String _displayName(DocumentType type) {
    switch (type) {
      case DocumentType.cnicFront:
        return 'CNIC Front';
      case DocumentType.cnicBack:
        return 'CNIC Back';
      case DocumentType.profilePhoto:
        return 'Profile Photo (Selfie)';
      case DocumentType.affidavit:
        return 'Affidavit';
      case DocumentType.guarantee:
        return 'Guarantee';
      case DocumentType.academicCertificate:
        return 'Academic / Skill Certificate';
      case DocumentType.otherCertificate:
        return 'Other Certificate';
    }
  }

  IconData _iconForDocument(DocumentType type) {
    switch (type) {
      case DocumentType.cnicFront:
      case DocumentType.cnicBack:
        return Icons.credit_card;
      case DocumentType.profilePhoto:
        return Icons.person;
      case DocumentType.affidavit:
      case DocumentType.guarantee:
      case DocumentType.academicCertificate:
      case DocumentType.otherCertificate:
        return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allDocuments = [
      DocumentType.cnicFront,
      DocumentType.cnicBack,
      DocumentType.profilePhoto,
      DocumentType.affidavit,
      DocumentType.guarantee,
      DocumentType.academicCertificate,
      DocumentType.otherCertificate,
    ];

    final uploadedCount =
        allDocuments.where(_uploadedDocuments.containsKey).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Upload'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDocuments,
        child: LayoutBuilder(builder: (context, constraints) {
          final isWeb = constraints.maxWidth > 600;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxWidth: isWeb ? 700 : double.infinity),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    Text(
                      'Upload the required KYC documents for verification.',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Progress: $uploadedCount / ${allDocuments.length} documents uploaded',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      ...allDocuments.map((type) => _buildDocumentCard(type)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _hasAllRequiredDocs && !_isSubmitting
                            ? _submitForReview
                            : null,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          _isSubmitting ? 'Submitting...' : 'Submit for review',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Approutes.PROVIDER_TERMS_CONDITIONS,
                          );
                        },
                        child: const Text(
                          'View Terms & Conditions',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending_review':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDocumentCard(DocumentType type) {
    final data = _uploadedDocuments[type];
    final isUploading = _pendingUploads.contains(type);
    final status = data?['status'] as String? ?? 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _statusColor(status).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _iconForDocument(type),
                  size: 28,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _displayName(type),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (data != null)
                  Icon(Icons.check_circle, color: _statusColor(status))
                else
                  const Icon(
                    Icons.hourglass_empty,
                    color: Color.fromARGB(255, 255, 42, 0),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (data != null && data['fileBase64'] != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  base64Decode(data['fileBase64']),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data['fileName'] ?? 'Uploaded document',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Status: ${status.replaceAll('_', ' ').toUpperCase()}',
                  style: TextStyle(
                    color: _statusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else if (data != null) ...[
              const SizedBox(height: 8),
              Text(
                data['fileName'] ?? 'Uploaded document',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Status: ${data['status'] ?? 'uploaded'}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUploading ? null : () => _showUploadOptions(type),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(data != null ? Icons.edit : Icons.upload_file),
                label: Text(
                  isUploading
                      ? 'UPLOADING...'
                      : (data != null ? 'Replace Document' : 'Upload Document'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
