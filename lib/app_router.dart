import 'package:client_front/pages/PengaturanAkunPage%20.dart';
import 'package:client_front/pages/PilihJenisLapanganScreen.dart';
import 'package:client_front/pages/forgot_password.dart';
import 'package:client_front/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'pages/dashboard_client.dart';
import 'pages/drawer_page.dart';
import 'pages/login_page.dart';
import 'pages/pengaturan_page.dart';
import 'pages/ubah_password_page.dart';
import 'models/user.dart'; // Pastikan path sesuai

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case '/forgot-password':
        return MaterialPageRoute(builder: (_) => ForgotPasswordPage());
      case '/drawer':
        final user = settings.arguments as User;
        return MaterialPageRoute(builder: (_) => DrawerPage(user: user));
      case '/dashboardClient':
        return MaterialPageRoute(builder: (_) => DashboardClient());
      case '/pengaturan':
        return MaterialPageRoute(builder: (_) => PengaturanPage());
      case '/pengaturanAkun':
        return MaterialPageRoute(builder: (_) => PengaturanAkunPage());
      case '/ubahpassword':
        return MaterialPageRoute(builder: (_) => UbahPasswordPage());
      case '/pilihjenis':
        return MaterialPageRoute(builder: (_) => PilihJenisLapanganScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
