import 'package:client_front/utils/DateUtils.dart';

class User {
  final int id;
  final String username;
  final String nama_lengkap;
  final String email;
  final String tempat_tinggal;
  final DateTime tanggal_lahir;
  final String role;
  final String? foto_base64;

  User({
    required this.id,
    required this.username,
    required this.nama_lengkap,
    required this.email,
    required this.tempat_tinggal,
    required this.tanggal_lahir,
    required this.role,
    this.foto_base64,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      nama_lengkap: json['nama_lengkap'] ?? '',
      email: json['email'] ?? '',
      tempat_tinggal: json['tempat_tinggal'] ?? '',
      tanggal_lahir:
          DateUtils.parseDateString(json['tanggal_lahir']) ?? DateTime.now(),
      role: json['role'] ?? '',
      foto_base64: json['foto_base64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nama_lengkap': nama_lengkap,
      'email': email,
      'tempat_tinggal': tempat_tinggal,
      'tanggal_lahir':
          DateUtils.formatDateTime(tanggal_lahir), // Use DateUtils to format
      'role': role,
      'foto_base64': foto_base64,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? nama_lengkap,
    String? email,
    String? tempat_tinggal,
    DateTime? tanggal_lahir, // Update type to DateTime
    String? role,
    String? foto_base64,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      nama_lengkap: nama_lengkap ?? this.nama_lengkap,
      email: email ?? this.email,
      tempat_tinggal: tempat_tinggal ?? this.tempat_tinggal,
      tanggal_lahir: tanggal_lahir ?? this.tanggal_lahir,
      role: role ?? this.role,
      foto_base64: foto_base64 ?? this.foto_base64,
    );
  }
}
