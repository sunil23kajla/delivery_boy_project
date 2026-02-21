import 'package:get/get.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/order_details/order_details_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/network/no_internet_screen.dart';
import '../../presentation/screens/delivery_flow/delivery_flow_screen.dart';
import '../../presentation/screens/undelivered/undelivered_screen.dart';
import '../../presentation/screens/home/rvp/rvp_flow_screen.dart';
import '../../presentation/screens/home/rt/rt_flow_screen.dart';
import '../../presentation/screens/home/fm/fm_flow_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String noInternet = '/no-internet';
  static const String home = '/home';
  static const String orderDetails = '/order-details';
  static const String settings = '/settings';
  static const String deliveryFlow = '/delivery-flow';
  static const String undeliveredProcess = '/undelivered-process';
  static const String rvpFlow = '/rvp-flow';
  static const String rtFlow = '/rt-flow';
  static const String fmFlow = '/fm-flow';

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: login, page: () => const LoginScreen()),
    GetPage(name: otp, page: () => const OtpScreen()),
    GetPage(name: noInternet, page: () => const NoInternetScreen()),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(name: orderDetails, page: () => const OrderDetailsScreen()),
    GetPage(name: settings, page: () => const SettingsScreen()),
    GetPage(name: deliveryFlow, page: () => const DeliveryFlowScreen()),
    GetPage(name: undeliveredProcess, page: () => const UndeliveredScreen()),
    GetPage(name: rvpFlow, page: () => const RvpFlowScreen()),
    GetPage(name: rtFlow, page: () => const RtFlowScreen()),
    GetPage(name: fmFlow, page: () => const FmFlowScreen()),
  ];
}
