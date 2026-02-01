import 'package:flutter/material.dart';
import 'package:service_link/widgets/app_bar.dart';
import 'package:service_link/widgets/bottom_nav_bar.dart';
import 'package:service_link/models/booking_model.dart';
import 'package:service_link/screens/provider/job_detail_screen.dart';
import 'package:service_link/services/database/booking_service.dart';
import 'package:service_link/util/AppRoute.dart';

class JobRequestsScreen extends StatefulWidget {
  const JobRequestsScreen({super.key});

  @override
  State<JobRequestsScreen> createState() => _JobRequestsScreenState();
}

class _JobRequestsScreenState extends State<JobRequestsScreen>
    with SingleTickerProviderStateMixin {
  int _bottomNavIndex = 1;
  final BookingService _bookingService = BookingService();
  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final bookings = await _bookingService.getProviderBookings();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onBottomNavTap(int index) {
    if (index == _bottomNavIndex) return;
    setState(() => _bottomNavIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_DASHBOARD);
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_MY_SERVICES);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_PROFILE);
        break;
    }
  }

  List<BookingModel> _byStatus(BookingStatus status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_DASHBOARD);
        return false;
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: ServiceAppBar(
            title: 'Job Requests',
            bottom: const TabBar(
              tabs: [
                Tab(text: 'New'),
                Tab(text: 'Active'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  children: [
                    _buildList(_byStatus(BookingStatus.pending)),
                    _buildList(_byStatus(BookingStatus.confirmed)),
                    _buildList(_byStatus(BookingStatus.completed)),
                  ],
                ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _bottomNavIndex,
            onTap: _onBottomNavTap,
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text('Nothing here yet'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return FutureBuilder<Map<String, dynamic>?>(
            future: _bookingService.getServiceDetails(booking.serviceId),
            builder: (context, serviceSnapshot) {
              final serviceData = serviceSnapshot.data;
              return FutureBuilder<Map<String, dynamic>?>(
                future: _bookingService.getClientDetails(booking.clientId),
                builder: (context, clientSnapshot) {
                  final clientData = clientSnapshot.data;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(serviceData?['title'] ?? 'Service'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(clientData?['fullName'] ?? 'Client'),
                          Text(
                            '${_bookingService.formatBookingDate(booking.scheduledDate)} • ${booking.scheduledTime}',
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Rs ${booking.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _statusChip(booking.status),
                        ],
                      ),
                      onTap: () async {
                        final result = await Navigator.pushNamed(
                          context,
                          Approutes.PROVIDER_JOB_DETAIL,
                          arguments: JobDetailArguments(
                            booking: booking,
                            clientData: clientData,
                            serviceData: serviceData,
                          ),
                        );
                        if (result == true) {
                          _loadBookings();
                        }
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusChip(BookingStatus status) {
    Color color;
    String label;
    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        label = 'New';
        break;
      case BookingStatus.confirmed:
        color = Colors.blue;
        label = 'Active';
        break;
      case BookingStatus.completed:
        color = Colors.green;
        label = 'Done';
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
        break;
    }
    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}
