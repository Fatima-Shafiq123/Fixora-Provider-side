import 'package:flutter/material.dart';
import 'package:service_link/widgets/bottom_nav_bar.dart';
import 'package:service_link/widgets/customer_review_item.dart';
import 'package:service_link/util/AppRoute.dart';
import 'package:service_link/services/database/review_database.dart';
import 'package:service_link/services/database/user_database.dart';
import 'package:service_link/models/review_model.dart';
import 'package:intl/intl.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  int _bottomNavIndex = 0; // Default to home tab
  final ReviewDatabase _reviewDatabase = ReviewDatabase();
  final UserDatabase _userDatabase = UserDatabase();

  bool _isLoading = true;
  List<ReviewModel> _reviews = [];
  final Map<String, Map<String, dynamic>> _clientData = {};

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current provider's reviews
      final reviewsStream = _reviewDatabase.getCurrentProviderReviews();

      // Listen to the stream once to get the initial data
      final reviewsList = await reviewsStream.first;

      // Store the reviews
      setState(() {
        _reviews = reviewsList;
      });

      // Fetch client data for each review
      for (var review in reviewsList) {
        await _fetchClientData(review.clientId);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reviews: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchClientData(String clientId) async {
    try {
      if (!_clientData.containsKey(clientId)) {
        final user = await _userDatabase.getUser(clientId);
        if (user != null) {
          setState(() {
            _clientData[clientId] = {
              'fullName': user.fullName,
              'userName': user.userName,
            };
          });
        }
      }
    } catch (e) {
      print('Error fetching client data for $clientId: $e');
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM').format(date);
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
        // Navigate to profile page
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_PROFILE);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Review On Services',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushReplacementNamed(
              context, Approutes.PROVIDER_DASHBOARD),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Customer Review',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),

          // Reviews List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reviews.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No reviews yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Reviews from your clients will appear here',
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
                        itemCount: _reviews.length,
                        itemBuilder: (context, index) {
                          final review = _reviews[index];
                          final clientData = _clientData[review.clientId];
                          final clientName = clientData != null
                              ? clientData['fullName'] ?? 'Client'
                              : 'Client #${index + 1}';
                          // Use default profile image for now
                          const String defaultImage =
                              'assets/profiles/profile1.png';

                          return CustomerReviewItem(
                            customerName: clientName,
                            date: _formatDate(review.createdAt.toDate()),
                            rating: review.rating,
                            reviewText: review.comment,
                            imageUrl: defaultImage,
                            isAssetImage: true,
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
