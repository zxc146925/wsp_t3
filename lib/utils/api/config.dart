class Config {
  static late bool isLocal;
  static late String apiUrl;
  static late String mediaSocketUrl;
  static late String apiSocketServiceUrl;

  static late String realTimeVideoIP;
  static late String recordsVideoIP;

  Config({required bool isLocalItem}) {
    switch (isLocalItem) {
      case true:
        {
          // 77內
          isLocal = isLocalItem;
          mediaSocketUrl = 'https://mycena.com.tw:4000';
          apiUrl = 'mycena.com.tw:4000';
          apiSocketServiceUrl = 'wss://mycena.com.tw:8012';
          realTimeVideoIP = 'https://mycena.com.tw:8900';
          recordsVideoIP = 'https://mycena.com.tw:8000';
          break;
        }
      case false:
        {
          // 77外
          isLocal = isLocalItem;
          mediaSocketUrl = 'http://192.168.1.77:4000';
          apiUrl = '192.168.1.77:4000';
          apiSocketServiceUrl = 'ws://192.168.1.77:8012';
          realTimeVideoIP = 'http://192.168.1.77:8000';
          recordsVideoIP = 'http://mycena.com.tw:8000';
          break;
        }
    }
  }
}

var headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
};

//local
//  isLocal = isLocalItem;
//           mediaSocketUrl = 'http://192.168.1.69:3000';
//           apiUrl = '192.168.1.69:3000';
//           apiSocketServiceUrl = 'ws://192.168.1.77:8012';
//           videoIP = 'http://192.168.1.77:8000';