import 'dart:io'; // 用來處理檔案
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nkust/bloc/recognition/recognition_bloc.dart';
import 'package:nkust/pages/image_upload_page.dart';
import 'package:nkust/services/image_recognition_service.dart';
import 'package:nkust/services/text_recognition_service.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RecognitionBloc(TextRecognitionService(), ImageRecognitionService()),
      child: MaterialApp(
        home: ImageUploadPage(title: '基於多模態融合之泌尿科外觀相似藥物智慧辨識與與用藥安全導引系統'),
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
      ),
    );
  }
}