import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureFileManager {
  static const _storage = FlutterSecureStorage();
  static const _authKey = 'salesforce_auth_info';

  /// Save authentication info to secure storage
  static Future<void> saveAuthInfo(Map<String, dynamic> authInfo) async {
    await _storage.write(key: _authKey, value: jsonEncode(authInfo));
  }

  /// Get authentication info from secure storage
  static Future<Map<String, dynamic>?> getAuthInfo() async {
    final authInfo = await _storage.read(key: _authKey);
    if (authInfo != null) {
      return jsonDecode(authInfo);
    }
    return null;
  }

  /// Delete authentication info from secure storage
  static Future<void> deleteAuthInfo() async {
    await _storage.delete(key: _authKey);
  }

}