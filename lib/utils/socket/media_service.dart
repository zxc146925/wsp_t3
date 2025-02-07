import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket _socket;

  // 單例模式
  SocketService._internal();
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  /// 初始化 Socket
  void init(String url) {
    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket']) // 僅使用 WebSocket
          .disableAutoConnect() // 初始化時不自動連接
          .build(),
    );

    // 註冊事件
    _registerDefaultHandlers();
  }

  /// 連接到伺服器
  void connect(String userId) {
    if (!_socket.connected) {
      _socket.connect();

      _socket.emitWithAck(
        'register',
        {'userId': userId},
        ack: (result) {
          print('註冊--$result');
        },
      );
      print('Connecting to socket...');
    } else {
      print('Socket already connected.');
    }
  }

  /// 斷開連接
  void disconnect() {
    if (_socket.connected) {
      _socket.disconnect();
      print('Socket disconnected.');
    } else {
      print('Socket is already disconnected.');
    }
  }

  /// 發送訊息
  void sendMessage(String event, dynamic message) {
    if (_socket.connected) {
      _socket.emit(event, message);
      print('Message sent: $message');
    } else {
      print('Cannot send message. Socket is not connected.');
    }
  }

  /// 註冊事件
  void on(String event, Function(dynamic) callback) {
    _socket.on(event, callback);
  }

  /// 移除事件
  void off(String event) {
    _socket.off(event);
  }

  /// 是否已連接
  bool get isConnected => _socket.connected;

  /// 註冊預設的處理程序
  void _registerDefaultHandlers() {
    _socket.onConnect((_) {
      print('Socket connected.');
    });

    _socket.onDisconnect((_) {
      print('Socket disconnected.');
    });

    _socket.onConnectError((error) {
      print('Socket connection error: $error');
    });

    _socket.onError((error) {
      print('Socket error: $error');
    });
  }

  /// 釋放資源
  void dispose() {
    _socket.dispose();
  }
}
