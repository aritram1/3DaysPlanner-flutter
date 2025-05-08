import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:threedaysplanner/util/app_constants.dart'; // Import the app constants
import 'package:threedaysplanner/util/secure_file_manager.dart'; // Import the secure file manager
class SalesforceAuth {

  static String? accessToken;

  /// Method 1: Authenticate using Client Credentials Flow
  static Future<bool> authenticate() async {
    final url = Uri.parse('${AppConstants.instanceUrl}/services/oauth2/token');
    final response = await http.post(
      url,
      body: {
        'grant_type': 'client_credentials',
        'client_id': AppConstants.clientId,
        'client_secret': AppConstants.clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      accessToken = data['access_token'];

      // Save the token and response info to secure storage
      await SecureFileManager.saveAuthInfo(data);

      return true;
    } 
    else {
      print('Authentication failed: ${response.body}');
      return false;
    }
  }
}