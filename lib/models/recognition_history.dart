import 'dart:io';

import 'package:nkust/bloc/recognition/recognition_state.dart';

class RecognitionHistory {
  final String id;
  final File image;
  final RecognitionType type;
  final List<Map<String, dynamic>> result;
  final DateTime timestamp;

  RecognitionHistory({
    required this.id,
    required this.image,
    required this.type,
    required this.result,
    required this.timestamp,
  });
}
