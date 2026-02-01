import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:service_link/widgets/bottom_nav_bar.dart';
import 'package:service_link/models/booking_model.dart';
import 'package:service_link/services/database/booking_service.dart';
import 'package:service_link/util/AppRoute.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  int _bottomNavIndex = 0;
  final BookingService _bookingService = BookingService();
  List<BookingModel> _completedBookings = [];
  bool _isLoading = true;
  final Map<String, Map<String, dynamic>> _serviceData = {};
  final Map<String, Map<String, dynamic>> _clientData = {};

  @override
  void initState() {
    super.initState();
    _loadCompletedBookings();
  }

  Future<void> _loadCompletedBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get completed bookings for the current provider
      final bookings = await _bookingService.getProviderBookings(
        statusFilter: BookingStatus.completed.toString(),
      );
      
      setState(() {
        _completedBookings = bookings;
      });
      
      // Fetch service and client data for each booking
      for (var booking in bookings) {
        await _fetchServiceData(booking.serviceId);
        await _fetchClientData(booking.clientId);
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading completed bookings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _fetchServiceData(String serviceId) async {
    try {
      if (!_serviceData.containsKey(serviceId)) {
        final data = await _bookingService.getServiceDetails(serviceId);
        if (data != null) {
          setState(() {
            _serviceData[serviceId] = data;
          });
        }
      }
    } catch (e) {
      print('Error fetching service data for $serviceId: $e');
    }
  }
  
  Future<void> _fetchClientData(String clientId) async {
    try {
      if (!_clientData.containsKey(clientId)) {
        final data = await _bookingService.getClientDetails(clientId);
        if (data != null) {
          setState(() {
            _clientData[clientId] = data;
          });
        }
      }
    } catch (e) {
      print('Error fetching client data for $clientId: $e');
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
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_MY_SERVICES);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_PROFILE);
        break;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return WillPopScope(
      onWillPop: () async {
        // Navigate to provider dashboard instead of exiting or going back to login
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_DASHBOARD);
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Service History',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: isDarkMode ? Colors.black : Theme.of(context).primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacementNamed(context, Approutes.PROVIDER_DASHBOARD),
          ),
        ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _completedBookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No service history yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completed services will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _completedBookings.length,
                  itemBuilder: (context, index) {
                    final booking = _completedBookings[index];
                    final serviceData = _serviceData[booking.serviceId];
                    final clientData = _clientData[booking.clientId];
                    
                    final serviceTitle = serviceData != null 
                        ? serviceData['title'] ?? 'Unknown Service' 
                        : 'Unknown Service';
                    
                    final clientName = clientData != null 
                        ? clientData['fullName'] ?? 'Unknown Client' 
                        : 'Unknown Client';
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    serviceTitle,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8, 
                                    vertical: 4
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Completed',
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  clientName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    booking.clientAddress,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(booking.scheduledDate.toDate()),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  booking.scheduledTime,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Amount',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  'Rs ${booking.totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF5C5CFF),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
}
