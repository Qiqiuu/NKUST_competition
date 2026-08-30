import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionService {
    final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    Future<String> recognizeText(File image) async {
        final inputImage = InputImage.fromFile(image);
        final RecognizedText recognizedText = await _recognizer.processImage(inputImage);
        return recognizedText.text;
    }

    void dispose() {
        _recognizer.close();
    } 
}