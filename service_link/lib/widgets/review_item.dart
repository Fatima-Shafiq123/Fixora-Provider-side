import 'package:flutter/material.dart';

class ReviewItem extends StatelessWidget {
  final String name;
  final String date;
  final double rating;
  final String imageUrl;
  final String? reviewText;
  final bool isAssetImage;

  const ReviewItem({
    super.key,
    required this.name,
    required this.date,
    required this.rating,
    required this.imageUrl,
    this.reviewText =
        'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet.',
    this.isAssetImage = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile image
          CircleAvatar(
            radius: 24,
            backgroundImage: isAssetImage
                ? AssetImage(imageUrl) as ImageProvider
                : NetworkImage(imageUrl),
            backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
          const SizedBox(width: 12),
          // Review content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Star rating
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < rating.floor()
                            ? Icons.star
                            : (index == rating.floor() && rating % 1 > 0)
                                ? Icons.star_half
                                : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      rating.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Review text
                if (reviewText != null)
                  Text(
                    reviewText!,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

