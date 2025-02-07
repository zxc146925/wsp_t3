class ConstructionDetailEntity {
  final String id;
  final String name;
  final String peopleName;
  final String phone;
  final String status;
  final String startTime;
  final String endTime;
  final String description;

  ConstructionDetailEntity({
    required this.id,
    required this.name,
    required this.peopleName,
    required this.phone,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.description,
  });

  factory ConstructionDetailEntity.fromJson(Map<String, dynamic> json) => ConstructionDetailEntity(
        id: json["id"],
        name: json["name"],
        peopleName: json["peopleName"],
        phone: json["phone"],
        status: json["status"],
        startTime: json["startTime"],
        endTime: json["endTime"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "peopleName": peopleName,
        "phone": phone,
        "status": status,
        "startTime": startTime,
        "endTime": endTime,
        "description": description,
      };
}
