import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  Future<void> fetchData() async {
    final url = Uri.parse(ApiConfig.baseUrl);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        json.decode(response.body);
      } else {
        if (kDebugMode) {
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
