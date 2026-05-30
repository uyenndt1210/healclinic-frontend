import 'package:benhvien/screens/patient_view/ChangPhone.dart';
import 'package:benhvien/screens/patient_view/ChangeInfoPatient.dart';
import 'package:benhvien/screens/patient_view/ConfidenceAndPolicy.dart';
import 'package:benhvien/screens/patient_view/Examiniation.dart';
import 'package:benhvien/screens/patient_view/ForotPassWord.dart';
import 'package:benhvien/screens/patient_view/HealRecord.dart';
import 'package:benhvien/screens/patient_view/HelpView.dart';
import 'package:benhvien/screens/patient_view/InfoPatient_View.dart';
import 'package:benhvien/screens/patient_view/MedicalRecord.dart';
import 'package:benhvien/screens/patient_view/ResetPassword.dart';
import 'package:benhvien/screens/patient_view/followHealth.dart';
import 'package:benhvien/screens/patient_view/vaccine.dart';
import 'package:flutter/material.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/register_phone_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/set_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/patient_view/navigation_patient_role.dart';
import 'package:flutter/services.dart';
import 'screens/patient_view/profile_view.dart';
import 'screens/patient_view/ContactView.dart';


void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
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
        //primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F9FF),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73C8),),
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
        '/profile': (context) => const InforPatient(),
        '/contact': (context) => ContactPage(),
        '/resetPass': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ResetPasswordScreen(
            phone: args['phone'],
            fullName: "",
          );
        },
        '/forgotPass': (context) => const ForgotPasswordScreen(),
        '/changePhone': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return ChangPhoneScreen(currentPhone: args);
        },
        '/terms': (context) => const ConfidenceAndPolicyScreen(),
        '/medicalRecord': (context) => const MedicalRecordPage(),
        '/healRecord': (context) => const HealthRecordPage(),
        '/revisit': (context) => const ExaminationPage(),
        '/vaccine': (context) => const VaccinePage(),
        '/help': (context) => const UserGuideScreen(),
        '/homeHealth': (context) => const SkinCareAndHealthGuideScreen(),
      },
    );
  }
}