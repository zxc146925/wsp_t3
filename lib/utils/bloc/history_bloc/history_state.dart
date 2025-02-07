part of 'history_bloc.dart';

@immutable
sealed class HistoryState {
  late Map<String, HistoryEntity> historyMap;
}

// 初始狀態
final class HistoryInitialState extends HistoryState {}

//讀取中
class HistoryLoadingState extends HistoryState {}

// 下滑中
class HistoryLoadMoreState extends HistoryState {}

// 下滑最多
class HistoryLoadMoreMaxState extends HistoryState {}

// 讀取失敗
class HistoryReadFailState extends HistoryState {}

//顯示中
class HistoryShowingState extends HistoryState {}
