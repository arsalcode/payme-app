import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class AuthService {
  get baseUrl => null;

  Future<bool> checkEmail(String email) async {
    try {
      final res = await http.post(
          Uri.parse(
            '$baseUrl/is-email-exist',
          ),
          body: {
            'email': email,
          });

      if (res.statusCode == 200) {
        return jsonDecode(res.body)['is-email-exist'];
      } else {
        return jsonDecode(res.body)['erroes'];
      }
    } catch (e) {
      rethrow;
    }
  }
}
