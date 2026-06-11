import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://latoya-traumatic-delmer.ngrok-free.dev";

  static Future<dynamic> sendImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamed = await request.send();
      final response = await streamed.stream.bytesToString();

      final decodedResponse = jsonDecode(response);

      return decodedResponse;
    } catch (e) {
      return {"error": e.toString()};
    }
  }
}
