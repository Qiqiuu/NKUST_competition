import 'dart:io';

import 'package:nkust/bloc/recognition/recognition_state.dart';

abstract class RecognitionEvent {}

class ImageSelected extends RecognitionEvent {
  final File image;
  ImageSelected(this.image);
}

class RecognitionTypeSelected extends RecognitionEvent {
  final RecognitionType type;
  RecognitionTypeSelected(this.type);
}

class ImageCleared extends RecognitionEvent {}

class AddToHistory extends RecognitionEvent {}

class ClearHistory extends RecognitionEvent {}

class DeleteHistoryItem extends RecognitionEvent {
  final String historyItemId;
  DeleteHistoryItem(this.historyItemId);
}
