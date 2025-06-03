import 'package:flutter/material.dart';
import '../Utils/date_utils.dart';

class LocationHeader extends StatelessWidget {
  final String locationDisplay;
  final DateTime currentDate;
  final VoidCallback onChangeLocation;

  const LocationHeader({
    super.key,
    required this.locationDisplay,
    required this.currentDate,
    required this.onChangeLocation,
  });

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormatter.formatDate(currentDate);

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.teal.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Konum Bilgisi ve Değiştirme Butonu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.teal[700], size: 20),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Konum: $locationDisplay',
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.teal[800]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                icon: Icon(Icons.edit_location_alt_outlined,
                    size: 18, color: Colors.teal[700]),
                label: const Text('Değiştir',
                    style: TextStyle(color: Colors.teal, fontSize: 14)),
                onPressed: onChangeLocation,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          // Tarih Bilgisi
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.teal[700], size: 20),
              const SizedBox(width: 8.0),
              Text(
                formattedDate,
                style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal[800]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}