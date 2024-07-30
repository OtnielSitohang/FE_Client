import 'package:client_front/models/user.dart';
import 'package:client_front/pages/dashboard_client.dart';
import 'package:client_front/pages/drawer_page.dart';
import 'package:client_front/pages/login_page.dart';
import 'package:flutter/material.dart';

import 'pages/PengaturanAkunPage .dart';
import 'pages/PilihJenisLapanganScreen.dart';
import 'pages/pengaturan_page.dart';
import 'pages/ubah_password_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LoginPage());
      case '/drawer':
        final user = settings.arguments as User;
        return MaterialPageRoute(builder: (_) => DrawerPage(user: user));
      case '/dashboardAdmin':
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
