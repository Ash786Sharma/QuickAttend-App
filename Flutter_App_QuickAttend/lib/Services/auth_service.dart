import 'api_service.dart';

class AuthService {
  static Future<dynamic> login(String employeeId) async {
    final response = await ApiService.post('/auth/login', {'employeeId': employeeId});
    return response;
  }

  static Future<dynamic> register(Map<String, dynamic> userData) async {
    final response = await ApiService.post('/auth/register', userData);
    return response;
  }
}
