part of 'smart_chat_bloc.dart';

@immutable
sealed class SmartChatState {
  Map<String, MessageEntity> historySmartChatMap = {}; // 歷史訊息
  BehaviorSubject<String> chatRoomId = BehaviorSubject<String>.seeded('');
  BehaviorSubject<MessageEntity?> smartChatStream = BehaviorSubject<MessageEntity?>(); // 當前訊息
  BehaviorSubject<MessageEntity?> smartChatGPTStream = BehaviorSubject<MessageEntity?>(); // 當前GPT訊息
  BehaviorSubject<bool> isFirstStream = BehaviorSubject<bool>();
  SmartChatState();
}

final class SmartChatInitialState extends SmartChatState {} // 初始狀態

final class SmartChatIsMeLoadingState extends SmartChatState {} // 自己輸入載入中的狀態

// 讀取中
final class SmartChatLoadingState extends SmartChatState {}

// 顯示中
final class SmartChatShowingState extends SmartChatState {}

// 上滑中
final class SmartChatLoadMoreState extends SmartChatState {}

// 上滑顯示最多
final class SmartChatLoadMoreMaxState extends SmartChatState {}

// GPT 回傳的內容
final class SmartChatResponseLoadingState extends SmartChatState {} // 載入中的狀態

final class SmartChatMessageState extends SmartChatState {} // 訊息狀態

final class SmartChatLoadingFailureState extends SmartChatState {} // 讀取失敗的狀態