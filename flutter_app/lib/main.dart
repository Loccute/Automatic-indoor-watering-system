import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home_page.dart';
import 'package:flutter_app/pages/landing_page.dart';
//import 'values/app_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/pages/control_page.dart';
import 'package:flutter_app/pages/login_page.dart';
import 'package:flutter_app/pages/register_page.dart'; // nếu bạn lưu ở thư mục này
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Pump Control App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue),
      // Khai báo các routes
      routes: {
        '/': (context) => LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/landing_page': (context) => const LandingPage(),
        '/home': (context) => HomePage(),
        '/settings': (context) => const ControlPage(), // Thêm dòng này
      },
    );
  }
}