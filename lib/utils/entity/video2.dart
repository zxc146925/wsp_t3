class Video2 {
  final String id;
  final String name;
  final String date;
  final int number;
  final int anomalyAmount;
  final String description;

  Video2({required this.id, required this.name, required this.date, required this.number, required this.anomalyAmount, required this.description});

  factory Video2.fromJson(Map<String, dynamic> json) => Video2(
        id: json["id"],
        name: json["name"],
        date: json["date"],
        number: json["number"],
        anomalyAmount: json["anomalyAmount"],
        description: json["description"],
      );
}
