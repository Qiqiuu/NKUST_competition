import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nkust/bloc/recognition/recognition_bloc.dart';
import 'package:nkust/bloc/recognition/recognition_event.dart';
import 'package:nkust/bloc/recognition/recognition_state.dart';
import 'package:nkust/pages/history_page.dart';
import 'package:nkust/pages/recognition_results_page.dart';
import 'package:nkust/services/image_picker_service.dart';
import 'package:nkust/utils/utils.dart';

class ImageUploadPage extends StatelessWidget {
  ImageUploadPage({super.key, required this.title});

  final String title;
  final ImagePickerService _pickerService = ImagePickerService();

  Future<void> _pickImage(BuildContext context, Future imagePickFunc) async {
    final image = await imagePickFunc;
    if (!context.mounted) return;
    if (image != null) {
      Utils.showSnackbar(context, '選擇圖片成功！', showFromTop: true);
      context.read<RecognitionBloc>().add(ImageSelected(image));
      if (context.mounted) {
        final bloc = context.read<RecognitionBloc>();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: bloc,
              child: const RecognitionResultsPage(),
            ),
          ),
        );
      }
    } else {
      Utils.showSnackbar(
        context,
        '未選擇圖片！',
        boolProperty: false,
        showFromTop: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () {
              final bloc = context.read<RecognitionBloc>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: bloc,
                    child: const HistoryPage(),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Stack(
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

          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF6366F1).withValues(alpha: 0.2),
              ),
            ),
          ),

          BlocBuilder<RecognitionBloc, RecognitionState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: state.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                state.image!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              height: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 64,
                                  color: Colors.white30,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _pickImage(
                          context,
                          _pickerService.pickImageFromGallery(),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF6366F1,
                          ), // Indigo 500
                          foregroundColor: Colors.white,
                          elevation: 10,
                          shadowColor: const Color(
                            0xFF6366F1,
                          ).withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.photo_library, size: 40),
                            const SizedBox(width: 12),
                            Text(
                              '從相簿選取圖片',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // SizedBox(
                    //   height: 56,
                    //   child: ElevatedButton(
                    //     onPressed: () => _pickImage(
                    //       context,
                    //       _pickerService.pickImageFromCamera(),
                    //     ),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: const Color(
                    //         0xFF6366F1,
                    //       ), // Indigo 500
                    //       foregroundColor: Colors.white,
                    //       elevation: 10,
                    //       shadowColor: const Color(
                    //         0xFF6366F1,
                    //       ).withValues(alpha: 0.5),
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(16),
                    //       ),
                    //     ),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         const Icon(Icons.camera_alt, size: 28),
                    //         const SizedBox(width: 12),
                    //         Text(
                    //           '從相機拍攝圖片',
                    //           style: GoogleFonts.poppins(
                    //             fontSize: 18,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // const Spacer(),
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
                              '此應用程式可能會出錯，如有問題請諮詢藥師或醫師',
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
              );
            },
          ),
        ],
      ),
    );
  }
}
