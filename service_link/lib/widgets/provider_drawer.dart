import 'package:flutter/material.dart';
import 'package:service_link/util/AppRoute.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:service_link/util/theme_provider.dart';

class ProviderDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int)? onItemSelected;

  const ProviderDrawer({
    super.key,
    this.selectedIndex = 0,
    this.onItemSelected,
  });

  @override
  State<ProviderDrawer> createState() => _ProviderDrawerState();
}

class _ProviderDrawerState extends State<ProviderDrawer> {
  String _providerName = 'Loading...';
  String _specialization = '';
  String _email = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Get user data from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userInfo = userDoc.data()!;

          setState(() {
            _providerName = userInfo['fullName'] ?? 'User';
            _email = userInfo['email'] ?? currentUser.email ?? '';
            // If we have a service category, show it as specialization
            _specialization = userInfo['serviceCategory'] ?? '';
            if (_specialization.isEmpty) {
              // Fallback to experience as a proxy for specialization
              var exp = userInfo['experience'] ?? '';
              _specialization = exp.isNotEmpty ? '$exp Years Experience' : '';
            }
            _isLoading = false;
          });
        } else {
          setState(() {
            _providerName = currentUser.email?.split('@')[0] ?? 'User';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _providerName = 'User';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            _buildDrawerHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                physics: const AlwaysScrollableScrollPhysics(),
                children: <Widget>[
                  _buildDrawerItem(
                    context,
                    icon: Icons.person,
                    title: 'My Profile',
                    index: 0,
                    route: Approutes.PROVIDER_PROFILE,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    index: 1,
                    route: Approutes.PROVIDER_DASHBOARD,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.book_online,
                    title: 'Bookings',
                    index: 2,
                    route: Approutes.PROVIDER_BOOKINGS,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.work,
                    title: 'My Services',
                    index: 3,
                    route: Approutes.PROVIDER_MY_SERVICES,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.history,
                    title: 'Service History',
                    index: 4,
                    route: Approutes.PROVIDER_SERVICE_HISTORY,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.reviews,
                    title: 'Reviews',
                    index: 5,
                    route: Approutes.PROVIDER_REVIEWS,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.chat_bubble_outline,
                    title: 'Chats',
                    index: 6,
                    route: Approutes.PROVIDER_CHAT_LIST,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Wallet',
                    index: 7,
                    route: Approutes.PROVIDER_WALLET,
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    index: 8,
                    route: Approutes.PROVIDER_HELP_SUPPORT,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings,
                    title: 'Settings',
                    index: 9,
                    route: Approutes.PROVIDER_SETTINGS,
                  ),
                  _buildThemeToggle(context),
                  _buildDrawerItem(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    index: 10,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(
                            context, Approutes.PROVIDER_LOGIN);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final headerColor = const Color(0xFF218907);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        Navigator.pushNamed(context, Approutes.PROVIDER_PROFILE);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: headerColor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor:
                      isDarkMode ? Colors.grey.shade800 : Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: isDarkMode ? headerColor : const Color(0xFF218907),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _providerName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _email,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_specialization.isNotEmpty)
                              const SizedBox(height: 2),
                            if (_specialization.isNotEmpty)
                              Text(
                                _specialization,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'View Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon,
      required String title,
      required int index,
      String? route,
      Function()? onTap}) {
    final isSelected = widget.selectedIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? primaryColor
            : isDarkMode
                ? Colors.grey.shade400
                : Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? primaryColor
              : isDarkMode
                  ? Colors.grey.shade300
                  : Colors.grey.shade800,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap ??
          () {
            if (widget.onItemSelected != null) {
              widget.onItemSelected!(index);
            }

            if (route != null) {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, route);
            }
          },
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ListTile(
      leading: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        'Dark Mode',
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.grey.shade800,
        ),
      ),
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (_) {
          themeProvider.toggleTheme();
        },
        activeThumbColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
