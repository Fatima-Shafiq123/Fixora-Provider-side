import 'package:flutter/material.dart';
import 'package:service_link/widgets/star_rating.dart';

class CustomerReviewItem extends StatelessWidget {
  final String customerName;
  final String date;
  final double rating;
  final String reviewText;
  final String? imageUrl;
  final bool isAssetImage;

  const CustomerReviewItem({
    super.key,
    required this.customerName,
    required this.date,
    required this.rating,
    required this.reviewText,
    this.imageUrl,
    this.isAssetImage = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.grey.shade800 : Colors.blue.shade100,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with customer info
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Customer avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                  backgroundImage: imageUrl != null
                      ? (isAssetImage
                          ? AssetImage(imageUrl!) as ImageProvider
                          : NetworkImage(imageUrl!))
                      : null,
                  child: imageUrl == null
                      ? Icon(Icons.person,
                          size: 24, color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400)
                      : null,
                ),

                const SizedBox(width: 12),

                // Customer name and rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            customerName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            date,
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      StarRating(rating: rating),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Review text
            Text(
              reviewText,
              style: TextStyle(
                color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

