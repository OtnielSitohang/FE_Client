import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String email;
  final String newEmail;
  final String tempatTinggal;
  final String newTempatTinggal;
  final VoidCallback onConfirm;

  ConfirmationDialog({
    required this.email,
    required this.newEmail,
    required this.tempatTinggal,
    required this.newTempatTinggal,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Konfirmasi Perubahan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email:'),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text('Lama: $email'),
              ),
              Expanded(
                child: Text('Baru: $newEmail'),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text('Tempat Tinggal:'),
          SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text('Lama: $tempatTinggal'),
              ),
              Expanded(
                child: Text('Baru: $newTempatTinggal'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          child: Text('Konfirmasi'),
        ),
      ],
    );
  }
}
