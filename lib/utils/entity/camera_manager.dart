class CameraManagerEntity {
  final String id;
  final String cameraName;
  final String locationName;
  final String ip;
  final int port;
  final String protocol;
  final String web;
  final String urlPath;
  final int createDatetime;
  final int state;
  final String account;
  final String password;

  CameraManagerEntity({
    required this.id,
    required this.cameraName,
    required this.locationName,
    required this.ip,
    required this.port,
    required this.protocol,
    required this.web,
    required this.urlPath,
    required this.createDatetime,
    required this.state,
    required this.account,
    required this.password,
  });

  factory CameraManagerEntity.fromJson(Map<String, dynamic> json) => CameraManagerEntity(
        id: json["id"],
        cameraName: json["cameraName"] ?? '',
        locationName: json["locationName"] ?? '',
        ip: json["ip"] ?? '',
        port: json["port"] ?? 0,
        protocol: json["protocol"] ?? '',
        web: json["web"] ?? '',
        urlPath: json["urlPath"] ?? '',
        createDatetime: json["createDatetime"] ?? 0,
        state: json["state"] ?? 0,
        account: json["account"] ?? '',
        password: json["password"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "cameraName": cameraName,
        "locationName": locationName,
        "ip": ip,
        "port": port,
        "protocol": protocol,
        "web": web,
        "urlPath": urlPath,
        "createDatetime": createDatetime,
        "state": state,
        "account": account,
        "password": password,
      };
}
