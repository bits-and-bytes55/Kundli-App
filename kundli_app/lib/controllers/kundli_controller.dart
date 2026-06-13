import 'package:get/get.dart';
import '../services/api_service.dart';

class KundliController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var kundliData = Rx<Map<String, dynamic>?>(null);

  Future<void> fetchKundli(String name, String date, String time, double lat, double lon) async {
    isLoading.value = true;
    try {
      var data = await _apiService.generateKundli(
        name: name,
        date: date,
        time: time,
        lat: lat,
        lon: lon,
      );
      kundliData.value = data;
    } finally {
      isLoading.value = false;
    }
  }
}
