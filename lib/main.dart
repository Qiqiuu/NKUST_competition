import 'dart:io'; // 用來處理檔案
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 選圖套件
// import 'package:http/http.dart' as http; // API套件
// import 'dart:convert'; // 用來解析 JSON

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '圖片辨識 App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ImageRecognitionPage(title: 'AI 圖片辨識'), 
    );
  }
}

class ImageRecognitionPage extends StatefulWidget {
  const ImageRecognitionPage({super.key, required this.title});
  final String title;

  @override
  State<ImageRecognitionPage> createState() => _ImageRecognitionPageState();
}

class _ImageRecognitionPageState extends State<ImageRecognitionPage> {
  // 變數：儲存選到的圖片
  File? _selectedImage;
  // 變數：顯示辨識結果文字
  String _resultText = "尚未選擇圖片";
  // 變數：是否正在辨識中 (用來顯示轉圈圈)
  bool _isAnalyzing = false;

  final ImagePicker _picker = ImagePicker();

  // 功能 1: 選擇圖片 (來源可以是相簿 Gallery 或 相機 Camera)
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _resultText = "圖片已準備好，請點擊辨識";
      });
    }
  }

  // 功能 2: 上傳圖片並串接 API
  Future<void> _uploadAndRecognize() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _resultText = "正在分析中...";
    });

    // --- 實作選擇區 ---
    
    // 【模式 A：模擬 API (測試 UI 用)】
    // 假裝等 2 秒然後回傳結果
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isAnalyzing = false;
      _resultText = "辨識成功！\n結果：這是一隻可愛的貓 (98%)";
    });

    // 【模式 B：真實 API 串接 (解開下方註解即可使用)】
    /*
    try {
      // 1. 設定你的 API 網址
      var uri = Uri.parse("https://your-api-domain.com/predict");

      // 2. 建立 Multipart Request (類似表單上傳)
      var request = http.MultipartRequest('POST', uri);

      // 3. 加入圖片檔案 (假設後端接收欄位名稱是 'image')
      request.files.add(await http.MultipartFile.fromPath(
        'image', 
        _selectedImage!.path
      ));

      // 4. 發送請求
      var response = await request.send();

      // 5. 讀取回應
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResult = json.decode(responseData);
        
        setState(() {
          // 假設回傳格式是 { "label": "Cat", "confidence": 0.98 }
          _resultText = "辨識結果：${jsonResult['label']}";
        });
      } else {
        setState(() {
          _resultText = "上傳失敗，錯誤代碼：${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        _resultText = "發生錯誤：$e";
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView( // 防止內容太長超出螢幕
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 30),
              
              // 1. 圖片顯示區
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: _selectedImage == null
                    ? const Icon(Icons.image, size: 100, color: Colors.grey)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
              
              const SizedBox(height: 20),

              // 2. 按鈕區 (拍照 / 選圖)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("拍照"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("選圖"),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 3. 辨識按鈕 (如果正在分析就顯示轉圈圈)
              _isAnalyzing
                  ? const CircularProgressIndicator()
                  : FilledButton.icon(
                      onPressed: _selectedImage == null ? null : _uploadAndRecognize,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      ),
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text("開始辨識", style: TextStyle(fontSize: 18)),
                    ),

              const SizedBox(height: 30),

              // 4. 結果顯示區
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: double.infinity,
                color: Colors.teal.withOpacity(0.1),
                child: Column(
                  children: [
                    Text(
                      "分析結果",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _resultText,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}