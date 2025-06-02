class EczaneModel {
  final String name;
  final String dist;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;

  EczaneModel({
    required this.name,
    required this.dist,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
  });
  factory EczaneModel.fromJson(Map<String, dynamic> json) {
    final locParts = (json['loc'] as String).split(',');
    return EczaneModel(
        name: json["name"] as String,
        dist: json["dist"] as String,
        address: json["address"] as String,
        phone: json["phone"] as String,
        latitude: double.parse(locParts[0]),
        longitude: double.parse(locParts[1]));
  }
}
