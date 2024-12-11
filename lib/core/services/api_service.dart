import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';

class ApiService {
  Future<void> fetchData() async {
    final url = Uri.parse(ApiConfig.baseUrl);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (kDebugMode) {
          print('Fetched data: $data');
        }

        return data;
      } else {
        if (kDebugMode) {
          print('Failed to fetch data: ${response.statusCode}');
          print('Error details: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }
}
