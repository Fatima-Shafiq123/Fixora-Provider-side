import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool showViewAll;
  final VoidCallback? onViewAllPressed;
  final Color? titleColor;
  final Color? viewAllColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.showViewAll = true,
    this.onViewAllPressed,
    this.titleColor,
    this.viewAllColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          if (showViewAll)
            TextButton(
              onPressed: onViewAllPressed ?? () {},
              style: TextButton.styleFrom(
                foregroundColor: viewAllColor,
              ),
              child: const Text('View All'),
            ),
        ],
      ),
    );
  }
}

