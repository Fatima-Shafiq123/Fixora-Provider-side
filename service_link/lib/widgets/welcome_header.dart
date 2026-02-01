import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  final String userName;
  final String message;
  final EdgeInsetsGeometry padding;
  final TextStyle? userNameStyle;
  final TextStyle? messageStyle;

  const WelcomeHeader({
    super.key,
    this.userName = 'User',
    this.message = 'Welcome Back!',
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    this.userNameStyle,
    this.messageStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: padding,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello $userName',
            style: userNameStyle ??
                TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: messageStyle ??
                TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }
}

