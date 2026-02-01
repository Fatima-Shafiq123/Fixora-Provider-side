import 'package:flutter/material.dart';
import 'package:service_link/screens/provider/about_app_screen.dart';
import 'package:service_link/screens/provider/add_service_screen.dart';
import 'package:service_link/screens/provider/chat_list_screen.dart';
import 'package:service_link/screens/provider/chat_screen.dart';
import 'package:service_link/screens/provider/document_upload_screen.dart';
import 'package:service_link/screens/provider/edit_profile_screen.dart';
import 'package:service_link/screens/provider/edit_service_screen.dart';
import 'package:service_link/screens/provider/faq_screen.dart';
import 'package:service_link/screens/provider/help_support_screen.dart';
import 'package:service_link/screens/provider/job_detail_screen.dart';
import 'package:service_link/screens/provider/job_requests_screen.dart';
import 'package:service_link/screens/provider/my_services_screen.dart';
import 'package:service_link/screens/provider/onboarding_screen.dart';
import 'package:service_link/screens/provider/profile_screen.dart';
import 'package:service_link/screens/provider/provider_dashboard_screen.dart';
import 'package:service_link/screens/provider/provider_forgot_password_screen.dart';
import 'package:service_link/screens/provider/provider_login_screen.dart';
import 'package:service_link/screens/provider/provider_otp_screen.dart';
import 'package:service_link/screens/provider/provider_signup_screen.dart';
import 'package:service_link/screens/provider/reviews_screen.dart';
import 'package:service_link/screens/provider/service_availability_screen.dart';
import 'package:service_link/screens/provider/service_history_screen.dart';
import 'package:service_link/screens/provider/settings_screen.dart';
import 'package:service_link/screens/provider/splash_screen.dart';
import 'package:service_link/screens/provider/terms_conditions_screen.dart';
import 'package:service_link/screens/provider/location_picker_screen.dart';
import 'package:service_link/screens/provider/wallet_screen.dart';
import 'package:service_link/screens/provider/withdraw_screen.dart';
import 'package:service_link/models/user_model.dart';

class Approutes {
  static const String PROVIDER_SPLASH = "/provider/splash";
  static const String PROVIDER_ONBOARDING = "/provider/onboarding";
  static const String PROVIDER_LOGIN = "/provider/login";
  static const String PROVIDER_SIGNUP = "/provider/signup";
  static const String PROVIDER_OTP = "/provider/otp";
  static const String PROVIDER_DASHBOARD = "/provider/dashboard";
  static const String PROVIDER_FORGOT_PASSWORD = "/provider/forgot-password";
  static const String PROVIDER_BOOKINGS = "/provider/bookings";
  static const String PROVIDER_JOB_DETAIL = "/provider/job-detail";
  static const String PROVIDER_REVIEWS = "/provider/reviews";
  static const String PROVIDER_MY_SERVICES = "/provider/my-services";
  static const String PROVIDER_ADD_SERVICE = "/provider/add-service";
  static const String PROVIDER_EDIT_SERVICE = "/provider/edit-service";
  static const String PROVIDER_PROFILE = "/provider/profile";
  static const String PROVIDER_EDIT_PROFILE = "/provider/edit-profile";
  static const String PROVIDER_SERVICE_HISTORY = "/provider/service-history";
  static const String PROVIDER_DOCUMENT_UPLOAD = "/provider/document-upload";
  static const String PROVIDER_CHAT_LIST = "/provider/chat-list";
  static const String PROVIDER_CHAT = "/provider/chat";
  static const String PROVIDER_WALLET = "/provider/wallet";
  static const String PROVIDER_WITHDRAW = "/provider/withdraw";
  static const String PROVIDER_SERVICE_AVAILABILITY =
      "/provider/service-availability";
  static const String PROVIDER_SETTINGS = "/provider/settings";
  static const String PROVIDER_HELP_SUPPORT = "/provider/help-support";
  static const String PROVIDER_FAQ = "/provider/faq";
  static const String PROVIDER_ABOUT = "/provider/about";
  static const String PROVIDER_TERMS_CONDITIONS = "/provider/terms-conditions";
  static const String PROVIDER_LOCATION_PICKER = "/provider/location-picker";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Approutes.PROVIDER_SPLASH:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case Approutes.PROVIDER_ONBOARDING:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case Approutes.PROVIDER_LOGIN:
        return MaterialPageRoute(builder: (_) => const ProviderLoginScreen());

