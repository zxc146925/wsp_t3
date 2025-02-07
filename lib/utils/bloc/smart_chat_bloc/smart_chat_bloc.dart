import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';
import 'package:wsp_t3/utils/public/public_data.dart';
import '../../api/chatroom_service.dart';
import '../../api/message_service.dart';
import '../../entity/message.dart';
part 'smart_chat_event.dart';
part 'smart_chat_state.dart';

class SmartChatBloc extends Bloc<SmartChatEvent, SmartChatState> {
  factory SmartChatBloc() {
    var state = SmartChatInitialState();
    state.historySmartChatMap = {};
    state.chatRoomId = BehaviorSubject.seeded('');
    state.smartChatGPTStream = BehaviorSubject.seeded(null);
    state.smartChatStream = BehaviorSubject.seeded(null);
    state.isFirstStream = BehaviorSubject.seeded(false);
    return SmartChatBloc._(state);
  }

  // ignore: use_super_parameters
  SmartChatBloc._(state) : super(state) {
    on<SmartChatSendMessage>(_onSmartChatSendMessage);
    on<SmartChatReponseMessage>(_onSmartChatReponseMessage);
    on<SmartChatVoiceMessage>(_onSmartChatVoiceMessage);
    on<SmartChatNewRoomMessage>(_onSmartChatNewRoomMessage);
    on<SmartChatOpenHistoryContentEvent>(_onSmartChatOpenHistoryContentEvent);
    // on<SmartChatOpenHistoryContentLoadMoreEvent>(_onSmartChatOpenHistoryContentLoadMoreEvent);
  }

  @override
  void onEvent(SmartChatEvent event) {
    print('SmartChatEvent onEvent-------${event.runtimeType}');
    super.onEvent(event);
  }

  @override
  void onChange(Change<SmartChatState> change) {
    print('SmartChatState onChange------${change.currentState.runtimeType}---${change.nextState.runtimeType}');
    super.onChange(change);
  }

  SmartChatState emitState(SmartChatState newState, SmartChatState oldState) {
    newState.historySmartChatMap = oldState.historySmartChatMap;
    newState.smartChatGPTStream = oldState.smartChatGPTStream;
    newState.smartChatStream = oldState.smartChatStream;
    newState.chatRoomId = oldState.chatRoomId;
    newState.isFirstStream = oldState.isFirstStream;
    return newState;
  }

  // 使用者輸入
  Future<void> _onSmartChatSendMessage(SmartChatSendMessage event, Emitter<SmartChatState> emit) async {
    try {
      // 自己輸入載入中
      print('---------SmartChatSendMessage---${event.message}---${event.userId}-------${state.chatRoomId.value}');
      emit(emitState(SmartChatIsMeLoadingState(), state));
      state.isFirstStream.add(false);

      // 先判斷是否創建聊天室
      if (state.chatRoomId.value.isEmpty) {
        final chatRoomId = await ChatroomService.createChatRoom(event.userId);
        // 取得chatRoomId，存起來
        print('取得創建的聊天室----${chatRoomId.toString()}');
        state.chatRoomId.add(chatRoomId['id']);
        state.isFirstStream.add(true);
      }

      // Call API取得文字Entity
      final message = await MessageService.sendMessageRequest(
        userId: event.userId,
        text: event.message,
        chatroomId: state.chatRoomId.value,
        isFirst: state.isFirstStream.value,
      );
      MessageEntity messageEntity = MessageEntity.fromJson(message);

      //檢查是否已有資料
      if (state.smartChatStream.valueOrNull != null) {
        print('目前有資料');
        // 更新歷史對話
        MessageEntity chatMessage = state.smartChatStream.value!;
        MessageEntity? gptMessage = state.smartChatGPTStream.valueOrNull;

        state.historySmartChatMap.update(chatMessage.id, (value) => chatMessage, ifAbsent: () => chatMessage);
        if (gptMessage != null) {
          state.historySmartChatMap.update(gptMessage.id, (value) => gptMessage, ifAbsent: () => gptMessage);
        }
        // 更新當前輸入
        state.smartChatStream.add(messageEntity);
      } else {
        // 如果是第一筆資料
        print('目前是第一筆');
        state.smartChatStream.add(messageEntity);
      }

      // 變更狀態為回應載入中
      emit(emitState(SmartChatResponseLoadingState(), state));
    } catch (error) {
      print('發生錯誤: $error');
      // 保留，之後有錯可以避免
      // emit(emitState(SmartChatErrorState(error.toString()), state));
    }
  }

  // GPT 回傳的內容
  Future<void> _onSmartChatReponseMessage(SmartChatReponseMessage event, Emitter<SmartChatState> emit) async {
    print('SmartChatReponseMessage---------------------${event.message.toJson()}');
    state.smartChatGPTStream.add(event.message);
    emit(emitState(SmartChatMessageState(), state));
    // 模擬Socket接收到Chat AI回覆結果
    // await Future.delayed(const Duration(seconds: 2), () {

    // });
  }

  // 發送語音訊息
  Future<void> _onSmartChatVoiceMessage(SmartChatVoiceMessage event, Emitter<SmartChatState> emit) async {}

