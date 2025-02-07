import 'config.dart';
import 'package:http/http.dart' as http;

class TestAPI {
  static Future<void> testApi() async {
    var response = await http.get(Uri.http(Config.apiUrl));

    try {
      if (response.statusCode == 200) {
        print('Uploaded successfully!');
        print('Response body: ${response.body}');
      } else {
        print('Failed to upload. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Failed to upload. Error: $e');
    }
  }
}
