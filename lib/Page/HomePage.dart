import 'package:eczane/Model/eczane_model.dart';
import 'package:eczane/Service/eczane_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  // Kullanıcıya gösterilecek konum bilgisi
  String _currentLocationDisplay = "Konum Alınıyor...";
  DateTime _currentDate = DateTime.now();

  final EczaneService _pharmacyService = EczaneService();
  List<EczaneModel> _allPharmacies = [];
  List<EczaneModel> _filteredPharmacies = [];
  bool _isLoading = true; // Yükleme durumunu izler
  String? _errorMessage; // Hata mesajlarını tutar

  // Konum değiştirme diyaloğu için controller'lar
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPharmacies(); // Uygulama başladığında eczaneleri yükle
    _searchController
        .addListener(_filterPharmacies); // Arama çubuğu dinleyicisi
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
      _isLoading = true; // Yüklemeyi başlat
      _errorMessage = null; // Önceki hataları temizle
      _allPharmacies = []; // Listeleri temizle
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
            // Baştaki virgülü temizle
            _currentLocationDisplay =
                _currentLocationDisplay.substring(1).trim();
          }
        });
      } else {
        // Eğer il ve ilçe belirtilmişse, display'i güncelle
        setState(() {
          _currentLocationDisplay = "$district, $city";
        });
      }

      // PharmacyService'i kullanarak eczaneleri çek
      final List<EczaneModel> fetchedPharmacies =
          await _pharmacyService.getOnDutyEczane(
        city: city,
        district: district,
      );

      setState(() {
        _allPharmacies = fetchedPharmacies;
        _filteredPharmacies = fetchedPharmacies;
        _isLoading = false; // Yüklemeyi bitir
      });
    } catch (e) {
      setState(() {
        _errorMessage = e
            .toString()
            .replaceFirst('Exception: ', ''); // "Exception: " kısmını kaldır
        _isLoading = false; // Yüklemeyi bitir
        _currentLocationDisplay =
            "Konum Alınamadı"; // Hata durumunda konum bilgisini güncelle
      });
      print('Eczane verileri yüklenirken hata oluştu: $e');
      // Kullanıcıya hata mesajı göster
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

  // Telefon arama fonksiyonu (gerçek uygulamada url_launcher kullanılır)
  Future<void> _makePhoneCall(String phoneNumber) async {
    // final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    // if (await canLaunchUrl(launchUri)) {
    //   await launchUrl(launchUri);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Arama yapılamadı: $phoneNumber')),
    //   );
    //   print('Could not launch $phoneNumber');
    // }
    print('Arama yapılıyor: $phoneNumber'); // Simülasyon
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Arama simülasyonu: $phoneNumber')),
    );
  }

  // Haritada gösterme fonksiyonu (gerçek uygulamada url_launcher veya map plugin kullanılır)
  Future<void> _openMap(
      double latitude, double longitude, String pharmacyName) async {
    // final String googleMapsUrl = "http://maps.google.com/maps?q=$latitude,$longitude";
    // final Uri launchUri = Uri.parse(googleMapsUrl);
    // if (await canLaunchUrl(launchUri)) {
    //   await launchUrl(launchUri);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('$pharmacyName haritada gösterilemedi.')),
    //   );
    //   print('Could not launch map for $pharmacyName');
    // }
    print(
        'Haritada gösteriliyor: $pharmacyName ($latitude, $longitude)'); // Simülasyon
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$pharmacyName için harita simülasyonu.')),
    );
  }

  // Basit tarih formatlama fonksiyonu (GG/AA/YYYY)
  String _formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = _formatDate(_currentDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nöbetçi Eczaneler'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Konum ve Tarih Bilgisi Alanı
          Container(
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
                          Icon(Icons.location_on,
                              color: Colors.teal[700], size: 20),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'Konum: $_currentLocationDisplay', // Güncellenen konum display
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
                      onPressed:
                          _changeLocation, // Konum değiştirme metodunu çağır
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
                    Icon(Icons.calendar_today,
                        color: Colors.teal[700], size: 20),
                    const SizedBox(width: 8.0),
                    Text(
                      formattedDate, // Güncellenmiş tarih formatı
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.teal[800]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Arama Çubuğu
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Eczane adı, ilçe veya adres ara...',
                prefixIcon: Icon(Icons.search, color: Colors.teal[700]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.teal[700]),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.teal[200]!)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.teal[200]!)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.teal, width: 2)),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 14.0, horizontal: 20.0),
              ),
            ),
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
                        if (_allPharmacies.isNotEmpty &&
                            _searchController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Farklı bir anahtar kelime deneyin.',
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
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
                        onCall: () => _makePhoneCall(pharmacy.phone),
                        onMap: () => _openMap(pharmacy.latitude,
                            pharmacy.longitude, pharmacy.name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Tek bir eczane kartını gösteren Widget
class PharmacyCard extends StatelessWidget {
  final EczaneModel pharmacy;
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
            // Eczane Adı ve Mesafe
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pharmacy.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.teal[800]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
