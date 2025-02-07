part of 'notification_bloc.dart';

@immutable
sealed class NotificationEvent {}

// 初始化
class NotificationInitEvent extends NotificationEvent {
  final int skip;
  final int size;
  final String userId;

  NotificationInitEvent({required this.skip, required this.size, required this.userId});
}
// 加載更多
class NotificationLoadMoreEvent extends NotificationEvent {
  final int skip;
  final int size;
  final String userId;
  NotificationLoadMoreEvent({required this.skip, required this.size, required this.userId});
}

// 更新推播為已讀
class NotificationUpdateReadEvent extends NotificationEvent {
  final String notificationId;
  final String userId;
  NotificationUpdateReadEvent({required this.notificationId, required this.userId});
}


// 推播添加
class NotificationAddEvent extends NotificationEvent {
  final NotificationEntity notificationEntity;

  NotificationAddEvent(this.notificationEntity);
}