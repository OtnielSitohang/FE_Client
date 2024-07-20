import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';

class PengaturanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text('Tema Gelap'),
            value:
                Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark,
            onChanged: (bool value) {
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme(value);
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Pengaturan Akun'),
            onTap: () {
              Navigator.pushNamed(
                  context, '/pengaturanAkun'); // Navigate to PengaturanAkunPage
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Ubah Password'),
            onTap: () {
              Navigator.pushNamed(context, '/ubahpassword');
            },
          ),

          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifikasi'),
            onTap: () {
              // Add navigation to the notification settings page here
            },
          ),
          // Add other settings here
        ],
      ),
    );
  }
}
