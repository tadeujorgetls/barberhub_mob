import 'working_hours_entity.dart';

/// Configurações gerenciáveis de uma barbearia.
class ShopSettingsEntity {
  final String shopId;
  final String name;
  final String address;
  final String phone;
  /// weekday → WorkingHoursEntity (1=Seg ... 7=Dom)
  final Map<int, WorkingHoursEntity> workingHours;

  const ShopSettingsEntity({
    required this.shopId,
    required this.name,
    required this.address,
    required this.phone,
    required this.workingHours,
  });

  ShopSettingsEntity copyWith({
    String? name,
    String? address,
    String? phone,
    Map<int, WorkingHoursEntity>? workingHours,
  }) =>
      ShopSettingsEntity(
        shopId: shopId,
        name: name ?? this.name,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        workingHours: workingHours ?? this.workingHours,
      );

  Map<String, dynamic> toJson() => {
        'shopId': shopId,
        'name': name,
        'address': address,
        'phone': phone,
        'workingHours': workingHours.map(
          (k, v) => MapEntry(k.toString(), v.toJson()),
        ),
      };

  factory ShopSettingsEntity.fromJson(Map<String, dynamic> json) {
    final wh = <int, WorkingHoursEntity>{};
    final whRaw = json['workingHours'] as Map<String, dynamic>? ?? {};
    for (final e in whRaw.entries) {
      wh[int.parse(e.key)] = WorkingHoursEntity.fromJson(
        Map<String, dynamic>.from(e.value as Map),
      );
    }
    return ShopSettingsEntity(
      shopId: json['shopId'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String? ?? '',
      workingHours: wh.isEmpty ? WorkingHoursEntity.defaultSchedule() : wh,
    );
  }
}
