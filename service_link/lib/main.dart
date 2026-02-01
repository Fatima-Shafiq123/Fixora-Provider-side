import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:service_link/util/AppRoute.dart';
import 'package:service_link/util/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:service_link/screens/provider/provider_dashboard_screen.dart';
import 'package:service_link/screens/provider/provider_login_screen.dart';
import 'package:service_link/screens/provider/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ServiceLinkApp(),
    ),
  );
}

class ServiceLinkApp extends StatelessWidget {
  const ServiceLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Fixora',
          theme: themeProvider.getTheme(),
          debugShowCheckedModeBanner: false,
          home: const InitialScreen(),
          onGenerateRoute: Approutes.generateRoute,
        );
      },
    );
  }
}

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData) {
          return const ProviderDashboardScreen();
        }
        return const ProviderLoginScreen();
      },
    );
  }
}
