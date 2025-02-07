class EngineeringEntity {
  final String id;
  final String phone;
  final String inspector;
  final String contractor;
  final String description;
  final String name;
  final String engineer;
  final int cameraCount;
  final int startDatetime;
  final int endDatetime;
  final int createDatetime;

  const EngineeringEntity({
    required this.id,
    required this.phone,
    required this.inspector,
    required this.contractor,
    required this.description,
    required this.name,
    required this.engineer,
    required this.cameraCount,
    required this.startDatetime,
    required this.endDatetime,
    required this.createDatetime,
  });

  /// Creates an EngineeringEntity from a JSON map
  factory EngineeringEntity.fromJson(Map<String, dynamic> json) {
    return EngineeringEntity(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      inspector: json['inspector'] ?? '',
      contractor: json['contractor'] ?? '',
      description: json['description'] ?? '',
      name: json['name'] ?? '',
      engineer: json['engineer'] ?? '',
      cameraCount: json['cameraCount'] ?? 0,
      startDatetime: json['startDatetime'] ?? 0,
      endDatetime: json['endDatetime'] ?? 0,
      createDatetime: json['createDatetime'] ?? 0,
    );
  }

  /// Converts this EngineeringEntity to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'inspector': inspector,
      'contractor': contractor,
      'description': description,
      'name': name,
      'engineer': engineer,
      'cameraCount': cameraCount,
      'startDatetime': startDatetime,
      'endDatetime': endDatetime,
      'createDatetime': createDatetime,
    };
  }
}