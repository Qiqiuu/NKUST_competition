import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nkust/bloc/recognition/recognition_bloc.dart';
import 'package:nkust/bloc/recognition/recognition_event.dart';
import 'package:nkust/bloc/recognition/recognition_state.dart';
import 'package:nkust/pages/history_detail_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('歷史紀錄'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final bloc = context.read<RecognitionBloc>();
              showDialog(
                context: context,
                builder: (context) => BlocProvider.value(
                  value: bloc,
                  child: AlertDialog(
                    title: const Text('清除歷史紀錄'),
                    content: const Text('您確定要清除歷史紀錄嗎？此操作無法復原。'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          bloc.add(ClearHistory());
                          Navigator.pop(context);
                        },
                        child: const Text('確認'),
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.delete_outlined),
          ),
        ],
      ),
      body: BlocBuilder<RecognitionBloc, RecognitionState>(
        builder: (context, state) {
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
              if (state.history.isEmpty)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '尚無歷史紀錄',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.history.length,
                  itemBuilder: (context, index) {
                    final item = state.history[index];
                    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

                    return Card(
                      color: Colors.white.withValues(alpha: 0.1),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HistoryDetailPage(history: item),
                            ),
                          );
                        },
                        onLongPress: () {
                          final bloc = context.read<RecognitionBloc>();
                          showDialog(
                            context: context,
                            builder: (context) => BlocProvider.value(
                              value: bloc,
                              child: AlertDialog(
                                title: const Text(
                                  '刪除該筆歷史記錄',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: const Text(
                                  '確定要刪除這筆歷史記錄嗎？此操作無法復原',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      bloc.add(DeleteHistoryItem(item.id));
                                      Navigator.pop(context);
                                    },
                                    child: const Text('確定'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        leading: ClipRect(
                          child: Image.file(
                            item.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[700],
                                ),
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          ),
                        ),
                        title: Text(
                          item.type == RecognitionType.text ? '藥盒辨識' : '藥丸辨識',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              item.result.isNotEmpty
                                  ? item.result
                                        .map(
                                          (med) =>
                                              '藥物學名: ${med['scientific_name']}\n'
                                              '適應症: ${(med['uses'] as List).join(', ')}\n',
                                          // '副作用: ${(med['sideEffects'] as List).join(', ')}\n'
                                          // '禁忌: ${(med['contraindications'] as List).join(', ')}\n',
                                        )
                                        .join('\n')
                                  : '尚無匹配的藥物',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              dateFormat.format(item.timestamp),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
