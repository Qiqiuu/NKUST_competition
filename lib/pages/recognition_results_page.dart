import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nkust/bloc/recognition/recognition_bloc.dart';
import 'package:nkust/bloc/recognition/recognition_event.dart';
import 'package:nkust/bloc/recognition/recognition_state.dart';

class RecognitionResultsPage extends StatefulWidget {
  const RecognitionResultsPage({super.key});

  @override
  State<RecognitionResultsPage> createState() => _RecognitionResultsPageState();
}

class _RecognitionResultsPageState extends State<RecognitionResultsPage> {
  bool _historyAdded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('辨識結果'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<RecognitionBloc>().add(ImageCleared());
            _historyAdded = false;
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocBuilder<RecognitionBloc, RecognitionState>(
        builder: (context, state) {
          if (state.result.isNotEmpty && !_historyAdded) {
            _historyAdded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<RecognitionBloc>().add(AddToHistory());
            });
          }
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1E1B4B),
                      Color(0xFF312E81),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (state.image != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                state.image!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(height: 24),
                          Text(
                            '選擇辨識類型',
                            style: GoogleFonts.poppins(
                              fontSize: 35,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              SizedBox(
                                height: 56,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state.loading
                                      ? null
                                      : () {
                                          context.read<RecognitionBloc>().add(
                                            RecognitionTypeSelected(
                                              RecognitionType.text,
                                            ),
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6366F1),
                                    foregroundColor: Colors.white,
                                    elevation: 10,
                                    shadowColor: const Color(
                                      0xFF6366F1,
                                    ).withValues(alpha: 0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child:
                                      state.loading &&
                                          state.type == RecognitionType.text
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          '藥盒辨識',
                                          style: GoogleFonts.poppins(
                                            fontSize: 35,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 56,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state.loading
                                      ? null
                                      : () {
                                          context.read<RecognitionBloc>().add(
                                            RecognitionTypeSelected(
                                              RecognitionType.image,
                                            ),
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6366F1),
                                    foregroundColor: Colors.white,
                                    elevation: 10,
                                    shadowColor: const Color(
                                      0xFF6366F1,
                                    ).withValues(alpha: 0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child:
                                      state.loading &&
                                          state.type == RecognitionType.image
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          '藥丸辨識',
                                          style: GoogleFonts.poppins(
                                            fontSize: 35,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 60),
                              Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange[300],
                                      size: 40,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '請盡量維持圖片清晰度，並保持影像方向正確，避免傾斜或歪斜',
                                        style: GoogleFonts.poppins(
                                          fontSize: 28,
                                          color: Colors.orange[200],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (state.result.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    state.result
                                        .map(
                                          (med) =>
                                              '藥物學名: ${med['scientific_name']}\n'
                                              '適應症: ${(med['uses'] as List).join(', ')}\n'
                                              '副作用: ${(med['sideEffects'] as List).join(', ')}\n'
                                              '禁忌: ${(med['contraindications'] as List).join(', ')}\n',
                                        )
                                        .join('\n'),
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 20,
                                      color: Colors.white,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// !TODO: 新增藥物作用和副作用和衝突藥物、影像辨識模型訓練
