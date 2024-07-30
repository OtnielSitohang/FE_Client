import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/lapangan.dart';
import '../models/jenis_lapangan.dart';
import 'package:client_front/services/booking_service.dart';
import 'booking_detail_screen.dart';
import '../models/UserProvider.dart';
import '../models/user.dart';
import 'package:provider/provider.dart';

class PilihTanggalSesiScreen extends StatefulWidget {
  final JenisLapangan jenisLapangan;

  const PilihTanggalSesiScreen({Key? key, required this.jenisLapangan})
      : super(key: key);

  @override
  _PilihTanggalSesiScreenState createState() => _PilihTanggalSesiScreenState();
}

class _PilihTanggalSesiScreenState extends State<PilihTanggalSesiScreen> {
  DateTime selectedDate = DateTime.now();
  String selectedSesi = '08-10'; // Inisialisasi sesi awal
  List<Lapangan> lapanganList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Tanggal dan Sesi'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: [
                Icon(Icons.calendar_today),
                SizedBox(width: 8.0),
                Text(
                  'Pilih Tanggal Anda:',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text('Pilih Tanggal'),
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Icon(Icons.access_time),
                SizedBox(width: 8.0),
                Text(
                  'Pilih Sesi:',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            DropdownButton<String>(
              value: selectedSesi,
              onChanged: (String? value) {
                setState(() {
                  selectedSesi = value!;
                });
              },
              items: <String>[
                '08-10',
                '10-12',
                '12-14',
                '14-16',
                '16-18',
                '18-20',
                '20-22',
                '22-24'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _fetchAvailableLapangan();
              },
              child: Text('Cari'),
            ),
            SizedBox(height: 16.0),
            _buildLapanganCards(),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 7)),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _fetchAvailableLapangan() async {
    try {
      List<Lapangan> availableLapangans =
          await ApiService.fetchAvailableLapangan(
        widget.jenisLapangan.id,
        DateFormat('yyyy-MM-dd').format(selectedDate),
        selectedSesi,
      );
      setState(() {
        lapanganList = availableLapangans;
      });
    } catch (e) {
      print('Error fetching available lapangan: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Gagal memuat lapangan yang tersedia. Periksa koneksi internet Anda.'),
      ));
    }
  }

  Widget _buildLapanganCards() {
    if (lapanganList.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada lapangan yang tersedia untuk tanggal dan sesi ini.',
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: lapanganList.map((lapangan) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                color: Colors.grey.shade300,
                child: Text(
                  lapangan.namaLapangan,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 8.0),
              FutureBuilder<Uint8List>(
                future: _getImageFromBase64(widget.jenisLapangan.gambarBase64),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return SizedBox.shrink();
                  }
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    height: 200.0,
                  );
                },
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDetailScreen(
                        jenisLapangan: widget.jenisLapangan,
                        selectedDate: selectedDate,
                        selectedSesi: selectedSesi,
                        gambarLapangan: widget.jenisLapangan.gambarBase64,
                        penggunaId:
                            Provider.of<UserProvider>(context, listen: false)
                                .user!
                                .id, // Pass the actual user ID
                        lapanganId: lapangan.id, // Pass the actual field ID
                        jenisLapanganId: widget.jenisLapangan.id,
                        tanggalPenggunaan:
                            DateFormat('yyyy-MM-dd').format(selectedDate),
                        harga: lapangan.harga
                            .toString(), // Convert harga to string
                      ),
                    ),
                  );
                },
                child: Text('Pilih'),
              ),
              SizedBox(height: 8.0),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<Uint8List> _getImageFromBase64(String base64String) async {
    List<int> bytes = base64Decode(base64String.split(',').last);
    return Uint8List.fromList(bytes);
  }
}
