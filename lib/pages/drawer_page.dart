import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../pages/dashboard_client.dart';
import '../pages/pengaturan_page.dart';
import 'dart:convert';

import 'PilihJenisLapanganScreen.dart';

class DrawerPage extends StatefulWidget {
  final User user;

  DrawerPage({required this.user});

  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Navigator.pop(context); // Close the drawer

    switch (index) {
      case 0:
        if (_selectedIndex != 0) {
          Navigator.pushReplacementNamed(context, '/dashboardClient');
        }
        break;
      case 1:
        if (_selectedIndex != 1) {
          Navigator.pushReplacementNamed(context, '/pilihjenis');
        }
        break;

      case 2:
        if (_selectedIndex != 2) {
          Navigator.pushReplacementNamed(context, '/pengaturan');
        }
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String? base64String = widget.user.foto_base64;

    // Decode base64 string menjadi Uint8List
    Uint8List? imageBytes;
    try {
      imageBytes = base64Decode(base64String ?? "");
    } catch (e) {
      print('Error decoding base64: $e');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Client Site'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.user.nama_lengkap),
              accountEmail: Text(widget.user.email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage:
                    imageBytes != null ? MemoryImage(imageBytes) : null,
                child: imageBytes == null
                    ? Icon(Icons.person,
                        size: 50) // Placeholder jika gambar tidak tersedia
                    : null,
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: Icon(Icons.sports),
              title: Text('Booking'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Pengaturan'),
              onTap: () => _onItemTapped(2),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () => _showLogoutDialog(),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardClient(),
          PilihJenisLapanganScreen(),
          PengaturanPage(),
        ],
      ),
    );
  }
}
