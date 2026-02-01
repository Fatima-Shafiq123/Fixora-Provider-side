import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'How long does approval take?',
        'a':
            'We verify documents within 2-4 working hours. You will receive a push notification once approved.'
      },
      {
        'q': 'How do I receive payments?',
        'a':
            'Earnings are added to your in-app wallet. You can withdraw to bank, JazzCash, or Easypaisa anytime.'
      },
      {
        'q': 'Can I pause my availability?',
        'a':
            'Yes. Use Service Availability in My Services to toggle days, time slots, or mark vacation days.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final item = faqs[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              title: Text(
                item['q']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(item['a']!),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

