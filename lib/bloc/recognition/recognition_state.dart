import 'dart:io';

import 'package:nkust/models/recognition_history.dart';

enum RecognitionType { text, image }

class RecognitionState {
  final File? image;
  final RecognitionType? type;
  final bool loading;
  final List<Map<String, dynamic>> result;
  final List<RecognitionHistory> history;

  const RecognitionState({
    this.image,
    this.type,
    this.loading = false,
    this.result = const [],
    this.history = const [],
  });

  RecognitionState copyWith({
    File? image,
    RecognitionType? type,
    bool? loading,
    List<Map<String, dynamic>>? result,
    List<RecognitionHistory>? history,
  }) {
    return RecognitionState(
      image: image ?? this.image,
      type: type ?? this.type,
      loading: loading ?? this.loading,
      result: result ?? this.result,
      history: history ?? this.history,
    );
  }
}
