import 'dart:convert';
import 'dart:io'; // Import this for handling File
import 'dart:typed_data';
import 'package:client_front/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../components/ConfirmationDialog.dart';
import '../components/EditableField.dart';
import '../models/user.dart';
import '../models/UserProvider.dart';
import '../utils/DateUtils.dart' as AppDateUtils;
import 'package:provider/provider.dart';

class PengaturanAkunPage extends StatefulWidget {
  @override
  _PengaturanAkunPageState createState() => _PengaturanAkunPageState();
}

class _PengaturanAkunPageState extends State<PengaturanAkunPage> {
  late TextEditingController _emailController;
  late TextEditingController _tempatTinggalController;
  bool _isEmailEdited = false;
  bool _isTempatTinggalEdited = false;
  late AuthService _authService; // Add AuthService instance
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _tempatTinggalController = TextEditingController();
    _authService = AuthService(); // Initialize AuthService

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      if (user != null) {
        _emailController.text = user.email ?? '';
        _tempatTinggalController.text = user.tempat_tinggal ?? '';

        setState(() {
          _isEmailEdited = _emailController.text.isNotEmpty;
          _isTempatTinggalEdited = _tempatTinggalController.text.isNotEmpty;
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _showImagePickerOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Sumber Gambar'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage();
              },
              child: Text('Pilih dari Galeri'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _takePhoto();
              },
              child: Text('Ambil Foto'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _uploadProfilePicture() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;

    if (currentUser == null || _selectedImage == null) return;

    try {
      final file = File(_selectedImage!.path);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final updatedUser = currentUser.copyWith(foto_base64: base64Image);
      await _authService.updateProfile(updatedUser);

      userProvider.setUser(updatedUser);

      // Refresh the UI or show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto profil berhasil diperbarui')),
      );
    } catch (e) {
      print('Gagal mengupdate foto profil: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengupdate foto profil')),
      );
    }
  }

  void _showConfirmationDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.user;

    if (currentUser == null) {
      print('User data is null');
      return;
    }

    final updatedEmail = _emailController.text.trim();
    final updatedTempatTinggal = _tempatTinggalController.text.trim();

    if (updatedEmail.isEmpty && updatedTempatTinggal.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Update Gagal'),
            content: Text(
                'Email atau tempat tinggal harus diisi untuk melakukan update.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    User updatedUser;
    if (updatedEmail.isNotEmpty && updatedTempatTinggal.isNotEmpty) {
      updatedUser = currentUser.copyWith(
        email: updatedEmail,
        tempat_tinggal: updatedTempatTinggal,
      );
    } else if (updatedEmail.isNotEmpty) {
      updatedUser = currentUser.copyWith(
        email: updatedEmail,
      );
    } else {
      updatedUser = currentUser.copyWith(
        tempat_tinggal: updatedTempatTinggal,
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          email: currentUser.email ?? '',
          newEmail: updatedEmail,
          tempatTinggal: currentUser.tempat_tinggal ?? '',
          newTempatTinggal: updatedTempatTinggal,
          onConfirm: () async {
            try {
              await userProvider.updateUser(context, updatedUser);
              Navigator.pushNamedAndRemoveUntil(
                  context, '/drawer', (route) => false,
                  arguments: updatedUser);
            } catch (e) {
              print('Gagal mengupdate pengguna: $e');
              String errorMessage =
                  'Gagal mengupdate profil. Silakan coba lagi nanti.';
              if (e.toString().contains('Unauthorized')) {
                errorMessage = 'Gagal mengupdate profil. Akses tidak sah.';
              } else if (e.toString().contains('Bad request')) {
                errorMessage = 'Gagal mengupdate profil. Data tidak valid.';
              } else if (e.toString().contains('Not found')) {
                errorMessage =
                    'Gagal mengupdate profil. Endpoint tidak ditemukan.';
              }

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Update Gagal'),
                    content: Text(errorMessage),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    String? base64String = user?.foto_base64;

    Uint8List? imageBytes;
    try {
      imageBytes = base64Decode(base64String ?? "");
    } catch (e) {
      print('Error decoding base64: $e');
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Pengaturan Akun'),
        ),
        body: Center(child: Text('Data pengguna tidak tersedia')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Pengaturan Akun'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _showImagePickerOptions, // Show image picker options
            child: CircleAvatar(
              radius: 50,
              backgroundImage:
                  imageBytes != null ? MemoryImage(imageBytes) : null,
              child: imageBytes == null
                  ? Icon(Icons.person,
                      size: 50) // Placeholder jika gambar tidak tersedia
                  : null,
            ),
          ),
          SizedBox(height: 16),
          ListTile(
            title: Text('Username'),
            subtitle: Text(user.username),
            trailing: Icon(Icons.lock, color: Colors.grey),
          ),
          ListTile(
            title: Text('Nama Lengkap'),
            subtitle: Text(user.nama_lengkap ?? '-'),
            trailing: Icon(Icons.lock, color: Colors.grey),
          ),
          ListTile(
            title: Text('Tanggal Lahir'),
            subtitle: Text(user.tanggal_lahir != null
                ? AppDateUtils.DateUtils.formattedDate(user.tanggal_lahir)
                : '-'),
            trailing: Icon(Icons.lock, color: Colors.grey),
          ),
          ListTile(
            title: Text('Email'),
            subtitle: EditableField(
              label: 'Email',
              controller: _emailController,
              icon: Icons.email,
              isEdited: _isEmailEdited,
              onChanged: (value) {
                setState(() {
                  _isEmailEdited = true;
                });
              },
            ),
            trailing: Icon(Icons.edit),
          ),
          ListTile(
            title: Text('Tempat Tinggal'),
            subtitle: EditableField(
              label: 'Tempat Tinggal',
              controller: _tempatTinggalController,
              icon: Icons.location_on,
              isEdited: _isTempatTinggalEdited,
              onChanged: (value) {
                setState(() {
                  _isTempatTinggalEdited = value.isNotEmpty;
                });
              },
            ),
            trailing: Icon(Icons.edit),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              await _uploadProfilePicture(); // Upload profile picture before saving
              _showConfirmationDialog();
            },
            child: Text('Simpan Perubahan'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tempatTinggalController.dispose();
    super.dispose();
  }
}
