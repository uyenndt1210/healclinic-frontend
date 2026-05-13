import 'package:flutter/material.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/register_phone_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/set_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/patient_view/home_patient_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HEAL CLINIC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',           // Bắt đầu từ màn hình Welcome
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/register': (context) => const RegisterPhoneScreen(),
        '/otp': (context) {
          final args =
          ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;

          return OtpScreen(
            phone: args['phone'],
            fullName: args['fullName'],
          );
        },
        '/set-password': (context) {
          final args =
          ModalRoute.of(context)!
              .settings
              .arguments as Map<String, dynamic>;

          return SetPasswordScreen(
            phone: args['phone'],
            fullName: args['fullName'],
          );
        },
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePatientScreen(),
        '/home_D': (context) => const Text("Thêm layout bác sĩ vô"),
      },
    );
  }
}