class LocationEntity {
  String? id;
  String? phone;
  String? manager;
  String? description;
  String? name;
  String? engineeringId;
  int? state;
  int? endDatetime;
  int? startDatetime;

  LocationEntity({
    this.id,
    this.phone,
    this.manager,
    this.description,
    this.name,
    this.engineeringId,
    this.state,
    this.endDatetime,
    this.startDatetime,
  });

  /// Creates a LocationEntity from a JSON map
  factory LocationEntity.fromJson(Map<String, dynamic> json) {
    return LocationEntity(
      id: json['id'] ?? '',
      phone: json['phone'] ?? '',
      manager: json['manager'] ?? '',
      description: json['description'] ?? '',
      name: json['name'] ?? '',
      engineeringId: json['engineeringId'] ?? '',
      state: json['state'] ?? 0,
      endDatetime: json['endDatetime'] ?? 0,
      startDatetime: json['startDatetime'] ?? 0,
    );
  }

  /// Converts this LocationEntity to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'manager': manager,
      'description': description,
      'name': name,
      'engineeringId': engineeringId,
      'state': state,
      'endDatetime': endDatetime,
      'startDatetime': startDatetime,
    };
  }
}
