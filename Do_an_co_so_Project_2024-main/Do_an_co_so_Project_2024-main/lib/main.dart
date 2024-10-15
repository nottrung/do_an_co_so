import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tea_man_pka/screens/admin/salary_manager/tea_profile_to_salary_screen.dart';
import 'package:tea_man_pka/screens/admin/setting_screen.dart';
import 'themes/theme_provider.dart';
import 'themes/app_themes.dart';
import 'screens/admin/request_manager/list_request_screen.dart';
import 'screens/admin/schedule_manager/list_schedule_screen.dart';
import 'screens/admin/tea_profile_manager/add_tea_screen.dart';
import 'screens/admin/tea_profile_manager/list_all_tea_screen.dart';
import 'screens/admin/ad_navbar.dart';
import 'screens/admin/ad_home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Quản lý giảng dạy',
            theme: themeProvider.themeData,
            debugShowCheckedModeBanner: false,
            home: LoginScreen(),
            // routes: {
            //   '/home': (context) => AdHomeScreen(),
            //   '/thongtin': (context) => ListAllTeaScreen(),
            //   '/ycau': (context) => ListRequestScreen(),
            //   '/addtea': (context) => AddTeaScreen(),
            //   '/adlistschedule': (context) => ListScheduleScreen(),
            // },
          );
        },
      ),
    );
  }
}

