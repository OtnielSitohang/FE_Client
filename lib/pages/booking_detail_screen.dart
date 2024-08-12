import 'dart:convert';
import 'package:client_front/services/booking_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/jenis_lapangan.dart';
import '../models/user.dart';
import 'package:provider/provider.dart';
import 'package:client_front/models/UserProvider.dart';

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
  String? _voucherCode;
  bool _isVoucherValid = false;
  bool _isVoucherClaimed = false;
  double _discount = 0.0;
  int? _voucherId;

  double get _finalPrice => _isVoucherClaimed
      ? double.parse(widget.harga) - _discount
      : double.parse(widget.harga);

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

  Future<void> _checkVoucher() async {
    if (_voucherCode != null && _voucherCode!.isNotEmpty) {
      try {
        final response = await ApiService.checkVoucherCode(_voucherCode!);
        if (response['valid'] == true) {
          setState(() {
            _isVoucherValid = true;
            _discount = (response['discount'] is int
                ? (response['discount'] as int).toDouble()
                : response['discount']) as double;
            _voucherId = response['voucher_id']; // Set voucher_id
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Voucher is valid')),
          );
        } else {
          setState(() {
            _isVoucherValid = false;
            _discount = 0.0; // Reset discount if invalid
            _voucherId = 0; // Reset voucher_id
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Voucher is invalid or expired')),
          );
        }
      } catch (e) {
        setState(() {
          _isVoucherValid = false;
          _discount = 0.0;
          _voucherId = 0; // Reset voucher_id
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to check voucher: $e')),
        );
      }
    }
  }

  Future<void> _claimVoucher() async {
    if (_voucherCode != null &&
        _voucherCode!.isNotEmpty &&
        _isVoucherValid &&
        !_isVoucherClaimed) {
      try {
        await ApiService.claimVoucher(
            voucherCode: _voucherCode!, penggunaId: widget.penggunaId);
        setState(() {
          _isVoucherClaimed = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voucher claimed successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to claim voucher: $e')),
        );
      }
    }
  }

  void _showDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Detail Booking'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Tanggal Penggunaan: ${widget.tanggalPenggunaan}'),
            Text('Sesi: ${widget.selectedSesi}'),
            Text('Nama Lapangan: ${widget.jenisLapangan.nama}'),
            Text(
                'Harga Awal: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(double.parse(widget.harga))}'),
            Text(
                'Diskon: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(_discount)}'),
            Text(
                'Harga Akhir: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(_finalPrice)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _bookField() async {
    if (_fotoBase64 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please upload the payment proof')),
      );
      return;
    }

    try {
      // Optionally claim voucher if it's valid and not claimed yet
      if (_isVoucherValid && !_isVoucherClaimed) {
        await _claimVoucher();
      }

      await ApiService.bookField(
        pengguna_id: widget.penggunaId,
        lapangan_id: widget.lapanganId,
        jenis_lapangan_id: widget.jenisLapanganId,
        tanggal_booking: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        tanggal_penggunaan: widget.tanggalPenggunaan,
        sesi: widget.selectedSesi,
        harga: _finalPrice,
        foto_base64: _fotoBase64!,
        voucher_id: _voucherId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking successful!')),
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final User? currentUser = userProvider.user;

      if (currentUser != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/drawer',
          (Route<dynamic> route) => false,
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
  }

  @override
  Widget build(BuildContext context) {
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
                  SizedBox(height: 8.0),
                  Text(
                    'Harga: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(_finalPrice)}',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Text('Kode Voucher (Opsional):', style: TextStyle(fontSize: 18.0)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _voucherCode = value;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Masukkan kode voucher',
                    ),
                    enabled: !_isVoucherClaimed,
                  ),
                ),
                SizedBox(width: 8.0),
                if (!_isVoucherClaimed) ...[
                  ElevatedButton(
                    onPressed: _checkVoucher,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    child: Text('Cek Voucher'),
                  ),
                  SizedBox(width: 8.0),
                  if (_isVoucherValid)
                    ElevatedButton(
                      onPressed: _claimVoucher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      child: Text('Klaim Voucher'),
                    ),
                  if (!_isVoucherValid)
                    Text('Voucher tidak tersedia',
                        style: TextStyle(color: Colors.red)),
                ]
              ],
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _showDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding:
                        EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  ),
                  child: Text('Informasi Detail'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _bookField,
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
