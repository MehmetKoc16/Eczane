import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:eczane/Model/eczane_model.dart';

class EczaneService {
  static const String _baseUrl =
      "https://api.collectapi.com/health/dutyPharmacy";
  static const String _apikey =
      "apikey 1O4iBRjCxv4eflQqKKv0Rc:7laKqrEuiayIRhOxKiSYrN";

  final Dio _dio = Dio();
  Future<Map<String, String>> getLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Konum servisi kapalı. Lütfen açınız.");
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Konum izni reddedildi. Lütfen izin veriniz.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          "Konum izni kalıcı olarak reddedildi.Uygulama ayarlarından izin vermelisiniz.");
    }
    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
    final List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isEmpty) {
      throw Exception("Adres bilgisi alınamadı");
    }
    final String city = placemarks[0].administrativeArea ?? '';
    final String district = placemarks[0].subAdministrativeArea ?? '';
    if (city.isEmpty) {
      throw Exception("Şehir bilgisi alınamadı.");
    }

    return {'city': city, 'district': district};
  }

  Future<List<EczaneModel>> getOnDutyEczane(
      {String? city, String? district}) async {
    String targetCity = city ?? '';
    String targetDistrict = district ?? '';
    try {
      if (targetCity.isEmpty || targetDistrict.isEmpty) {
        final Map<String, String> locationData = await getLocation();
        targetCity = locationData['city'] ?? '';
        targetDistrict = locationData['district'] ?? '';
        if (targetCity.isEmpty) {
          throw Exception("Konum bilgisi (şehir) alınamadı veya belirtilmedi.");
        }
      }

      // URL parametrelerini oluştur
      String url = '$_baseUrl?il=${Uri.encodeComponent(targetCity)}';
      if (targetDistrict.isNotEmpty) {
        url += '&ilce=${Uri.encodeComponent(targetDistrict)}';
      }

      // CollectAPI header'larını ayarla
      final Map<String, dynamic> headers = {
        "authorization": _apikey,
        "content-type": "application/json",
      };

      final response = await _dio.get(url, options: Options(headers: headers));

      if (response.statusCode != 200) {
        throw Exception(
            "API'den veri çekerken hata oluştu. ${response.statusCode}");
      }

      final Map<String, dynamic> responseData = response.data;

      if (responseData['success'] != true) {
        throw Exception(
            "API'den başarılı yanıt alınamadı: ${responseData['reason'] ?? 'Bilinmeyen Hata'}");
      }

      final List<dynamic> pharmacyResult = responseData["result"];

      // CollectAPI'den gelen veriyi EczaneModel'e dönüştür
      final List<EczaneModel> eczane = pharmacyResult
          .map((jsonItem) => EczaneModel.fromJson(jsonItem))
          .toList();

      return eczane;
    } on DioException catch (e) {
      if (e.response != null) {
        print(
            "Dio Error: ${e.response?.statusCode} - ${e.response?.statusMessage}");
        print("Response data: ${e.response?.data}");
        throw Exception(
            "API hatası: ${e.response?.statusCode} - ${e.response?.statusMessage}");
      } else {
        print("Dio Error without response: ${e.message}");
        throw Exception("Bağlantı hatası: ${e.message}");
      }
    } catch (e) {
      print("General Error: $e");
      throw Exception("Beklenmeyen hata: $e");
    }
  }
}
