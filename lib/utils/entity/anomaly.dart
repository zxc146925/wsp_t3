class AnomalyEntity {
  final String id;
  final String handlingStatus;
  final String anomalyType;
  final String caseName;
  final String camera;
  final String date;
  final String time;
  bool isFavorite;

  AnomalyEntity({
    required this.id,
    required this.handlingStatus,
    required this.anomalyType,
    required this.caseName,
    required this.camera,
    required this.date,
    required this.time,
    this.isFavorite = false,
  });

    
    Map<String, dynamic> toJson() => {
        "id": id,
        "handlingStatus": handlingStatus,
        "anomalyType": anomalyType,
        "caseName": caseName,
        "camera": camera,
        "date": date,
        "time": time,
        "isFavorite": isFavorite,
      };
    
    
}
