import 'package:get/get.dart';
import 'package:dio/dio.dart';

class ApiService extends GetxService {
  late Dio dio;
  
  final String baseUrl = 'http://10.0.2.2:8000/api';

  @override
  void onInit() {
    super.onInit();
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      }
    ));
  }

  Future<Map<String, dynamic>?> generateKundli({
    required String name,
    required String date,
    required String time,
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await dio.post('/kundli/generate', data: {
        'name': name,
        'date': date,
        'time': time,
        'lat': lat,
        'lon': lon,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('API Error: $e');
      return null;
    }
  }
}
