import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool showRatingNumber;
  final Color starColor;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 18,
    this.showRatingNumber = true,
    this.starColor = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(
          5,
          (index) => Icon(
            index < rating.floor()
                ? Icons.star
                : (index == rating.floor() && rating % 1 > 0)
                    ? Icons.star_half
                    : Icons.star_border,
            color: starColor,
            size: size,
          ),
        ),
        if (showRatingNumber) ...[
          const SizedBox(width: 6),
          Text(
            rating.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size - 4,
            ),
          ),
        ],
      ],
    );
  }
}

