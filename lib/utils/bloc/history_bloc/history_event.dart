part of 'history_bloc.dart';

@immutable
sealed class HistoryEvent {}

// 初始簡約的歷史列表
class HistoryInitEvent extends HistoryEvent {
  final int size;
  final int skip;
  final String userId;
  HistoryInitEvent({required this.size, required this.skip, required this.userId});
}

// 加載更多
class HistoryLoadMoreEvent extends HistoryEvent {
  final int size;
  final int skip;
  final String userId;
  HistoryLoadMoreEvent({required this.size, required this.skip, required this.userId});
}
