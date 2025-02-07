part of 'smart_chat_bloc.dart';

@immutable
sealed class SmartChatEvent {}

// 發送文字訊息
class SmartChatSendMessage extends SmartChatEvent {
  final String userId;
  final String message;
  SmartChatSendMessage({required this.userId, required this.message});
}

// GPT 回傳的內容
class SmartChatReponseMessage extends SmartChatEvent {
  final MessageEntity message;
  SmartChatReponseMessage(this.message);
}

// 點選詢問歷史Item
class SmartChatOpenHistoryContentEvent extends SmartChatEvent {
  final int skip;
  final int size;
  final String chatroomId;
  SmartChatOpenHistoryContentEvent({required this.skip, required this.size, required this.chatroomId});
}

// 點選詢問歷史Item上滑
// class SmartChatOpenHistoryContentLoadMoreEvent extends SmartChatEvent {
//   final int skip;
//   final int size;
//   SmartChatOpenHistoryContentLoadMoreEvent({required this.skip, required this.size});
// }


// 發送語音訊息
class SmartChatVoiceMessage extends SmartChatEvent {}

// 開啟新的聊天室
class SmartChatNewRoomMessage extends SmartChatEvent {}
