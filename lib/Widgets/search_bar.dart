import 'package:flutter/material.dart';

class PharmacySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const PharmacySearchBar({
    super.key,
    required this.controller,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Eczane adı, ilçe veya adres ara...',
          prefixIcon: Icon(Icons.search, color: Colors.teal[700]),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.teal[700]),
                  onPressed: onClear,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: Colors.teal[200]!)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: Colors.teal[200]!)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide(color: Colors.teal, width: 2)),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 14.0, horizontal: 20.0),
        ),
      ),
    );
  }
}