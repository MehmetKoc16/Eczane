import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../Models/pharmacy_model.dart';

class PharmacyService {
  static const String _baseUrl =
      "https://api.collectapi.com/health/dutyPharmacy";
  static const String _apikey =
      "apikey 1O4iBRjCxv4eflQqKKv0Rc:7laKqrEuiayIRhOxKiSYrN";

  final Dio _dio = Dio();
  
  // Kullanıcının konumunu alır ve il/ilçe bilgisine dönüştürür
  Future<Map<String, String>> getLocation() async {
    try {
      // Konum izni kontrolü
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Konum izni reddedildi.");
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception("Konum izni kalıcı olarak reddedildi. Ayarlardan izin vermeniz gerekiyor.");
      }
      
      // Konum al
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
      
      // Konum bilgisini adres bilgisine dönüştür
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
      print("Konum alınırken hata: $e");
      rethrow;
    }
  }

  // Nöbetçi eczaneleri getirir
  Future<List<PharmacyModel>> getOnDutyPharmacies({String? city, String? district}) async {
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
      
      // API'den gelen veriyi PharmacyModel'e dönüştür
      final List<PharmacyModel> pharmacies = pharmacyResult.map((jsonItem) => 
        PharmacyModel.fromJson(jsonItem)
      ).toList();
      
      return pharmacies;
    } on DioException catch (e) {
      if (e.response != null) {
        print("Dio Error: ${e.response?.statusCode} - ${e.response?.statusMessage}");
        print("Response data: ${e.response?.data}");
        throw Exception("API hatası: ${e.response?.statusCode} - ${e.response?.statusMessage}");
      } else {
        print("Dio Error without response: ${e.message}");
        throw Exception("Bağlantı hatası: ${e.message}");
      }
    } catch (e) {
      print("General Error: $e");
      throw Exception("Beklenmeyen hata: $e");
    }
  }
  
  // Türkçe karakterleri düzeltme yardımcı metodu
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