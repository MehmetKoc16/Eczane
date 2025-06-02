import 'package:flutter/material.dart';
import 'package:eczane/Page/HomePage.dart';

void main() {
  runApp(const NobetciEczaneApp());
}

class NobetciEczaneApp extends StatefulWidget {
  const NobetciEczaneApp({super.key});

  @override
  State<NobetciEczaneApp> createState() => _NobetciEczaneAppState();
}

class _NobetciEczaneAppState extends State<NobetciEczaneApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nöbetçi Eczane',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
          titleMedium: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Colors.black54),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
          labelLarge: TextStyle(
              fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        cardTheme: CardThemeData(
          elevation: 3.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIconColor: Colors.teal,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false, // Debug banner'ını kaldır
    );
  }
}