      case Approutes.PROVIDER_OTP:
        final args = settings.arguments;
        if (args is ProviderOtpArguments) {
          return MaterialPageRoute(
              builder: (_) => ProviderOtpScreen(
                    contact: args.contact,
                    isFromSignup: args.isFromSignup,
                  ));
        }
        return MaterialPageRoute(
            builder: (_) =>
                ProviderOtpScreen(contact: args?.toString() ?? 'your number'));

      case Approutes.PROVIDER_SIGNUP:
        return MaterialPageRoute(builder: (_) => const ProviderSignupScreen());

      case Approutes.PROVIDER_DASHBOARD:
        return MaterialPageRoute(
            builder: (_) => const ProviderDashboardScreen());

      case Approutes.PROVIDER_FORGOT_PASSWORD:
        return MaterialPageRoute(
            builder: (_) => const ProviderForgotPasswordScreen());

      case Approutes.PROVIDER_BOOKINGS:
        return MaterialPageRoute(builder: (_) => const JobRequestsScreen());

      case Approutes.PROVIDER_JOB_DETAIL:
        final args = settings.arguments as JobDetailArguments;
        return MaterialPageRoute(builder: (_) => JobDetailScreen(args: args));

      case Approutes.PROVIDER_REVIEWS:
        return MaterialPageRoute(builder: (_) => const ReviewsScreen());

      case Approutes.PROVIDER_MY_SERVICES:
        return MaterialPageRoute(builder: (_) => const MyServicesScreen());

      case Approutes.PROVIDER_ADD_SERVICE:
        return MaterialPageRoute(builder: (_) => const AddServiceScreen());

      case Approutes.PROVIDER_EDIT_SERVICE:
        final serviceId = settings.arguments as String? ?? '';
        return MaterialPageRoute(
            builder: (_) => EditServiceScreen(serviceId: serviceId));

      case Approutes.PROVIDER_PROFILE:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case Approutes.PROVIDER_EDIT_PROFILE:
        final userData = settings.arguments as UserModel;
        return MaterialPageRoute(
            builder: (_) => EditProfileScreen(userData: userData));

      case Approutes.PROVIDER_SERVICE_HISTORY:
        return MaterialPageRoute(builder: (_) => const ServiceHistoryScreen());

      case Approutes.PROVIDER_DOCUMENT_UPLOAD:
        return MaterialPageRoute(builder: (_) => DocumentUploadScreen());

      case Approutes.PROVIDER_CHAT_LIST:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());

      case Approutes.PROVIDER_CHAT:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(builder: (_) => ChatScreen(chatMeta: args));

      case Approutes.PROVIDER_WALLET:
        return MaterialPageRoute(builder: (_) => const WalletScreen());

      case Approutes.PROVIDER_WITHDRAW:
        return MaterialPageRoute(builder: (_) => const WithdrawScreen());

      case Approutes.PROVIDER_SERVICE_AVAILABILITY:
        return MaterialPageRoute(
            builder: (_) => const ServiceAvailabilityScreen());

      case Approutes.PROVIDER_SETTINGS:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case Approutes.PROVIDER_HELP_SUPPORT:
        return MaterialPageRoute(builder: (_) => const HelpSupportScreen());

      case Approutes.PROVIDER_FAQ:
        return MaterialPageRoute(builder: (_) => const FaqScreen());

      case Approutes.PROVIDER_ABOUT:
        return MaterialPageRoute(builder: (_) => const AboutAppScreen());

      case Approutes.PROVIDER_TERMS_CONDITIONS:
        return MaterialPageRoute(builder: (_) => const TermsConditionsScreen());

      case Approutes.PROVIDER_LOCATION_PICKER:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
            builder: (_) => LocationPickerScreen(
                  initialLocation: args?['location'],
                  initialAddress: args?['address'],
                ));
    }

    return MaterialPageRoute(builder: (_) => const ProviderLoginScreen());
  }
}
