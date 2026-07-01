import 'package:get/get.dart';
import '../services/api_service.dart';

class KundliController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var kundliData = Rx<Map<String, dynamic>?>(null);
  var deathKundliData = Rx<Map<String, dynamic>?>(null);
  
  var isVarshphalLoading = false.obs;
  var varshphalData = Rx<Map<String, dynamic>?>(null);

  Future<void> fetchKundli(String name, String date, String time, double lat, double lon, {String? gender, String? place, bool forceRefresh = false}) async {
    // Best Practice: GetX controllers me data already loaded ho to API dobara mat call karo
    if (!forceRefresh && kundliData.value != null) {
      // Basic check: if we already have some data, we could just return early. 
      // But since parameters might change, caching at the ApiService level (which we already did) is safer.
      // However, to strictly follow the best practice for identical UI reloads:
      print('KundliController: Data already loaded, skipping API call.');
      return;
    }

    isLoading.value = true;
    try {
      var data = await apiService.generateKundli(
        name: name,
        date: date,
        time: time,
        lat: lat,
        lon: lon,
        gender: gender,
      );
      if (data != null && place != null) {
        data['place'] = place;
        if (data['personal_details'] != null && data['personal_details'] is Map) {
          data['personal_details']['place'] = place;
        }
      }
      kundliData.value = data;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDeathKundli(String name, String date, String time, double lat, double lon, {String? gender, String? place}) async {
    try {
      var data = await apiService.generateKundli(
        name: name,
        date: date,
        time: time,
        lat: lat,
        lon: lon,
        gender: gender,
      );
      if (data != null && place != null) {
        data['place'] = place;
        if (data['personal_details'] != null && data['personal_details'] is Map) {
          data['personal_details']['place'] = place;
        }
      }
      deathKundliData.value = data;
    } catch (e) {
      print("Error fetching death kundli: $e");
    }
  }

  Future<void> fetchVarshphal(String name, String date, String time, double lat, double lon, int targetYear, {String? gender, bool forceRefresh = false}) async {
    // Best Practice: GetX controllers me data already loaded ho to API dobara mat call karo
    if (!forceRefresh && varshphalData.value != null) {
      print('KundliController: Varshphal data already loaded, skipping API call.');
      return;
    }

    isVarshphalLoading.value = true;
    try {
      var data = await apiService.getVarshphal(
        name: name,
        date: date,
        time: time,
        lat: lat,
        lon: lon,
        targetYear: targetYear,
        gender: gender,
      );
      varshphalData.value = data;
    } finally {
      isVarshphalLoading.value = false;
    }
  }
}