  // 點開歷史聊天內容(初始)
  Future<void> _onSmartChatOpenHistoryContentEvent(SmartChatOpenHistoryContentEvent event, Emitter<SmartChatState> emit) async {
    emit(emitState(SmartChatLoadingState(), state));
    try {
      state.chatRoomId.add(event.chatroomId);
      state.smartChatGPTStream = BehaviorSubject.seeded(null);
      state.smartChatStream = BehaviorSubject.seeded(null);
      state.historySmartChatMap.clear();
      final response = await MessageService.getMessageList(skip: event.skip, size: event.size, chatroomId: event.chatroomId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        List<dynamic> historyList = jsonDecode(response.body);

        for (var message in historyList) {
          if (message['type'] == 'text') {
            MessageEntity responseData = MessageEntity.fromJson(message);
            state.historySmartChatMap.update(
              responseData.id,
              (value) => responseData,
              ifAbsent: () => responseData,
            );
          } else {
            print('目前是圖片/影片');
            String content = message['content'];
            if (PublicData.hasErrorMessage(content)) {
              MessageEntity responseData = MessageEntity(
                id: message['id'],
                content: message['content'],
                chatroomId: message['chatroomId'],
                senderId: message['senderId'],
                createDatetime: message['createDatetime'],
                type: 'text',
              );

              state.historySmartChatMap.update(
                responseData.id,
                (value) => responseData,
                ifAbsent: () => responseData,
              );
            } else {
              final payloadString = message['payload'];
              print('目前是payloadString---$payloadString');
              final payloadObject = jsonDecode(payloadString)['context']['result'][0]['incident'];

              // print('payloadObject---${payloadObject['videoUrl']}');
              List<String> parts = PublicData.splitByFirstSlash(payloadObject['videoUrl']);

              MessageEntity responseData = MessageEntity(
                id: message['id'] ?? '',
                createDatetime: message['createDatetime'] ?? 0,
                content: message['content'] ?? '',
                type: message['type'] ?? '',
                // data: message['data'] ?? '',
                chatroomId: message['chatroomId'] ?? '',
                senderId: message['senderId'] ?? '',
                imageUrl: payloadObject['imageUrl'] ?? '',
                videoUrl: 'records/${parts[0]}-ai/${parts[1]}' ?? '',
                fileUrl: payloadObject['fileUrl'] ?? '',
              );
              state.historySmartChatMap.update(
                responseData.id,
                (value) => responseData,
                ifAbsent: () => responseData,
              );
            }
          }
        }
        emit(emitState(SmartChatShowingState(), state));
      }
    } catch (e) {
      print('SmartChatOpenHistoryContentEvent error--$e');
    }
  }

  // 點開歷史聊天內容(上滑)
  // Future<void> _onSmartChatOpenHistoryContentLoadMoreEvent(SmartChatOpenHistoryContentLoadMoreEvent event, Emitter<SmartChatState> emit) async {
  //   emit(emitState(SmartChatLoadMoreState(), state));
  //   try {
  //     final response = await MessageService.getMessageList(skip: event.skip, size: event.size, chatroomId: state.chatRoomId.value);
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       Map<String, MessageEntity> newMap = {};
  //       List<dynamic> historyList = jsonDecode(response.body);

  //       for (var message in historyList) {
  //         if (message['type'] == 'text') {
  //           MessageEntity responseData = MessageEntity.fromJson(message);
  //           newMap.update(
  //             responseData.id,
  //             (value) => responseData,
  //             ifAbsent: () => responseData,
  //           );
  //         } else {
  //           print('目前是圖片/影片');
  //           String content = message['content'];
  //           if (PublicData.hasErrorMessage(content)) {
  //             MessageEntity responseData = MessageEntity(
  //               id: message['id'],
  //               content: message['content'],
  //               chatroomId: message['chatroomId'],
  //               senderId: message['senderId'],
  //               createDatetime: message['createDatetime'],
  //               type: 'text',
  //             );

  //             newMap.update(
  //               responseData.id,
  //               (value) => responseData,
  //               ifAbsent: () => responseData,
  //             );
  //           } else {
  //             final payloadString = message['payload'];
  //             print('目前是payloadString---$payloadString');
  //             final payloadObject = jsonDecode(payloadString)['context']['result'][0]['incident'];

  //             // print('payloadObject---${payloadObject['videoUrl']}');
  //             List<String> parts = PublicData.splitByFirstSlash(payloadObject['videoUrl']);

  //             MessageEntity responseData = MessageEntity(
  //               id: message['id'] ?? '',
  //               createDatetime: message['createDatetime'] ?? 0,
  //               content: message['content'] ?? '',
  //               type: message['type'] ?? '',
  //               // data: message['data'] ?? '',
  //               chatroomId: message['chatroomId'] ?? '',
  //               senderId: message['senderId'] ?? '',
  //               imageUrl: payloadObject['imageUrl'] ?? '',
  //               videoUrl: 'records/${parts[0]}-ai/${parts[1]}' ?? '',
  //               fileUrl: payloadObject['fileUrl'] ?? '',
  //             );
  //             newMap.update(
  //               responseData.id,
  //               (value) => responseData,
  //               ifAbsent: () => responseData,
  //             );
  //           }
  //         }
  //       }
  //       newMap.addAll(state.historySmartChatMap);
  //       state.historySmartChatMap = newMap;

  //       if (historyList.length < event.size) {
  //         emit(emitState(SmartChatLoadMoreMaxState(), state));
  //       } else {
  //         emit(emitState(SmartChatShowingState(), state));
  //       }
  //     }
  //   } catch (e) {
  //     print('SmartChatOpenHistoryContentEvent error--$e');
  //   }
  // }

  // 開啟新的聊天室
  Future<void> _onSmartChatNewRoomMessage(SmartChatNewRoomMessage event, Emitter<SmartChatState> emit) async {
    state.smartChatGPTStream = BehaviorSubject();
    state.smartChatStream = BehaviorSubject();
    state.historySmartChatMap.clear();
    state.chatRoomId = BehaviorSubject();
    emit(emitState(SmartChatInitialState(), state));
  }
}
