# Admin Side Setup Guide

## Overview
This guide explains how to set up and use the Admin Panel for managing provider documents and approvals.

---

## 🔐 **1. Creating Admin Account**

### Step 1: Create Admin User in Firebase Console

1. Go to **Firebase Console** → **Authentication** → **Users**
2. Click **Add User**
3. Enter admin email and password
4. Click **Create**

### Step 2: Assign Admin Role

1. Go to **Firestore Database** → **Data**
2. Create a new collection: `roles`
3. Create a document with ID = **Admin's Firebase UID** (from Authentication)
4. Add field:
   ```json
   {
     "role": "admin",
     "email": "admin@example.com",
     "createdAt": [timestamp],
     "lastLogin": [timestamp]
   }
   ```

### Step 3: Verify Admin Access

- Admin can now log in using the Admin Login screen
- System will verify role before granting access

---

## 📱 **2. Admin Screens**

### Admin Login (`/admin/login`)
- Email/password authentication
- Role verification
- Redirects to dashboard on success

### Admin Dashboard (`/admin/dashboard`)
- Statistics cards:
  - Total Providers
  - Pending Review
  - Approved
  - Rejected
- Quick action buttons
- Refresh functionality

### Provider List (`/admin/provider-list`)
- Tabs: Pending, Approved, Rejected
- Shows provider name, category, submission date
- Deadline countdown for pending reviews
- Tap to view details

### Provider Detail (`/admin/provider-detail`)
- Provider information
- Category and subcategories
- Document list with status
- Approve/Reject buttons for each document
- Approve Provider button (when all documents approved)
- Reject Provider option

### Document Viewer (`/admin/document-viewer`)
- View images inline
- Open PDFs in external viewer
- Download and view documents

---

## ⚙️ **3. Admin Service Functions**

### Dashboard Statistics
```dart
final stats = await adminService.getDashboardStats();
// Returns: {total, pending, approved, rejected}
```

### Get Providers by Status
```dart
Stream<List<ProviderDocumentStatus>> providers = 
  adminService.getProvidersByStatus('pending');
```

### Approve Document
```dart
await adminService.approveDocument(providerId, DocumentType.affidavit);
```

### Reject Document
```dart
await adminService.rejectDocument(
  providerId, 
  DocumentType.cnic, 
  'Reason for rejection'
);
```

### Approve Provider
```dart
await adminService.approveProvider(providerId);
// Only works if all documents are approved
```

### Reject Provider
```dart
await adminService.rejectProvider(providerId, 'Rejection reason');
```

---

## 🔒 **4. Security Rules**

### Firestore Rules
- Admin role checked via `roles/{uid}` collection
- Admins can read/write all provider data
- Audit logs only accessible to admins

### Storage Rules
- Document viewing requires admin authentication
- Files served through Firebase Storage URLs

---

## 📋 **5. Provider Approval Workflow**

### Step 1: Provider Submits Documents
- Provider uploads: Affidavit, Guarantee, CNIC, Academic Certificate
- Submission date recorded
- Review deadline set to 7 days

### Step 2: Admin Reviews Documents
- Admin views provider in "Pending Review" tab
- Opens provider detail page
- Reviews each document individually
- Approves or rejects each document with reason

### Step 3: Approve Provider
- When all documents are approved:
  - "Approve Provider" button becomes available
  - Admin clicks to approve
  - Provider account activated
  - Services enabled

### Step 4: Notification (Future Enhancement)
- Provider receives notification
- Finder can now see provider services

---

## ⏰ **6. One-Week Review Period**

### Implementation
- Submission date stored when documents uploaded
- Review deadline = submission date + 7 days
- Dashboard shows countdown
- Overdue providers highlighted in red

### Auto-Approval Policy (Optional)
Currently, providers must be manually approved. To implement auto-approval:
1. Create Cloud Function
2. Check daily for overdue reviews
3. Auto-approve if all documents approved
4. Send notification

---

## 📊 **7. Audit Logging**

All admin actions are logged:
- Document approvals/rejections
- Provider approvals/rejections
- Timestamp and admin ID
- Metadata (provider name, reasons, etc.)

Location: `auditLogs` collection in Firestore

---

## 🚀 **8. Running the Admin App**

### Option 1: Separate Admin App
Create a separate Flutter app with admin-only routes.

### Option 2: Same App with Role Check
Check user role on login and route accordingly:
```dart
if (await adminAuthService.isAdmin()) {
  Navigator.pushReplacementNamed(context, Approutes.ADMIN_DASHBOARD);
} else {
  Navigator.pushReplacementNamed(context, Approutes.PROVIDER_DASHBOARD);
}
```

---

## 📦 **9. Dependencies Added**

```yaml
http: ^1.1.0          # For downloading documents
open_file: ^3.5.0    # For opening PDFs in external viewer
```

---

## ✅ **10. Testing Checklist**

- [ ] Create admin account in Firebase
- [ ] Assign admin role in Firestore
- [ ] Login as admin
- [ ] View dashboard statistics
- [ ] Navigate to provider list
- [ ] View provider details
- [ ] Approve/reject individual documents
- [ ] Approve provider (all documents approved)
- [ ] Reject provider
- [ ] View documents (images and PDFs)
- [ ] Check audit logs

---

## 🔧 **11. Troubleshooting**

### "Access denied" on login
- Verify admin role exists in `roles/{uid}` collection
- Check role field equals "admin"
- Ensure Firebase Auth user exists

### Documents not loading
- Check Firebase Storage rules
- Verify document URLs are valid
- Check network connectivity

### Statistics not updating
- Pull to refresh dashboard
- Check Firestore queries
- Verify provider documents structure

---

## 📝 **12. Future Enhancements**

1. **Notifications**: FCM integration for approval notifications
2. **Email Notifications**: Send emails on approval/rejection
3. **Bulk Actions**: Approve/reject multiple providers
4. **Advanced Filtering**: Filter by category, date, etc.
5. **Export Reports**: Export provider data to CSV/PDF
6. **Document Templates**: Provide templates for providers
7. **Auto-Approval**: Automatic approval after 7 days if all documents approved
8. **Document Verification**: AI-based document verification

---

## 🎯 **Quick Start**

1. **Create Admin Account**:
   ```bash
   # In Firebase Console
   Authentication → Add User → admin@example.com
   ```

2. **Set Admin Role**:
   ```bash
   # In Firestore
   Collection: roles
   Document ID: [admin-uid]
   Data: { role: "admin", email: "admin@example.com" }
   ```

3. **Run App**:
   ```bash
   flutter run
   ```

4. **Navigate to Admin Login**:
   - Use route: `/admin/login`
   - Or add button in main app

5. **Login and Start Managing**:
   - Email: admin@example.com
   - Password: [your password]

---

**Status**: ✅ Admin Panel Fully Implemented
**Last Updated**: [Current Date]

