class Lapangan {
  final int id;
  final String namaLapangan;
  final double harga;

  Lapangan({
    required this.id,
    required this.namaLapangan,
    required this.harga,
  });

  factory Lapangan.fromJson(Map<String, dynamic> json) {
    return Lapangan(
      id: json['id'],
      namaLapangan: json['nama_lapangan'],
      harga: (json['harga'] as num)
          .toDouble(), // Pastikan harga diubah menjadi double
    );
  }
}
