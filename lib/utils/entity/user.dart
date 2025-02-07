class UserEntity {
  final String id;
  final String name;
  final String mail;
  final String phone;
  final int permission;
  final int identity;
  final int createDatetime;

  UserEntity({
    required this.id,
    required this.name,
    required this.mail,
    required this.phone,
    required this.permission,
    required this.identity,
    required this.createDatetime,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
        id: json["id"],
        name: json["name"],
        mail: json["mail"],
        phone: json["phone"],
        permission: json["permission"] ?? 0,
        identity: json["identity"] ?? 0,
        createDatetime: json["createDatetime"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "mail": mail,
        "phone": phone,
        "permission": permission,
        "identity": identity,
        "createDatetime": createDatetime,
      };
}
