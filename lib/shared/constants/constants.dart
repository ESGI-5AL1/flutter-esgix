import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static var apiKey = dotenv.env['API_KEY'];
  static var apiBaseUrl = dotenv.env['BASE_URL'];
}