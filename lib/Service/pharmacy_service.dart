import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../Models/pharmacy_model.dart';

class PharmacyService {
  static const String _baseUrl =
      "https://api.collectapi.com/health/dutyPharmacy";
  static const String _apikey =
      "apikey 1O4iBRjCxv4eflQqKKv0Rc:7laKqrEuiayIRhOxKiSYrN";

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 10),
  ));

  Future<Map<String, String>> getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Konum izni reddedildi.");
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            "Konum izni kalıcı olarak reddedildi. Ayarlardan izin vermeniz gerekiyor.");
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw Exception("Konum bilgisi adrese dönüştürülemedi.");
      }

      final Placemark place = placemarks.first;

      // Türkçe karakterleri düzelt
      String city = _normalizeText(place.administrativeArea ?? '');
      String district = _normalizeText(place.subAdministrativeArea ?? '');

      return {
        'city': city,
        'district': district,
      };
    } catch (e) {
      throw Exception("Konum alınırken hata: $e");
    }
  }

  Future<List<PharmacyModel>> getOnDutyPharmacies(
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

      String url = '$_baseUrl?il=${Uri.encodeComponent(targetCity)}';
      if (targetDistrict.isNotEmpty) {
        url += '&ilce=${Uri.encodeComponent(targetDistrict)}';
      }

      final Map<String, dynamic> headers = {
        "authorization": _apikey,
        "content-type": "application/json",
      };

      int maxRetries = 3;
      int retryCount = 0;
      Response? response;

      while (retryCount < maxRetries) {
        try {
          response = await _dio.get(url, options: Options(headers: headers));
          break;
        } on DioException catch (e) {
          retryCount++;
          if (retryCount >= maxRetries) {
            rethrow;
          }
          await Future.delayed(Duration(seconds: 1 * retryCount));
          throw Exception(
              'API isteği başarısız oldu, yeniden deneniyor ($retryCount/$maxRetries)');
        }
      }

      if (response == null || response.statusCode != 200) {
        throw Exception(
            "API'den veri çekerken hata oluştu. ${response?.statusCode}");
      }

      final Map<String, dynamic> responseData = response.data;

      if (responseData['success'] != true) {
        throw Exception(
            "API'den başarılı yanıt alınamadı: ${responseData['reason'] ?? 'Bilinmeyen Hata'}");
      }

      final List<dynamic> pharmacyResult = responseData["result"];

      final List<PharmacyModel> pharmacies = pharmacyResult
          .map((jsonItem) => PharmacyModel.fromJson(jsonItem))
          .toList();

      return pharmacies;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception(
            "Timeout hatası: API yanıt vermedi. Lütfen internet bağlantınızı kontrol edin ve tekrar deneyin.");
      }

      if (e.response != null) {
        throw Exception(
            "API hatası: ${e.response?.statusCode} - ${e.response?.statusMessage}. Response data: ${e.response?.data}");
      } else {
        throw Exception("Bağlantı hatası: ${e.message}");
      }
    } catch (e) {
      throw Exception("Beklenmeyen hata: $e");
    }
  }

  String _normalizeText(String text) {
    const turkishChars = 'çğıöşüÇĞİÖŞÜ';
    const englishChars = 'cgiosuCGIOSU';

    String normalized = text;
    for (int i = 0; i < turkishChars.length; i++) {
      normalized = normalized.replaceAll(turkishChars[i], englishChars[i]);
    }

    return normalized;
  }
}
