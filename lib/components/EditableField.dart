import 'package:flutter/material.dart';

class EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isEdited;
  final Function(String) onChanged;

  EditableField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.isEdited,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      subtitle: TextField(
        controller: controller,
        enabled: true,
        onChanged: onChanged,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(icon),
            onPressed: () {
              // Toggle the edit state
              if (label == 'Email') {
                onChanged(controller.text);
              } else if (label == 'Tempat Tinggal') {
                onChanged(controller.text);
              }
            },
          ),
        ),
      ),
    );
  }
}
