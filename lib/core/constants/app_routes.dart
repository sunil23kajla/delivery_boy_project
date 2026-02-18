import 'package:get/get.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/order_details/order_details_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/network/no_internet_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String noInternet = '/no-internet';
  static const String home = '/home';
  static const String orderDetails = '/order-details';
  static const String settings = '/settings';

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: otp, page: () => const OtpScreen()),
    GetPage(name: noInternet, page: () => const NoInternetScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: orderDetails, page: () => const OrderDetailsScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
  ];
}
