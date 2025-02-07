// 給影像管理的實時影像使用
class CamerListEntity {
  final String id;
  final int recordCount;
  final int port;
  final int incidentCount;
  final String protocol;
  final String locationId;
  final int state;
  final String web;
  final String urlPath;
  final String password;
  final String ip;
  final String name;
  final String account;

  CamerListEntity({
    required this.recordCount,
    required this.port,
    required this.incidentCount,
    required this.protocol,
    required this.locationId,
    required this.state,
    required this.web,
    required this.urlPath,
    required this.password,
    required this.ip,
    required this.id,
    required this.name,
    required this.account,
  });

  /// Creates a CamerListEntity from a JSON map
  factory CamerListEntity.fromJson(Map<String, dynamic> json) {
    return CamerListEntity(
      recordCount: json['recordCount'],
      port: json['port'],
      incidentCount: json['incidentCount'],
      protocol: json['protocol'],
      locationId: json['locationId'],
      state: json['state'],
      web: json['web'],
      urlPath: json['urlPath'],
      password: json['password'],
      ip: json['ip'],
      id: json['id'],
      name: json['name'],
      account: json['account'],
    );
  }

  /// Converts this CamerListEntity to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'recordCount': recordCount,
      'port': port,
      'incidentCount': incidentCount,
      'protocol': protocol,
      'locationId': locationId,
      'state': state,
      'web': web,
      'urlPath': urlPath,
      'password': password,
      'ip': ip,
      'id': id,
      'name': name,
      'account': account,
    };
  }
}
