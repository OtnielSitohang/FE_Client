import 'dart:convert';
import 'package:client_front/models/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:intl/intl.dart';
import '../models/jenis_lapangan.dart';
import '../models/user.dart';
import 'package:client_front/services/booking_service.dart';
import 'package:provider/provider.dart';

class BookingDetailScreen extends StatefulWidget {
  final JenisLapangan jenisLapangan;
  final DateTime selectedDate;
  final String selectedSesi;
  final String gambarLapangan;
  final int penggunaId;
  final int lapanganId;
  final int jenisLapanganId;
  final String tanggalPenggunaan;
  final String harga;

  const BookingDetailScreen({
    Key? key,
    required this.jenisLapangan,
    required this.selectedDate,
    required this.selectedSesi,
    required this.gambarLapangan,
    required this.penggunaId,
    required this.lapanganId,
    required this.jenisLapanganId,
    required this.tanggalPenggunaan,
    required this.harga,
  }) : super(key: key);

  @override
  _BookingDetailScreenState createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  String? _fotoBase64;
  String? _selectedPaymentMethod;

  final List<String> _paymentMethods = [
    'BNI',
    'BRI',
    'BCA',
    'MANDIRI',
    'DANA',
    'OVO',
    'GOPAY',
    'DLL',
  ];

  final Map<String, String> _accountNumbers = {
    'BNI': '1234567890',
    'BRI': '0987654321',
    'BCA': '1122334455',
    'MANDIRI': '5566778899',
    'DANA': '6677889900',
    'OVO': '2233445566',
    'GOPAY': '7788990011',
    'DLL': '3344556677',
  };

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pilih Sumber Gambar'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.of(context)
                  .pop(await picker.pickImage(source: ImageSource.camera));
            },
            child: Text('Ambil Foto'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context)
                  .pop(await picker.pickImage(source: ImageSource.gallery));
            },
            child: Text('Pilih dari Galeri'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'),
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      setState(() {
        _fotoBase64 = base64String;
      });
    }
  }

  void _viewImage() {
    if (_fotoBase64 != null) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Image.memory(
            base64Decode(_fotoBase64!),
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width,
          ),
        ),
      );
    }
  }

  void _showFullScreenInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pengguna ID: ${widget.penggunaId}',
                    style: TextStyle(fontSize: 18.0)),
                Text('Lapangan ID: ${widget.lapanganId}',
                    style: TextStyle(fontSize: 18.0)),
                Text('Jenis Lapangan ID: ${widget.jenisLapanganId}',
                    style: TextStyle(fontSize: 18.0)),
                Text(
                    'Tanggal Booking: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                    style: TextStyle(fontSize: 18.0)),
                Text('Tanggal Penggunaan: ${widget.tanggalPenggunaan}',
                    style: TextStyle(fontSize: 18.0)),
                Text('Sesi: ${widget.selectedSesi}',
                    style: TextStyle(fontSize: 18.0)),
                Text('Harga: ${widget.harga}',
                    style: TextStyle(fontSize: 18.0)),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final User? currentUser = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Booking'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                title: Text(
                  'Nama Lapangan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(widget.jenisLapangan.nama),
                leading: Icon(Icons.sports_soccer, size: 40.0),
              ),
            ),
            SizedBox(height: 16.0),
            Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: Image.memory(
                      base64Decode(widget.gambarLapangan.split(',').last),
                      fit: BoxFit.cover,
                      height: 200.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Text('Metode Pembayaran:', style: TextStyle(fontSize: 18.0)),
            DropdownButton<String>(
              value: _selectedPaymentMethod,
              hint: Text('Pilih Metode Pembayaran'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue;
                });
              },
              items:
                  _paymentMethods.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (_selectedPaymentMethod != null)
              Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nomor Akun: ${_accountNumbers[_selectedPaymentMethod] ?? 'N/A'}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Atas Nama: Otniel Sitohang'),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                ),
                child: Text('Upload Bukti Bayar'),
              ),
            ),
            SizedBox(height: 16.0),
            if (_fotoBase64 != null)
              GestureDetector(
                onTap: _viewImage,
                child: Center(
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.memory(
                        base64Decode(_fotoBase64!),
                        height: 300.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _showFullScreenInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                ),
                child: Text('Lihat Detail'),
              ),
            ),
            SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () async {
                  if (_fotoBase64 == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Please upload the payment proof')),
                    );
                    return;
                  }

                  try {
                    await ApiService.bookField(
                      pengguna_id: widget.penggunaId,
                      lapangan_id: widget.lapanganId,
                      jenis_lapangan_id: widget.jenisLapanganId,
                      tanggal_booking:
                          DateFormat('yyyy-MM-dd').format(DateTime.now()),
                      tanggal_penggunaan: widget.tanggalPenggunaan,
                      sesi: widget.selectedSesi,
                      harga: double.parse(widget.harga),
                      foto_base64: _fotoBase64!,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Booking successful!')),
                    );

                    if (currentUser != null) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/drawer',
                        (Route<dynamic> route) =>
                            false, // This removes all previous routes
                        arguments: currentUser,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User data not available')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create booking: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                ),
                child: Text('Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
