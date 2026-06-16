import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/api_service.dart';

class PanchangController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var isLocationLoading = false.obs;
  var panchangData = Rx<Map<String, dynamic>?>(null);

  // Selected date, time and location for Panchang
  var selectedDate = ''.obs;
  var selectedTime = ''.obs;
  var latitude = 28.6139.obs;  // Delhi default
  var longitude = 77.2090.obs; // Delhi default
  var placeName = 'New Delhi'.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with current date and time
    final now = DateTime.now();
    selectedDate.value = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    selectedTime.value = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    
    // Fetch exact location and Panchang on load
    fetchCurrentLocationAndPanchang();
  }

  Future<void> fetchCurrentLocationAndPanchang() async {
    isLocationLoading.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permission denied.');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('Location permissions permanently denied.');
        return;
      } 

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 6),
      );
      
      latitude.value = position.latitude;
      longitude.value = position.longitude;

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks.first;
          final String city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? 'My Location';
          placeName.value = city;
        } else {
          placeName.value = 'My Location';
        }
      } catch (geocodingError) {
        placeName.value = 'My Location';
        print('Geocoding error: $geocodingError');
      }
    } catch (e) {
      print('Location fetch error: $e');
    } finally {
      isLocationLoading.value = false;
      await fetchPanchang();
    }
  }

  Future<void> fetchPanchang() async {
    isLoading.value = true;
    try {
      var data = await apiService.getPanchang(
        date: selectedDate.value,
        time: selectedTime.value,
        lat: latitude.value,
        lon: longitude.value,
      );
      panchangData.value = data;
    } catch (e) {
      print('Error fetching panchang in controller: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateDate(String date) {
    selectedDate.value = date;
    fetchPanchang();
  }

  void updateTime(String time) {
    selectedTime.value = time;
    fetchPanchang();
  }

  void updateLocation(double lat, double lon, String name) {
    latitude.value = lat;
    longitude.value = lon;
    placeName.value = name;
    fetchPanchang();
  }
}
