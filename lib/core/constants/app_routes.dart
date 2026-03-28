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
import '../../presentation/screens/home/summary/summary_list_screen.dart';
import '../../presentation/screens/home/summary/summary_detail_screen.dart';
import '../../presentation/screens/home/summary/summary_list_controller.dart';

import 'package:delivery_boy/presentation/screens/home/quick/quick_flow_binding.dart';
import 'package:delivery_boy/presentation/screens/home/quick/quick_home_screen.dart';
import 'package:delivery_boy/presentation/screens/home/quick/pickup/quick_pickup_screen.dart';
import 'package:delivery_boy/presentation/screens/home/quick/delivery/quick_fvd_screen.dart';
import 'package:delivery_boy/presentation/screens/home/quick/quick_details_screen.dart';
import 'package:delivery_boy/presentation/screens/home/quick/quick_mark_pending_screen.dart';
import 'package:delivery_boy/presentation/screens/home/quick/delivery/quick_mark_undelivered_screen.dart';
import 'package:delivery_boy/presentation/screens/home/quick/quick_profile_screen.dart';
// Note: QuickDeliveryScreen removed in v2.5.3 simplification

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
  static const String summaryList = '/summary-list';
  static const String summaryDetail = '/summary-detail';
  static const String quickHome = '/quick-home';
  static const String quickPickup = '/quick-pickup';
  static const String quickDelivery = '/quick-delivery';
  static const String quickOrderDetails = '/quick-order-details';
  static const String quickMarkPending = '/quick-mark-pending';
  static const String quickMarkUndelivered = '/quick-mark-undelivered';
  static const String quickProfile = '/quick-profile';
  static const String quickFvd = '/quick-fvd';

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
    GetPage(
        name: summaryList,
        page: () => const SummaryListScreen(),
        binding: SummaryBinding()),
    GetPage(
        name: summaryDetail,
        page: () => const SummaryDetailScreen(),
        binding: SummaryBinding()),
    GetPage(
        name: quickHome,
        page: () => const QuickHomeScreen(),
        binding: QuickFlowBinding()),
    GetPage(
        name: quickPickup,
        page: () => const QuickPickupScreen(),
        binding: QuickFlowBinding()),
    GetPage(
        name: quickDelivery,
        page: () => const QuickFVDScreen(),
        binding: QuickFlowBinding()),
    GetPage(
        name: quickOrderDetails,
        page: () => const QuickDetailsScreen(),
        binding: QuickFlowBinding()),
    GetPage(
        name: quickMarkPending,
        page: () => const QuickMarkPendingScreen(),
        binding: QuickFlowBinding()),
    GetPage(
        name: quickMarkUndelivered,
        page: () => const QuickMarkUndeliveredScreen(),
        binding: QuickFlowBinding()),
    GetPage(
        name: quickProfile,
        page: () => const QuickProfileScreen(),
        binding: QuickFlowBinding()),
    GetPage(
        name: quickFvd,
        page: () => const QuickFVDScreen(),
        binding: QuickFlowBinding()),
  ];
}
