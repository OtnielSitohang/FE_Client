import 'package:client_front/Global/url.dart';
import 'package:client_front/models/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/dashboard_service.dart';
import 'package:client_front/utils/DateUtils.dart' as localDateUtils;
import 'package:url_launcher/url_launcher.dart'; // Pastikan dependency ini ada

class DashboardClient extends StatefulWidget {
  @override
  _DashboardClientState createState() => _DashboardClientState();
}

class _DashboardClientState extends State<DashboardClient> {
  late Future<Map<String, dynamic>> _bookings;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found. Please log in again.')),
        );
        Navigator.pushReplacementNamed(context, '/');
      });
      return;
    }

    setState(() {
      _bookings = DashboardService(baseUrl).fetchBookings(user.id);
    });
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final url = 'https://wa.me/$phoneNumber';
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch WhatsApp.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Lapangan Seminggu Ke Depan'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBookings, // Trigger data refresh
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _bookings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          final bookings = data['data'] as List<dynamic>;

          if (bookings.isEmpty) {
            return Center(
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lapangan yang Anda booking tidak ada.',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/pilihjenis');
                        },
                        child: Text('Booking Sekarang'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue, // Text color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final statusKonfirmasi = booking['status_pembayaran'];
              final statusIcon = statusKonfirmasi == 'Confirmed'
                  ? Icons.check_circle
                  : (statusKonfirmasi == 'Pending'
                      ? Icons.hourglass_empty
                      : Icons.help);

              // Parse the booking date
              final tanggalPenggunaan =
                  DateTime.parse(booking['tanggal_penggunaan']);
              final today = DateTime.now();

              // Determine if the "Hubungi Admin" button should be shown
              final canContactAdmin = statusKonfirmasi == 'Pending' &&
                  tanggalPenggunaan.isAfter(today);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Lapangan
                      Text(
                        booking['nama_lapangan'],
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),

                      // Tanggal Booking
                      Text(
                        'Tanggal Booking: ${localDateUtils.DateUtils.formattedDate(DateTime.parse(booking['tanggal_booking']))}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),

                      // Tanggal Penggunaan
                      Text(
                        'Tanggal Penggunaan: ${localDateUtils.DateUtils.formattedDate(DateTime.parse(booking['tanggal_penggunaan']))}',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      SizedBox(height: 8),

                      Divider(),
                      SizedBox(height: 8),

                      // Sesi
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                              child: Text('Sesi: ${booking['sesi']}',
                                  style: TextStyle(fontSize: 16))),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Nama User
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(
                              child: Text('Nama User: ${booking['nama_user']}',
                                  style: TextStyle(fontSize: 16))),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Harga
                      Row(
                        children: [
                          Icon(Icons.money, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                              child: Text('Harga: ${booking['harga']}',
                                  style: TextStyle(fontSize: 16))),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Status Pembayaran
                      Row(
                        children: [
                          Icon(statusIcon,
                              color: statusKonfirmasi == 'Confirmed'
                                  ? Colors.green
                                  : (statusKonfirmasi == 'Pending'
                                      ? Colors.orange
                                      : Colors.grey)),
                          SizedBox(width: 8),
                          Expanded(
                              child: Text(
                                  'Status Pembayaran: ${booking['status_pembayaran']}',
                                  style: TextStyle(fontSize: 16))),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Jenis Lapangan
                      Row(
                        children: [
                          Icon(Icons.sports_soccer, color: Colors.purple),
                          SizedBox(width: 8),
                          Expanded(
                              child: Text(
                                  'Jenis Lapangan: ${booking['jenis_lapangan']}',
                                  style: TextStyle(fontSize: 16))),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Divider under Jenis Lapangan
                      Divider(),

                      SizedBox(height: 8),

                      // Pesan jika status konfirmasi adalah "Confirmed"
                      if (statusKonfirmasi == 'Confirmed')
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Mohon datang tepat waktu.\n',
                                    ),
                                    TextSpan(
                                      text: 'Batas maksimal 1 line 8 orang.',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                      SizedBox(height: 16),

                      // Hubungi Admin Button
                      if (canContactAdmin)
                        ElevatedButton(
                          onPressed: () => _launchWhatsApp('+6282268449779'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Hubungi Admin'),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue, // Text color
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
