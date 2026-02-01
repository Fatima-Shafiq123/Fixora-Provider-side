import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final helpOptions = [
      {
        'title': 'Live Chat',
        'subtitle': 'Talk to our success team',
        'icon': Icons.chat_bubble_outline,
      },
      {
        'title': 'Call Support',
        'subtitle': '+92 300 1234567',
        'icon': Icons.call_outlined,
      },
      {
        'title': 'Email',
        'subtitle': 'providers@servicelink.pk',
        'icon': Icons.email_outlined,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: helpOptions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final option = helpOptions[index];
          return ListTile(
            tileColor: Theme.of(context).cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: Icon(option['icon'] as IconData),
            title: Text(option['title']! as String),
            subtitle: Text(option['subtitle']! as String),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${option['title']} coming soon.')),
              );
            },
          );
        },
      ),
    );
  }
}

