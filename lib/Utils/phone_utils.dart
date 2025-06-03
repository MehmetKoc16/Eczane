import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PhoneUtils {
  // Telefon arama fonksiyonu
  static Future<void> makePhoneCall(
      BuildContext context, String phoneNumber) async {
    // Telefon numarasını temizle (boşlukları ve parantezleri kaldır)
    final String cleanedNumber =
        phoneNumber.replaceAll(RegExp(r'[\s\(\)-]'), '');

    final Uri launchUri = Uri(scheme: 'tel', path: cleanedNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Arama yapılamadı: $phoneNumber')),
        );
        throw Exception('Could not launch $phoneNumber');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arama sırasında hata: $e')),
      );
      throw Exception('Error making phone call: $e');
    }
  }
}
