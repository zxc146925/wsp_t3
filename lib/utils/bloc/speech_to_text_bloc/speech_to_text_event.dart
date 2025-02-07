part of 'speech_to_text_bloc.dart';

@immutable
sealed class SpeechToTextEvent {}

class InitializeSpeech extends SpeechToTextEvent {}

class StartListening extends SpeechToTextEvent {}

class StopListening extends SpeechToTextEvent {}

class CancelListening extends SpeechToTextEvent {}

class ListeningResultEvent extends SpeechToTextEvent {
  final String recognizedText;

  ListeningResultEvent(this.recognizedText);
}