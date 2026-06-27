import 'package:get/get.dart';
import '../services/api_service.dart';

class KundliController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();

  var isLoading = false.obs;
  var kundliData = Rx<Map<String, dynamic>?>(null);
  var deathKundliData = Rx<Map<String, dynamic>?>(null);
  
  var isVarshphalLoading = false.obs;
  var varshphalData = Rx<Map<String, dynamic>?>(null);

  Future<void> fetchKundli(String name, String date, String time, double lat, double lon, {String? gender, String? place}) async {
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

  Future<void> fetchVarshphal(String name, String date, String time, double lat, double lon, int targetYear, {String? gender}) async {
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
