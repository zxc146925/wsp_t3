import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

part 'speech_to_text_event.dart';
part 'speech_to_text_state.dart';

class SpeechToTextBloc extends Bloc<SpeechToTextEvent, SpeechToTextState> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  SpeechToTextBloc._(super.state) {
    on<InitializeSpeech>(_onInitializeSpeech);
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<CancelListening>(_onCancelListening);
    on<ListeningResultEvent>(_onListeningResultEvent);
  }

  SpeechToTextBloc() : this._(SpeechInitial());

  @override
  void onEvent(SpeechToTextEvent event) {
    // print('SpeechToTextEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<SpeechToTextState> change) {
    // print('SpeechToTextState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  /// 初始化語音識別
  Future<void> _onInitializeSpeech(InitializeSpeech event, Emitter<SpeechToTextState> emit) async {
    try {
      if (_speech.isAvailable) {
        emit(SpeechStopped('')); // 已初始化
      } else {
        bool available = await _speech.initialize();
        if (available) {
          emit(SpeechStopped('')); // 初始狀態
        } else {
          emit(SpeechError("Speech recognition not available"));
        }
      }
    } catch (e) {
      emit(SpeechError("Error initializing speech recognition: ${e.toString()}"));
    }
  }

  /// 開始聆聽
  Future<void> _onStartListening(StartListening event, Emitter<SpeechToTextState> emit) async {
    try {
      _speech.listen(onResult: (result) {
        add(ListeningResultEvent(result.recognizedWords));
      });
      emit(SpeechListening('')); // 開始聆聽，初始為空
    } catch (e) {
      emit(SpeechError("Error starting listening: ${e.toString()}"));
    }
  }

  /// 更新語音識別結果
  void _onListeningResultEvent(ListeningResultEvent event, Emitter<SpeechToTextState> emit) {
    emit(SpeechListening(event.recognizedText)); // 更新識別到的文字
  }

  /// 停止聆聽
  void _onStopListening(StopListening event, Emitter<SpeechToTextState> emit) {
    try {
      if (_speech.isListening) {
        _speech.stop();
        if (state is SpeechListening) {
          final currentText = (state as SpeechListening).recognizedText;
          emit(SpeechStopped(currentText)); // 停止後保留最後的文字
        } else {
          emit(SpeechStopped('')); // 當前非聆聽狀態，返回空
        }
      }
    } catch (e) {
      emit(SpeechError("Error stopping listening: ${e.toString()}"));
    }
  }

  /// 取消聆聽
  void _onCancelListening(CancelListening event, Emitter<SpeechToTextState> emit) {
    try {
      _speech.cancel();
      emit(SpeechStopped('')); // 返回初始狀態
    } catch (e) {
      emit(SpeechError("Error cancelling listening: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() {
    _speech.stop(); // 清理資源
    return super.close();
  }
}
