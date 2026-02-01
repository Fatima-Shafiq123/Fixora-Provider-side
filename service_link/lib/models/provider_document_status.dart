import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_link/services/storage/document_upload_service.dart';

enum DocumentStatus {
  pending,
  approved,
  rejected,
}

class ProviderDocument {
  final DocumentType type;
  final String? url;
  final DocumentStatus status;
  final String? rejectionReason;
  final DateTime? uploadedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;

  ProviderDocument({
    required this.type,
    this.url,
    required this.status,
    this.rejectionReason,
    this.uploadedAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  factory ProviderDocument.fromMap(
      Map<String, dynamic> map, DocumentType type) {
    return ProviderDocument(
      type: type,
      url: map['url'],
      status: _statusFromString(map['status'] ?? 'pending'),
      rejectionReason: map['rejectionReason'],
      uploadedAt: map['uploadedAt']?.toDate(),
      reviewedAt: map['reviewedAt']?.toDate(),
      reviewedBy: map['reviewedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'status': _statusToString(status),
      'rejectionReason': rejectionReason,
      'uploadedAt': uploadedAt,
      'reviewedAt': reviewedAt,
      'reviewedBy': reviewedBy,
    };
  }

  static DocumentStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return DocumentStatus.approved;
      case 'rejected':
        return DocumentStatus.rejected;
      default:
        return DocumentStatus.pending;
    }
  }

  static String _statusToString(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.approved:
        return 'approved';
      case DocumentStatus.rejected:
        return 'rejected';
      default:
        return 'pending';
    }
  }

  String get typeString {
    switch (type) {
      case DocumentType.affidavit:
        return 'Affidavit';
      case DocumentType.guarantee:
        return 'Guarantee';
      case DocumentType.cnicFront:
        return 'CNIC Front';
      case DocumentType.cnicBack:
        return 'CNIC Back';
      case DocumentType.profilePhoto:
        return 'Profile Photo';
      case DocumentType.academicCertificate:
        return 'Academic Certificate';
      case DocumentType.otherCertificate:
        return 'Other Certificate';
    }
  }
}

class ProviderDocumentStatus {
  final String providerId;
  final String providerName;
  final String? providerEmail;
  final String category;
  final List<String> subcategories;
  final Map<DocumentType, ProviderDocument> documents;
  final bool isApproved;
  final bool servicesEnabled;
  final DateTime? submissionDate;
  final DateTime? approvalDate;
  final DateTime? reviewDeadline;
  final String? rejectionReason;

  ProviderDocumentStatus({
    required this.providerId,
    required this.providerName,
    this.providerEmail,
    required this.category,
    required this.subcategories,
    required this.documents,
    required this.isApproved,
    required this.servicesEnabled,
    this.submissionDate,
    this.approvalDate,
    this.reviewDeadline,
    this.rejectionReason,
  });

  factory ProviderDocumentStatus.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse documents
    final documentsMap = <DocumentType, ProviderDocument>{};
    final documentsData = data['kyc_documents'] ?? {};

    for (var type in DocumentType.values) {
      final typeString = _documentTypeToString(type);
      if (documentsData.containsKey(typeString)) {
        documentsMap[type] = ProviderDocument.fromMap(
          Map<String, dynamic>.from(documentsData[typeString]),
          type,
        );
      }
    }

    final submissionDate = data['submissionDate']?.toDate();
    final reviewDeadline = submissionDate?.add(const Duration(days: 7));

    return ProviderDocumentStatus(
      providerId: doc.id,
      providerName: data['fullName'] ?? 'Unknown',
      providerEmail: data['email'],
      category: data['serviceCategory'] ?? '',
      subcategories: List<String>.from(data['subcategories'] ?? []),
      documents: documentsMap,
      isApproved: data['isApproved'] ?? false,
      servicesEnabled: data['servicesEnabled'] ?? false,
      submissionDate: submissionDate,
      approvalDate: data['approvalDate']?.toDate(),
      reviewDeadline: reviewDeadline,
      rejectionReason: data['rejectionReason'],
    );
  }

  static String _documentTypeToString(DocumentType type) {
    switch (type) {
      case DocumentType.affidavit:
        return 'affidavit';
      case DocumentType.guarantee:
        return 'guarantee';
      case DocumentType.cnicFront:
        return 'cnicFront';
      case DocumentType.cnicBack:
        return 'cnicBack';
      case DocumentType.profilePhoto:
        return 'profilePhoto';
      case DocumentType.academicCertificate:
        return 'academicCertificate';
      case DocumentType.otherCertificate:
        return 'otherCertificate';
    }
  }

  bool get allDocumentsApproved {
    if (documents.isEmpty) return false;
    return documents.values
        .every((doc) => doc.status == DocumentStatus.approved);
  }

  bool get hasRejectedDocuments {
    return documents.values.any((doc) => doc.status == DocumentStatus.rejected);
  }

  int get daysUntilDeadline {
    if (reviewDeadline == null) return 0;
    final now = DateTime.now();
    final difference = reviewDeadline!.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  bool get isOverdue {
    if (reviewDeadline == null) return false;
    return DateTime.now().isAfter(reviewDeadline!);
  }
}
