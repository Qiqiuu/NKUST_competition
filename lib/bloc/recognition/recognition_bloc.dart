import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nkust/bloc/recognition/recognition_event.dart';
import 'package:nkust/bloc/recognition/recognition_state.dart';
import 'package:nkust/models/recognition_history.dart';
import 'package:nkust/services/image_recognition_service.dart';
import 'package:nkust/services/text_recognition_service.dart';
import 'package:nkust/utils/utils.dart';
import 'package:uuid/uuid.dart';

class RecognitionBloc extends Bloc<RecognitionEvent, RecognitionState> {
  final TextRecognitionService textRecognitionService;
  final ImageRecognitionService imageRecognitionService;

  RecognitionBloc(this.textRecognitionService, this.imageRecognitionService)
    : super(const RecognitionState()) {
    on<ImageSelected>((event, emit) {
      emit(state.copyWith(image: event.image, result: []));
    });

    on<RecognitionTypeSelected>((event, emit) async {
      emit(state.copyWith(loading: true, type: event.type));

      List<Map<String, dynamic>> result = [];
      if (event.type == RecognitionType.text) {
        String recognizedText = await textRecognitionService.recognizeText(
          state.image!,
        );
        result = await Utils.matchMedicines(recognizedText);
      } else if (event.type == RecognitionType.image) {
        String recognizedImageResult = await imageRecognitionService
            .recognizeImage(state.image!);
        result = await Utils.matchMedicines(recognizedImageResult);
      }
      emit(state.copyWith(loading: false, result: result));
    });

    on<ImageCleared>((event, emit) {
      emit(RecognitionState(history: state.history));
    });

    on<AddToHistory>((event, emit) {
      if (state.image != null && state.result.isNotEmpty) {
        final history = RecognitionHistory(
          id: const Uuid().v4(),
          image: state.image!,
          type: state.type!,
          result: state.result,
          timestamp: DateTime.now(),
        );

        final updatedHistory = [history, ...state.history];
        emit(state.copyWith(history: updatedHistory));
      }
    });

    on<ClearHistory>((event, emit) {
      emit(state.copyWith(history: []));
    });

    on<DeleteHistoryItem>((event, emit) {
      final updatedHistory = state.history
          .where((item) => item.id != event.historyItemId)
          .toList();
      emit(state.copyWith(history: updatedHistory));
    });
  }
}
