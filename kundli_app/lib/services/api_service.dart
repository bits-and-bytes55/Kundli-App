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
      connectTimeout: const Duration(seconds: 120),
      receiveTimeout: const Duration(seconds: 120),
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
        // Removed print response.data to prevent DevTools OOM crash
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
    String? gender,
    String? partnerName,
    String? partnerDate,
    String? partnerTime,
    double? partnerLat,
    double? partnerLon,
  }) async {
    try {
      final Map<String, dynamic> reqData = {
        'name': name,
        'date': date,
        'time': time,
        'lat': lat,
        'lon': lon,
        'gender': gender ?? 'Male',
      };
      if (partnerName != null) reqData['partner_name'] = partnerName;
      if (partnerDate != null) reqData['partner_date'] = partnerDate;
      if (partnerTime != null) reqData['partner_time'] = partnerTime;
      if (partnerLat != null) reqData['partner_lat'] = partnerLat;
      if (partnerLon != null) reqData['partner_lon'] = partnerLon;

      final response = await dio.post('/kundli/generate', data: reqData);
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('API Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> matchMilan({
    required String boyName, required String boyDate, required String boyTime,
    required double boyLat, required double boyLon,
    required String girlName, required String girlDate, required String girlTime,
    required double girlLat, required double girlLon,
  }) async {
    try {
      final response = await dio.post('/kundli/milan', data: {
        'boy_name': boyName, 'boy_date': boyDate, 'boy_time': boyTime,
        'boy_lat': boyLat, 'boy_lon': boyLon,
        'girl_name': girlName, 'girl_date': girlDate, 'girl_time': girlTime,
        'girl_lat': girlLat, 'girl_lon': girlLon,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Milan API Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getGochar() async {
    try {
      final response = await dio.get('/kundli/gochar');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Gochar API Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getGrahaSthiti({
    required String name,
    required String date,
    required String time,
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await dio.post('/kundli/graha-sthiti', data: {
        'name': name, 'date': date, 'time': time, 'lat': lat, 'lon': lon,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('GrahaSthiti API Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getVarshphal({
    required String name,
    required String date,
    required String time,
    required double lat,
    required double lon,
    required int targetYear,
    String? gender,
  }) async {
    try {
      final response = await dio.post('/kundli/varshphal', data: {
        'name': name,
        'date': date,
        'time': time,
        'lat': lat,
        'lon': lon,
        'gender': gender ?? 'Male',
        'target_year': targetYear,
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Varshphal API Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPanchang({
    required String date,
    required String time,
    required double lat,
    required double lon,
  }) async {
    try {
      final response = await dio.post('/panchang', data: {
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
      print('Panchang API Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getHoroscope({required String rashi}) async {
    try {
      final response = await dio.get('/horoscope', queryParameters: {'rashi': rashi});
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Horoscope API Error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getSavedCharts(String phone, {String query = '', String mode = 'Basic', int page = 1, int limit = 20}) async {
    try {
      print('=== getSavedCharts CALLED ===');
      print('URL: /charts');
      print('QueryParams: phone=$phone, query=$query, page=$page, limit=$limit');
      
      final response = await dio.get('/charts', queryParameters: {
        'phone': phone,
        'query': query,
        'page': page,
        'limit': limit,
      });
      
      print('getSavedCharts Status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> list = response.data['data'];
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return null;
    } catch (e) {
      print('getSavedCharts API Error: $e');
      if (e is DioException) {
        print('DioException response: ${e.response?.data}');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> saveChart({
    required String phone,
    required String name,
    required String date,
    required String time,
    required double lat,
    required double lon,
    String? gender,
    String? place,
    String? mode,
  }) async {
    try {
      final response = await dio.post('/charts', data: {
        'phone': phone,
        'name': name,
        'date': date,
        'time': time,
        'lat': lat,
        'lon': lon,
        'gender': gender ?? 'Male',
        'place': place ?? '',
        'mode': mode ?? 'Basic',
      });
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('saveChart API Error: $e');
      return null;
    }
  }

  Future<bool> editChart({
    required String id,
    String? name,
    String? date,
    String? time,
    double? lat,
    double? lon,
    String? gender,
    String? place,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (date != null) updateData['date'] = date;
      if (time != null) updateData['time'] = time;
      if (lat != null) updateData['lat'] = lat;
      if (lon != null) updateData['lon'] = lon;
      if (gender != null) updateData['gender'] = gender;
      if (place != null) updateData['place'] = place;

      print('=== editChart CALLED ===');
      print('URL: /charts/$id');
      print('Body: $updateData');

      final response = await dio.put('/charts/$id', data: updateData);
      
      print('editChart Status: ${response.statusCode}');
      
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('editChart API Error: $e');
      if (e is DioException) {
        print('DioException response: ${e.response?.data}');
      }
      return false;
    }
  }

  Future<bool> deleteChart(String id) async {
    try {
      print('=== deleteChart CALLED ===');
      print('URL: /charts/$id');

      final response = await dio.delete('/charts/$id');
      
      print('deleteChart Status: ${response.statusCode}');

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      print('deleteChart API Error: $e');
      if (e is DioException) {
        print('DioException response: ${e.response?.data}');
      }
      return false;
    }
  }
}
