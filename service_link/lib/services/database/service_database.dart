import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service_link/models/service_model.dart';
import 'package:service_link/services/database/database_service.dart';

class ServiceDatabase extends DatabaseService {
  final String _collection = 'services';

  // Add a new service
  Future<DocumentReference> addService(ServiceModel service) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    final data = service.toMap();
    // Add server timestamps for created and updated
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    return await addDocument(_collection, data);
  }

  // Update a service
  Future<void> updateService(String serviceId, Map<String, dynamic> data) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    // Add server timestamp for updated
    data['updatedAt'] = FieldValue.serverTimestamp();

    return await updateDocument(_collection, serviceId, data);
  }

  // Delete a service
  Future<void> deleteService(String serviceId) async {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    // First check if the service belongs to the current user
    final serviceDoc = await getDocument(_collection, serviceId);
    if (serviceDoc.exists && serviceDoc.get('providerId') == currentUserId) {
      return await deleteDocument(_collection, serviceId);
    } else {
      throw Exception('Not authorized to delete this service');
    }
  }

  // Get a specific service
  Future<ServiceModel?> getService(String serviceId) async {
    final doc = await getDocument(_collection, serviceId);
    if (doc.exists) {
      return ServiceModel.fromFirestore(doc);
    }
    return null;
  }

  // Get all services by current provider
  Stream<List<ServiceModel>> getProviderServices() {
    if (!isAuthenticated) {
      throw Exception('User not authenticated');
    }

    return getFilteredOrderedCollection(
      _collection,
      field: 'providerId',
      isEqualTo: currentUserId,
      orderBy: 'createdAt',
      descending: true,
    ).map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get all services by category
  Stream<List<ServiceModel>> getServicesByCategory(String category) {
    return getFilteredOrderedCollection(
      _collection,
      field: 'category',
      isEqualTo: category,
      orderBy: 'createdAt',
      descending: true,
    ).map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get all services
  Stream<List<ServiceModel>> getAllServices() {
    return getOrderedCollection(
      _collection,
      orderBy: 'createdAt',
      descending: true,
    ).map((snapshot) {
      return snapshot.docs
          .map((doc) => ServiceModel.fromFirestore(doc))
          .toList();
    });
  }

  // Search services by title or description
  Future<List<ServiceModel>> searchServices(String query) async {
    // Firestore doesn't support direct text search, so we'll fetch all services
    // and filter them on the client side
    final snapshot = await collection(_collection).get();
    
    final searchTerms = query.toLowerCase().split(' ');
    
    return snapshot.docs
        .map((doc) => ServiceModel.fromFirestore(doc))
        .where((service) {
          final title = service.title.toLowerCase();
          final description = service.description.toLowerCase();
          
          // Check if any search term is contained in title or description
          return searchTerms.any((term) => 
            title.contains(term) || description.contains(term));
        })
        .toList();
  }
}
