import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'core/constants/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'core/localization/app_translations.dart';
import 'presentation/bindings/initial_binding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initConnectivity();
  runApp(const MyApp());
}

void _initConnectivity() {
  InternetConnectionChecker().onStatusChange.listen((status) {
    if (status == InternetConnectionStatus.disconnected) {
      Get.toNamed(AppRoutes.noInternet);
    } else {
      if (Get.currentRoute == AppRoutes.noInternet) {
        Get.back();
      }
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      initialBinding: InitialBinding(),
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}
