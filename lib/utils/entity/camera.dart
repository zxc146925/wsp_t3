class CameraEntity {
  final String id;
  final String name;
  final String ip;
  final int port;
  final String protocol;
  final String web;
  final String urlPath;
  final String account;
  final String password;
  final int state;
  final int startDatetime;
  // final int endDatetime;

  CameraEntity({
    required this.id,
    required this.name,
    required this.ip,
    required this.port,
    required this.protocol,
    required this.web,
    required this.urlPath,
    required this.account,
    required this.password,
    required this.state,
    required this.startDatetime,
    // required this.endDatetime,
  });

  factory CameraEntity.fromJson(Map<String, dynamic> json) => CameraEntity(
        id: json["id"],
        name: json["name"],
        ip: json["ip"],
        port: json["port"],
        protocol: json["protocol"],
        web: json["web"],
        urlPath: json["urlPath"],
        account: json["account"],
        password: json["password"],
        state: json["state"],
        startDatetime: json["startDatetime"] ?? 0,
        // endDatetime: json["endDatetime"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "ip": ip,
        "port": port,
        "protocol": protocol,
        "web": web,
        "urlPath": urlPath,
        "account": account,
        "password": password,
        "state": state,
        "startDatetime": startDatetime,
        // "endDatetime": endDatetime,
      };
}
