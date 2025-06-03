import 'package:flutter/material.dart';
import '../Models/pharmacy_model.dart';
import '../Service/pharmacy_service.dart';
import '../Utils/map_utils.dart';
import '../Utils/phone_utils.dart';
import '../Widgets/pharmacy_card.dart';
import '../Widgets/location_header.dart';
import '../Widgets/search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PharmacyService _pharmacyService = PharmacyService();
  final TextEditingController _searchController = TextEditingController();
  final DateTime _currentDate = DateTime.now();
  String _currentLocationDisplay = "Konum alınıyor...";

  List<PharmacyModel> _allPharmacies = [];
  List<PharmacyModel> _filteredPharmacies = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Konum değiştirme diyaloğu için controller'lar
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPharmacies();
    _searchController.addListener(_filterPharmacies);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterPharmacies);
    _searchController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  // Eczaneleri PharmacyService'ten yükleyen metod
  Future<void> _loadPharmacies({String? city, String? district}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _allPharmacies = [];
      _filteredPharmacies = [];
    });

    try {
      if (city == null ||
          district == null ||
          city.isEmpty ||
          district.isEmpty) {
        final Map<String, String> locationData =
            await _pharmacyService.getLocation();
        city = locationData['city'];
        district = locationData['district'];
        setState(() {
          _currentLocationDisplay = "${district ?? ''}, ${city ?? ''}".trim();
          if (_currentLocationDisplay.startsWith(',')) {
            _currentLocationDisplay =
                _currentLocationDisplay.substring(1).trim();
          }
        });
      } else {
        setState(() {
          _currentLocationDisplay = "$district, $city";
        });
      }

      // PharmacyService'i kullanarak eczaneleri çek
      final List<PharmacyModel> fetchedPharmacies = await _pharmacyService
          .getOnDutyPharmacies(city: city, district: district);

      setState(() {
        _allPharmacies = fetchedPharmacies;
        _filteredPharmacies = fetchedPharmacies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        _currentLocationDisplay = "Konum Alınamadı";
      });
      throw Exception('Eczane verileri yüklenirken hata oluştu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $_errorMessage')),
      );
    }
  }

  // Arama çubuğuna göre eczaneleri filtrele
  void _filterPharmacies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredPharmacies = _allPharmacies.where((pharmacy) {
        return pharmacy.name.toLowerCase().contains(query) ||
            pharmacy.dist.toLowerCase().contains(query) ||
            pharmacy.address.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Konum değiştirme fonksiyonu
  Future<void> _changeLocation() async {
    // Mevcut konum bilgilerini controller'lara yükle
    final currentParts =
        _currentLocationDisplay.split(',').map((s) => s.trim()).toList();
    _districtController.text = currentParts.length > 1 ? currentParts[0] : '';
    _cityController.text =
        currentParts.length > 1 ? currentParts[1] : currentParts[0];

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konum Değiştir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _cityController,
                decoration:
                    const InputDecoration(hintText: "Şehir (örn: Ankara)"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _districtController,
                decoration:
                    const InputDecoration(hintText: "İlçe (örn: Çankaya)"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop({
                  'city': _cityController.text.trim(),
                  'district': _districtController.text.trim(),
                });
              },
            ),
          ],
        );
      },
    );

    if (result != null) {
      final String newCity = result['city'] ?? '';
      final String newDistrict = result['district'] ?? '';

      if (newCity.isNotEmpty) {
        // Yeni konuma göre eczaneleri yükle
        _loadPharmacies(city: newCity, district: newDistrict);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konum güncellendi: $newDistrict, $newCity')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şehir bilgisi boş bırakılamaz.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nöbetçi Eczaneler'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Konum ve Tarih Bilgisi Alanı
          LocationHeader(
            locationDisplay: _currentLocationDisplay,
            currentDate: _currentDate,
            onChangeLocation: _changeLocation,
          ),

          // Arama Çubuğu
          PharmacySearchBar(
            controller: _searchController,
            onClear: () {
              _searchController.clear();
            },
          ),

          // Yükleme Göstergesi, Hata Mesajı veya Sonuç Başlığı
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.teal),
            )
          else if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Hata: $_errorMessage',
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          else if (_filteredPharmacies.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                _searchController.text.isEmpty
                    ? 'Yakındaki Nöbetçi Eczaneler'
                    : '${_filteredPharmacies.length} sonuç bulundu',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.teal[800]),
              ),
            ),

          // Eczane Listesi
          Expanded(
            child: _filteredPharmacies.isEmpty &&
                    !_isLoading &&
                    _errorMessage == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _allPharmacies.isEmpty
                              ? 'Nöbetçi eczane bulunamadı.'
                              : 'Aramanızla eşleşen eczane bulunamadı.',
                          style: TextStyle(
                              fontSize: 18.0, color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredPharmacies.length,
                    itemBuilder: (context, index) {
                      final pharmacy = _filteredPharmacies[index];
                      return PharmacyCard(
                        pharmacy: pharmacy,
                        onCall: () =>
                            PhoneUtils.makePhoneCall(context, pharmacy.phone),
                        onMap: () => MapUtils.openMap(
                            context,
                            pharmacy.latitude,
                            pharmacy.longitude,
                            pharmacy.name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
