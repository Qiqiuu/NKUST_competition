import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageRecognitionService {
  Future<String> recognizeImage(File image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://127.0.0.1:8000/recognize'),
    );

    request.files.add(await http.MultipartFile.fromPath('file', image.path));
    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var json = jsonDecode(responseData);
    return json['medicine'];
  }
}
