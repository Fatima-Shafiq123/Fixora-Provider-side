import 'package:flutter/material.dart';
import 'package:service_link/widgets/app_bar.dart';
import 'package:service_link/widgets/bottom_nav_bar.dart';
import 'package:service_link/widgets/my_service_item.dart';
import 'package:service_link/screens/provider/service_detail_screen.dart';
import 'package:service_link/screens/provider/edit_service_screen.dart';
import 'package:service_link/util/AppRoute.dart';
import 'package:service_link/services/database/service_service.dart';
import 'package:service_link/models/service_model.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  int _bottomNavIndex = 2; // My Services tab

  final ServiceService _serviceService = ServiceService();
  List<ServiceModel> _services = [];
  bool _isLoading = true;
  final Set<String> _availabilityUpdatesInProgress = {};

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if user is logged in
      final userId = _serviceService.currentUserId;
      print('Current user ID: $userId');

      if (userId == null) {
        print('User not logged in or user ID is null');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to view your services'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Fetch services from Firestore
      final services = await _serviceService.getProviderServices();
      print('Fetched ${services.length} services for provider $userId');

      // Debug: print each service
      for (var service in services) {
        print('Service ID: ${service.serviceId}, Title: ${service.title}');
      }

      setState(() {
        _services = services;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading services: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading services: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onBottomNavTap(int index) {
    if (index == _bottomNavIndex) {
      return; // Don't navigate if already on this tab
    }

    setState(() {
      _bottomNavIndex = index;
    });

    // Navigate to different screens based on bottom nav selection
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_DASHBOARD);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_BOOKINGS);
        break;
      case 2:
        // Already on my services, no navigation needed
        break;
      case 3:
        // Navigate to profile page
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_PROFILE);
        break;
    }
  }

  void _navigateToServiceDetail(String serviceId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(serviceId: serviceId),
      ),
    );
  }

  void _navigateToAddService() async {
    final result =
        await Navigator.pushNamed(context, Approutes.PROVIDER_ADD_SERVICE);

    // If the user added a service, reload the services list
    if (result != null) {
      _loadServices(); // Reload services from Firestore
    }
  }

  void _navigateToEditService(String serviceId) async {
    // Navigate to edit screen with just the serviceId
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditServiceScreen(
          serviceId: serviceId,
        ),
      ),
    );

    // Reload services if changes were made
    if (result != null) {
      _loadServices();
    }
  }

  void _confirmDeleteService(String serviceId, String serviceTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$serviceTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteService(serviceId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteService(String serviceId) async {
    try {
      final success = await _serviceService.deleteService(serviceId);

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service deleted successfully'),
            backgroundColor: Color(0xFF5C5CFF),
          ),
        );

        // Reload services
        _loadServices();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete service'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error deleting service: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while deleting the service'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to provider dashboard instead of exiting
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_DASHBOARD);
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: ServiceAppBar(
          title: 'My Services',
          actions: [
            IconButton(
              icon: const Icon(Icons.schedule),
              tooltip: 'Availability',
              onPressed: () {
                Navigator.pushNamed(
                    context, Approutes.PROVIDER_SERVICE_AVAILABILITY);
              },
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _navigateToAddService,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _services.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.work_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No services available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _navigateToAddService,
                          icon: const Icon(Icons.add),
                          label: const Text('ADD SERVICE'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5C5CFF),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      // Use a default image if no images are available
                      final String imageUrl = service.images.isNotEmpty
                          ? service.images.first
                          : 'assets/service1.png';

                      return MyServiceItem(
                        id: service.serviceId!,
                        title: service.title,
                        price: service.price,
                        discountPercentage:
                            0, // Add this to your service model if needed
                        imageUrl: imageUrl,
                        isAssetImage: !imageUrl
                            .startsWith('http'), // Use asset if not a URL
                        rating: service.rating,
                        onTap: () =>
                            _navigateToServiceDetail(service.serviceId!),
                        onEdit: () =>
                            _navigateToEditService(service.serviceId!),
                        onDelete: () => _confirmDeleteService(
                            service.serviceId!, service.title),
                        isActive: service.isAvailable,
                        onAvailabilityChanged: service.serviceId == null ||
                                _availabilityUpdatesInProgress
                                    .contains(service.serviceId)
                            ? null
                            : (value) => _toggleAvailability(service, value),
                      );
                    },
                  ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _bottomNavIndex,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }

  Future<void> _toggleAvailability(
      ServiceModel service, bool isAvailable) async {
    if (service.serviceId == null) return;
    setState(() {
      _availabilityUpdatesInProgress.add(service.serviceId!);
    });
    final success = await _serviceService.updateAvailability(
        service.serviceId!, isAvailable);
    if (mounted) {
      setState(() {
        _availabilityUpdatesInProgress.remove(service.serviceId!);
        if (success) {
          _services = _services
              .map((s) => s.serviceId == service.serviceId
                  ? s.copyWith(isAvailable: isAvailable)
                  : s)
              .toList();
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Service marked as ${isAvailable ? 'available' : 'offline'}'
              : 'Failed to update availability'),
        ),
      );
    }
  }
}
