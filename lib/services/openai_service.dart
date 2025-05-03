import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static Future<String> sendMessage(String message) async {
    final apiKey = dotenv.env['API_OPENAI_KEY'] ?? '';
    if (apiKey.isEmpty) {
      return 'Error: API Key is missing.';
    }

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': message},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedBody);
      return data['choices'][0]['message']['content'].trim();
    } else {
      print('API Error: ${response.body}');
      return 'Lỗi: Không nhận được phản hồi từ API.';
    }
  }
}
