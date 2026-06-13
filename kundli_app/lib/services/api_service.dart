import 'package:get/get.dart';
import 'package:dio/dio.dart';

class ApiService extends GetxService {
  late Dio dio;
  final String baseUrl = 'https://kundli.bitsandbytesitsolution.com/api';
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

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('================ API REQUEST ================');
        print('URL: ${options.uri}');
        print('METHOD: ${options.method}');
        print('BODY: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('================ API RESPONSE ================');
        print('URL: ${response.requestOptions.uri}');
        print('STATUS CODE: ${response.statusCode}');
        print('RESPONSE DATA: ${response.data}');
        print('==============================================');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('================ API ERROR ================');
        print('URL: ${e.requestOptions.uri}');
        print('STATUS CODE: ${e.response?.statusCode}');
        print('ERROR MESSAGE: ${e.message}');
        print('===========================================');
        return handler.next(e);
      },
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
