import 'package:flutter/material.dart';
import 'package:service_link/util/AppRoute.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      {
        'name': 'Ali Khan',
        'service': 'AC Maintenance',
        'lastMessage': 'Thanks for coming today!',
        'unread': 2,
      },
      {
        'name': 'Sara Ahmed',
        'service': 'Deep Cleaning',
        'lastMessage': 'See you tomorrow at 9am.',
        'unread': 0,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Chats'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: chats.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ListTile(
            tileColor: Theme.of(context).cardColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: CircleAvatar(
              child: Text((chat['name'] as String).substring(0, 1)),
            ),
            title: Text(chat['name'] as String),
            subtitle: Text('${chat['service']} • ${chat['lastMessage']}'),
            trailing: (chat['unread'] as int) > 0
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      chat['unread']!.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : null,
            onTap: () {
              Navigator.pushNamed(
                context,
                Approutes.PROVIDER_CHAT,
                arguments: chat,
              );
            },
          );
        },
      ),
    );
  }
}
