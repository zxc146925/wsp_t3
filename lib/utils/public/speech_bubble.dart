import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/speech_to_text_bloc/speech_to_text_bloc.dart';

class SpeechBubble extends StatelessWidget {
  final VoidCallback onStop; // 停止按鈕的回調

  const SpeechBubble({super.key, required this.onStop});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '語音偵測中...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              BlocBuilder<SpeechToTextBloc, SpeechToTextState>(
                builder: (context, state) {
                  if (state is SpeechListening) {
                    return Text(
                      state.recognizedText.isEmpty ? '請說話...' : '偵測到：${state.recognizedText}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    );
                  } else if (state is SpeechError) {
                    return Text(
                      '錯誤：${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    );
                  }
                  return const Text(
                    '準備中...',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onStop,
                child: const Text('停止'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
