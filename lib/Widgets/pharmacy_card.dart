import 'package:flutter/material.dart';
import '../Models/pharmacy_model.dart';

class PharmacyCard extends StatelessWidget {
  final PharmacyModel pharmacy;
  final VoidCallback onCall;
  final VoidCallback onMap;

  const PharmacyCard({
    super.key,
    required this.pharmacy,
    required this.onCall,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eczane Adı
            Text(
              pharmacy.name,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.teal[800]),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6.0),

            // İlçe Bilgisi
            Text(
              pharmacy.dist,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.black54, fontSize: 15),
            ),
            const SizedBox(height: 10.0),

            // Adres Bilgisi
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_pin, color: Colors.red[400], size: 20.0),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    pharmacy.address,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(height: 1.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),

            // Telefon Bilgisi
            Row(
              children: [
                Icon(Icons.phone, color: Colors.blue[600], size: 20.0),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    pharmacy.phone,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Butonlar (Ara ve Haritada Göster)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.call, size: 18),
                  label: const Text('Ara'),
                  onPressed: onCall,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10)),
                ),
                const SizedBox(width: 12.0),
                ElevatedButton.icon(
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Harita'),
                  onPressed: onMap,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}