import 'package:flutter/material.dart';
import 'package:service_link/util/AppRoute.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {'title': 'Cleaning Job #2891', 'amount': '+ Rs 4,200', 'date': 'Today'},
      {'title': 'Withdrawal to JazzCash', 'amount': '- Rs 6,000', 'date': 'Yesterday'},
      {'title': 'AC Service Job #2783', 'amount': '+ Rs 3,100', 'date': '12 Nov'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Withdrawable Balance',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Rs 18,750',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Chip(
                        label: const Text('Pending Rs 2,400'),
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: const Text('Completed Rs 94,300'),
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          Approutes.PROVIDER_WITHDRAW,
                        );
                      },
                      child: const Text('Withdraw'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...transactions.map(
              (tx) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  child: const Icon(Icons.payments),
                ),
                title: Text(tx['title']!),
                subtitle: Text(tx['date']!),
                trailing: Text(
                  tx['amount']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: tx['amount']!.startsWith('+') ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

