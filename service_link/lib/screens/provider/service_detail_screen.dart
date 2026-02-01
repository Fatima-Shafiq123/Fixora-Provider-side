import 'package:flutter/material.dart';
import 'package:service_link/widgets/bottom_nav_bar.dart';
import 'package:service_link/util/AppRoute.dart';
import 'package:service_link/services/database/service_service.dart';
import 'package:service_link/models/service_model.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;

  const ServiceDetailScreen({
    super.key,
    required this.serviceId,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  int _bottomNavIndex = 2; // My Services tab
  final ServiceService _serviceService = ServiceService();
  
  ServiceModel? _service;
  bool _isLoading = true;
  List<Map<String, dynamic>> _reviews = [];
  
  @override
  void initState() {
    super.initState();
    _loadServiceDetails();
  }
  
  Future<void> _loadServiceDetails() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load service details
      final service = await _serviceService.getServiceById(widget.serviceId);
      
      // Load reviews for this service
      final reviews = await _serviceService.getReviewsByServiceId(widget.serviceId);
      
      setState(() {
        _service = service;
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading service details: $e');
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
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_MY_SERVICES);
        break;
      case 3:
        // Navigate to profile if implemented
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to My Services screen instead of going back to user screens
        Navigator.pushReplacementNamed(context, Approutes.PROVIDER_MY_SERVICES);
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _service == null
              ? const Center(child: Text('Service not found'))
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title bar
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context, 
                                    Approutes.PROVIDER_MY_SERVICES
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Service Detail',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  // Navigate to edit screen
                                  Navigator.pushNamed(
                                    context,
                                    Approutes.PROVIDER_EDIT_SERVICE,
                                    arguments: widget.serviceId,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Service image
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                          ),
                          child: _service!.images.isNotEmpty && 
                                 _service!.images.first.startsWith('http')
                              ? Image.network(
                                  _service!.images.first,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/service1.png',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                              : Image.asset(
                                  'assets/service1.png',
                                  fit: BoxFit.cover,
                                ),
                        ),

                        const SizedBox(height: 16),

                        // Service Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _service!.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Rs ${_service!.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF5C5CFF),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _service!.priceType == 'hourly' ? '/ hour' : '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _service!.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        
                        // Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _service!.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Gallery
                        if (_service!.images.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Gallery',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {},
                                      child: const Text('View All'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _service!.images.length,
                                    itemBuilder: (context, index) {
                                      final imageUrl = _service!.images[index];
                                      final isAssetImage = !imageUrl.startsWith('http');
                                      
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: isAssetImage
                                              ? Image.asset(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Image.asset(
                                                      'assets/service1.png',
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Reviews
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Reviews',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text('View All'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _reviews.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          'No reviews yet',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: _reviews.map((review) {
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 16),
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 20,
                                                    backgroundImage: review['isAssetImage']
                                                        ? AssetImage(review['imageUrl'])
                                                        : NetworkImage(review['imageUrl']) as ImageProvider,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          review['name'],
                                                          style: const TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          review['date'],
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star,
                                                        color: Colors.amber,
                                                        size: 16,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        review['rating'].toString(),
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                review['text'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
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
}
