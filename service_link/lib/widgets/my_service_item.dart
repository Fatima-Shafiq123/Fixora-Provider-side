import 'package:flutter/material.dart';
import 'package:service_link/widgets/star_rating.dart';

class MyServiceItem extends StatelessWidget {
  final String id;
  final String title;
  final double price;
  final int? discountPercentage;
  final String imageUrl;
  final bool isAssetImage;
  final double rating;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isActive;
  final ValueChanged<bool>? onAvailabilityChanged;

  const MyServiceItem({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    this.discountPercentage,
    required this.imageUrl,
    this.isAssetImage = true,
    required this.rating,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.isActive = true,
    this.onAvailabilityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final shadowColor = isDarkMode ? Colors.black.withOpacity(0.3) : Colors.grey.shade200;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Service image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: SizedBox(
                width: 120,
                height: 120,
                child: isAssetImage
                    ? Image.asset(imageUrl, fit: BoxFit.cover)
                    : Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),

            // Service details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Rs $price',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5C5CFF),
                          ),
                        ),
                        if (discountPercentage != null &&
                            discountPercentage! > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '$discountPercentage% off',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    StarRating(rating: rating, size: 14),
                    const SizedBox(height: 8),
                    if (onEdit != null || onDelete != null || onAvailabilityChanged != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (onAvailabilityChanged != null)
                            Row(
                              children: [
                                const Text('Available'),
                                Switch(
                                  value: isActive,
                                  onChanged: onAvailabilityChanged,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            ),
                          if (onEdit != null)
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                              onPressed: onEdit,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          const SizedBox(width: 12),
                          if (onDelete != null)
                            IconButton(
                              icon: const Icon(Icons.delete, size: 18),
                              color: Colors.red.shade400,
                              onPressed: onDelete,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

