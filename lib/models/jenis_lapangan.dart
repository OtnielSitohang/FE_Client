// models/jenis_lapangan.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class JenisLapangan {
  final int id;
  final String nama;
  final String gambarBase64;

  JenisLapangan({
    required this.id,
    required this.nama,
    required this.gambarBase64,
  });

  factory JenisLapangan.fromJson(Map<String, dynamic> json) {
    return JenisLapangan(
      id: json['id'],
      nama: json['nama'],
      gambarBase64:
          json['gambar'], // Pastikan gambarBase64 disimpan sebagai String
    );
  }

  // Getter untuk mendapatkan gambar dalam bentuk Image
  Image get gambar {
    // Dekode base64 menjadi bytes
    List<int> bytes = base64Decode(gambarBase64.split(',').last);
    return Image.memory(Uint8List.fromList(bytes)); // Image dari bytes
  }
}
