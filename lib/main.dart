import 'package:flutter/material.dart';
import 'Pages/home_page.dart';

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
      debugShowCheckedModeBanner: false,
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
      ),
      home: const HomePage(),
    );
  }
}
