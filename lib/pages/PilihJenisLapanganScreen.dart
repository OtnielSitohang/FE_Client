import 'dart:convert';
import 'dart:typed_data';

import 'package:client_front/services/booking_service.dart';
import 'package:flutter/material.dart';
import '../models/jenis_lapangan.dart';

import 'pilih_tanggal_sesi_screen.dart'; // Sesuaikan dengan nama service Anda

class PilihJenisLapanganScreen extends StatefulWidget {
  const PilihJenisLapanganScreen({Key? key}) : super(key: key);

  @override
  _PilihJenisLapanganScreenState createState() =>
      _PilihJenisLapanganScreenState();
}

class _PilihJenisLapanganScreenState extends State<PilihJenisLapanganScreen> {
  List<JenisLapangan> jenisLapanganList = [];

  @override
  void initState() {
    super.initState();
    fetchJenisLapangan();
  }

  Future<void> fetchJenisLapangan() async {
    try {
      List<JenisLapangan> jenisLapangans = await ApiService
          .fetchJenisLapangan(); // Ganti dengan nama fungsi yang sesuai di ApiService
      setState(() {
        jenisLapanganList = jenisLapangans;
      });
    } catch (e) {
      print('Error fetching jenis lapangan: $e');
      // Tambahkan penanganan error sesuai kebutuhan
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Jenis Lapangan'),
      ),
      body: ListView.builder(
        itemCount: jenisLapanganList.length,
        itemBuilder: (context, index) {
          JenisLapangan jenisLapangan = jenisLapanganList[index];
          return _buildCard(jenisLapangan);
        },
      ),
    );
  }

  Widget _buildCard(JenisLapangan jenisLapangan) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.grey.shade300,
            child: Text(
              jenisLapangan.nama,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 8.0),
          FutureBuilder<Uint8List>(
            future: _getImageFromBase64(jenisLapangan.gambarBase64),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return SizedBox
                    .shrink(); // Optional: return empty widget or placeholder
              }
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                height: 200.0, // Sesuaikan dengan tinggi yang diinginkan
              );
            },
          ),
          SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PilihTanggalSesiScreen(jenisLapangan: jenisLapangan),
                ),
              );
            },
            child: Text('Pilih Lapangan'),
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }

  Future<Uint8List> _getImageFromBase64(String base64String) async {
    List<int> bytes = base64Decode(base64String.split(',').last);
    return Uint8List.fromList(bytes);
  }
}
