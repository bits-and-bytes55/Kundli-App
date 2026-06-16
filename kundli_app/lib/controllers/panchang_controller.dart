import 'package:get/get.dart';
import '../services/api_service.dart';

class PanchangController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();

  var isLoading = false.obs;
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
    
    // Fetch initial Panchang
    fetchPanchang();
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
