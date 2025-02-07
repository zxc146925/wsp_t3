part of 'speech_to_text_bloc.dart';

@immutable
sealed class SpeechToTextState {}

class SpeechInitial extends SpeechToTextState {}

class SpeechListening extends SpeechToTextState {
  final String recognizedText;

  SpeechListening(this.recognizedText);
}

class SpeechStopped extends SpeechToTextState {
  final String recognizedText;

  SpeechStopped(this.recognizedText);
}

class SpeechError extends SpeechToTextState {
  final String message;

  SpeechError(this.message);
}
