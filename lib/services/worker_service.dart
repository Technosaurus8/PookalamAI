import 'dart:convert';
import 'package:http/http.dart' as http;

class WorkerService {
  static const String workerUrl =
      'https://pookalam-worker.amanmuhammed515.workers.dev';

  static Future<Map<String, dynamic>> scoreImage(String base64Image) async {
    final response = await http.post(
      Uri.parse(workerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'imageBase64': base64Image}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Worker returned ${response.statusCode}: ${response.body}',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
