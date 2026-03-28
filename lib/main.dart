import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:delivery_boy/core/constants/app_routes.dart';
import 'package:delivery_boy/core/constants/app_strings.dart';
import 'package:delivery_boy/core/localization/app_translations.dart';
import 'package:delivery_boy/presentation/bindings/initial_binding.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('--- APP START startup: VERSION SYNC CHECK 2.3.0 ---');
  await GetStorage.init();
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

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
