import 'package:flutter/material.dart';
import 'package:service_link/util/AppRoute.dart';
import 'package:service_link/widgets/provider_drawer.dart';
import 'package:service_link/widgets/stats_card.dart';
import 'package:service_link/widgets/review_item.dart';
import 'package:service_link/widgets/section_header.dart';
import 'package:service_link/widgets/welcome_header.dart';
import 'package:service_link/widgets/bottom_nav_bar.dart';
import 'package:service_link/widgets/app_bar.dart';
import 'package:service_link/services/database/dashboard_service.dart';
import 'package:service_link/models/review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int _selectedIndex = 0;
  int _bottomNavIndex = 0;

  // Dashboard data
  final DashboardService _dashboardService = DashboardService();
  String _providerName = 'User';
  double _totalEarnings = 0.0;
  int _totalServices = 0;
  int _upcomingServices = 0;
  int _todayServices = 0;
  List<ReviewModel> _recentReviews = [];
  bool _isLoading = true;

  void _onDrawerItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        // Already on dashboard, no navigation needed
        break;
      case 1:
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_BOOKINGS);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_MY_SERVICES);
        break;
      case 3:
        // Navigate to profile page
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_PROFILE);
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Load all dashboard data from Firestore
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load provider name
      final name = await _dashboardService.getProviderName();

      // Load statistics
      final earnings = await _dashboardService.getTotalEarnings();
      final servicesCount = await _dashboardService.getTotalServicesCount();
      final upcomingCount = await _dashboardService.getUpcomingServicesCount();
      final todayCount = await _dashboardService.getTodayServicesCount();

      // Load recent reviews
      final reviews = await _dashboardService.getRecentReviews();

      // Update state with loaded data
      if (mounted) {
        setState(() {
          _providerName = name;
          _totalEarnings = earnings;
          _totalServices = servicesCount;
          _upcomingServices = upcomingCount;
          _todayServices = todayCount;
          _recentReviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Format date for reviews
  String _formatReviewDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd MMM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final averageRating = _recentReviews.isEmpty
        ? 0.0
        : _recentReviews.fold<double>(
                0.0, (sum, review) => sum + (review.rating ?? 0)) /
            _recentReviews.length;
    return WillPopScope(
      onWillPop: () async {
        // Show a confirmation dialog instead of just preventing back navigation
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Exit App'),
                content: const Text('Are you sure you want to exit the app?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Yes'),
                  ),
                ],
              ),
            ) ??
            false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const ServiceAppBar(
          title: 'Fixora',
        ),
        drawer: ProviderDrawer(
          selectedIndex: _selectedIndex,
          onItemSelected: _onDrawerItemSelected,
        ),
        // Add resizeToAvoidBottomInset to prevent overflow when keyboard appears
        resizeToAvoidBottomInset: true,
        // Use a SafeArea to respect system UI elements
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading dashboard data...'),
                  ],
                ),
              )
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WelcomeHeader(
                          userName: _providerName,
                          message: 'Here is your business snapshot',
                        ),
                        const SizedBox(height: 8),
                        _buildQuickActions(),
                        const SizedBox(height: 8),
                        _buildStatGrid(),
                        const SizedBox(height: 16),
                        _buildTodayBookingsCard(),
                        const SizedBox(height: 16),
                        _buildPendingRequestsCard(),
                        const SizedBox(height: 16),
                        _buildRatingSummary(averageRating),
                        SectionHeader(
                          title: 'Reviews',
                          onViewAllPressed: () {
                            Navigator.pushNamed(
                                context, Approutes.PROVIDER_REVIEWS);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _recentReviews.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Text('No reviews yet'),
                                  ),
                                )
                              : Column(
                                  children: _recentReviews.map((review) {
                                    return FutureBuilder<Map<String, dynamic>?>(
                                      future: _dashboardService
                                          .getUserData(review.clientId),
                                      builder: (context, snapshot) {
                                        final clientName =
                                            snapshot.data?['fullName'] ??
                                                'Client';
                                        final date =
                                            _formatReviewDate(review.createdAt);

                                        return ReviewItem(
                                          name: clientName,
                                          date: date,
                                          rating: review.rating,
                                          imageUrl:
                                              'assets/profiles/profile1.png',
                                          isAssetImage: true,
                                          reviewText: review.comment,
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _bottomNavIndex,
          onTap: _onBottomNavTap,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      _QuickAction(
        icon: Icons.pending_actions,
        label: 'My Jobs',
        route: Approutes.PROVIDER_BOOKINGS,
      ),
      _QuickAction(
        icon: Icons.work_outline,
        label: 'My Services',
        route: Approutes.PROVIDER_MY_SERVICES,
      ),
      _QuickAction(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Wallet',
        route: Approutes.PROVIDER_WALLET,
      ),
      _QuickAction(
        icon: Icons.person_outline,
        label: 'Profile',
        route: Approutes.PROVIDER_PROFILE,
      ),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final action = actions[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, action.route),
            child: Container(
              width: 120,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).cardColor,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(action.icon, color: Theme.of(context).primaryColor),
                  const Spacer(),
                  Text(
                    action.label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  value: 'Rs ${_totalEarnings.toStringAsFixed(0)}',
                  label: 'Total Earnings',
                  iconColor: const Color(0xFF5C5CFF),
                  icon: Icons.payments_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  value: _totalServices.toString(),
                  label: 'Services Live',
                  iconColor: Colors.indigo.shade400,
                  icon: Icons.home_repair_service_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatsCard(
                  value: _upcomingServices.toString(),
                  label: 'Pending Requests',
                  iconColor: Colors.orange.shade400,
                  icon: Icons.pending_actions_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  value: _todayServices.toString(),
                  label: 'Today\'s Jobs',
                  iconColor: Colors.green.shade400,
                  icon: Icons.today_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayBookingsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.shade50,
              child: Icon(Icons.event_available, color: Colors.green.shade600),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Bookings',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$_todayServices jobs scheduled today',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, Approutes.PROVIDER_BOOKINGS);
              },
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingRequestsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.orange.shade50,
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_outlined, color: Colors.orange),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pending Requests',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_upcomingServices customers are waiting for your response',
                    style: const TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.orange),
              onPressed: () {
                Navigator.pushNamed(context, Approutes.PROVIDER_BOOKINGS);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary(double avgRating) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).cardColor,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.amber.shade100,
              child: Text(
                avgRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rating Summary',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_recentReviews.length} recent reviews',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (avgRating / 5).clamp(0.0, 1.0),
                    minHeight: 6,
                    color: Colors.amber,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String route;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.route,
  });
}
