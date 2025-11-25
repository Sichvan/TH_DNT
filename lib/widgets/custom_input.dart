import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final Function(String) onChanged;
  final bool isPassword;
  final IconData icon;

  const CustomInput({
    Key? key,
    required this.label,
    required this.onChanged,
    required this.icon,
    this.isPassword = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        obscureText: isPassword,
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          labelText: label,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        validator: (val) => val!.isEmpty ? 'Vui lòng nhập $label' : null,
      ),
    );
  }
}
