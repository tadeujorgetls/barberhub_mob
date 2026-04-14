class ServiceModel {
  final String id;
  String name;
  String description;
  double price;
  int durationMinutes;
  String iconName;
  bool isActive;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.iconName,
    this.isActive = true,
  });

  String get formattedPrice =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  String get formattedDuration {
    if (durationMinutes < 60) return '$durationMinutes min';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}min';
  }

  ServiceModel copyWith({
    String? name,
    String? description,
    double? price,
    int? durationMinutes,
    String? iconName,
    bool? isActive,
  }) {
    return ServiceModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      iconName: iconName ?? this.iconName,
      isActive: isActive ?? this.isActive,
    );
  }
}
