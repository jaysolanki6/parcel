class Parcel {
  final String id;
  final DateTime date;
  final int parcelCount;
  final double totalAmount;

  const Parcel({
    required this.id,
    required this.date,
    required this.parcelCount,
    required this.totalAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'parcelCount': parcelCount,
      'totalAmount': totalAmount,
    };
  }

  factory Parcel.fromJson(Map<String, dynamic> json) {
    final parsedDate = DateTime.parse(json['date'].toString());

    return Parcel(
      id: json['id']?.toString() ??
          '${parsedDate.year}-${parsedDate.month}-${parsedDate.day}',
      date: parsedDate,
      parcelCount: (json['parcelCount'] as num).toInt(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }
}