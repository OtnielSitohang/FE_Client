import 'package:client_front/models/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart'; // Sesuaikan dengan lokasi file Anda
import '../services/ubahpassword_service.dart'; // Sesuaikan dengan lokasi file Anda

class UbahPasswordPage extends StatefulWidget {
  @override
  _UbahPasswordPageState createState() => _UbahPasswordPageState();
}

class _UbahPasswordPageState extends State<UbahPasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubah Password'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _oldPasswordController,
              obscureText: !_isOldPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password Lama',
                suffixIcon: IconButton(
                  icon: Icon(_isOldPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isOldPasswordVisible = !_isOldPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _newPasswordController,
              obscureText: !_isNewPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                suffixIcon: IconButton(
                  icon: Icon(_isNewPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                suffixIcon: IconButton(
                  icon: Icon(_isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                _ubahPassword(context);
              },
              child: Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  void _ubahPassword(BuildContext context) async {
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Validasi form
    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showErrorDialog(context, 'Harap isi semua kolom');
      return;
    }

    if (newPassword != confirmPassword) {
      _showErrorDialog(
          context, 'Password baru dan konfirmasi password tidak cocok');
      return;
    }

    // Dapatkan instance UserProvider dari Provider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    User? currentUser = userProvider.user;

    if (currentUser == null) {
      _showErrorDialog(context, 'Pengguna tidak ditemukan');
      return;
    }

    // Panggil metode ubahPassword dari UbahPasswordService
    final ubahPasswordService =
        Provider.of<UbahPasswordService>(context, listen: false);
    ApiResponse response = await ubahPasswordService.ubahPassword(
        currentUser.id, oldPassword, newPassword);

    if (response.status == Status.SUCCESS) {
      // Tampilkan dialog sukses
      _showSuccessDialog(context);
    } else {
      // Tampilkan dialog error
      _showErrorDialog(context, response.message);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sukses'),
          content: Text('Password berhasil diubah'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog sukses
                Navigator.pushReplacementNamed(
                    context, '/drawer'); // Navigasi ke '/drawer'
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
