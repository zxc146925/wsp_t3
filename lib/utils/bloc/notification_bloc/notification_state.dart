part of 'notification_bloc.dart';

@immutable
sealed class NotificationState {
  bool isLoadingMore = false;
  late Map<String, NotificationEntity> notificationMap;
}

// 初始狀態
final class NotificationInitialState extends NotificationState {}

//讀取中(整個轉圈)
class NotificationLoadingState extends NotificationState {}

// 讀取更多(UI轉圈)
class NotificationLoadingMoreState extends NotificationState {}

// 讀取已達上限
class NotificationReadMoreMaxState extends NotificationState {}

//顯示中
class NotificationShowingState extends NotificationState {}

//讀取失敗
class NotificationErrorState extends NotificationState {}


