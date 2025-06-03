import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  static Future<void> openMap(BuildContext context, double latitude,
      double longitude, String pharmacyName) async {
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
    final Uri launchUri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        // Apple Maps URL'i dene (iOS için)
        final String appleMapsUrl =
            "https://maps.apple.com/?q=$pharmacyName&ll=$latitude,$longitude";
        final Uri appleUri = Uri.parse(appleMapsUrl);

        if (await canLaunchUrl(appleUri)) {
          await launchUrl(appleUri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$pharmacyName haritada gösterilemedi.')),
          );
          throw Exception('Could not launch map for $pharmacyName');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harita açılırken hata: $e')),
      );
      throw Exception('Error opening map: $e');
    }
  }
}
