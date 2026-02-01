import 'package:flutter/material.dart';
import 'package:service_link/util/AppRoute.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _smsUpdates = false;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: _notifications,
            onChanged: (value) => setState(() => _notifications = value),
            title: const Text('Push Notifications'),
            subtitle: const Text('Get alerts for bookings and payments'),
          ),
          SwitchListTile(
            value: _smsUpdates,
            onChanged: (value) => setState(() => _smsUpdates = value),
            title: const Text('SMS Updates'),
            subtitle: const Text('Receive status updates via SMS'),
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(_language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final selected = await showModalBottomSheet<String>(
                context: context,
                builder: (context) => _LanguageSheet(selected: _language),
              );
              if (selected != null) {
                setState(() => _language = selected);
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () => Navigator.pushNamed(
                context, Approutes.PROVIDER_HELP_SUPPORT),
          ),
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('FAQs'),
            onTap: () => Navigator.pushNamed(context, Approutes.PROVIDER_FAQ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About App'),
            onTap: () => Navigator.pushNamed(context, Approutes.PROVIDER_ABOUT),
          ),
        ],
      ),
    );
  }
}

class _LanguageSheet extends StatelessWidget {
  final String selected;

  const _LanguageSheet({required this.selected});

  @override
  Widget build(BuildContext context) {
    final languages = ['English', 'Urdu', 'Punjabi'];
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Choose Language',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          ...languages.map(
            (lang) => RadioListTile<String>(
              value: lang,
              groupValue: selected,
              onChanged: (value) => Navigator.pop(context, value),
              title: Text(lang),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

