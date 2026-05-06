/// Horário de funcionamento de um dia da semana.
class WorkingHoursEntity {
  final bool isOpen;
  final String openTime;  // "09:00"
  final String closeTime; // "18:00"

  const WorkingHoursEntity({
    required this.isOpen,
    this.openTime = '09:00',
    this.closeTime = '18:00',
  });

  WorkingHoursEntity copyWith({bool? isOpen, String? openTime, String? closeTime}) =>
      WorkingHoursEntity(
        isOpen: isOpen ?? this.isOpen,
        openTime: openTime ?? this.openTime,
        closeTime: closeTime ?? this.closeTime,
      );

  Map<String, dynamic> toJson() => {
        'isOpen': isOpen,
        'openTime': openTime,
        'closeTime': closeTime,
      };

  factory WorkingHoursEntity.fromJson(Map<String, dynamic> json) =>
      WorkingHoursEntity(
        isOpen: json['isOpen'] as bool? ?? true,
        openTime: json['openTime'] as String? ?? '09:00',
        closeTime: json['closeTime'] as String? ?? '18:00',
      );

  /// Gera lista de horários disponíveis entre abertura e fechamento.
  List<String> availableSlots(List<String> allSlots) {
    if (!isOpen) return [];
    return allSlots.where((s) => _inRange(s)).toList();
  }

  bool _inRange(String slot) {
    final slotMins = _toMinutes(slot);
    return slotMins >= _toMinutes(openTime) && slotMins < _toMinutes(closeTime);
  }

  static int _toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  static const Map<int, String> weekdayNames = {
    1: 'Segunda', 2: 'Terça', 3: 'Quarta',
    4: 'Quinta',  5: 'Sexta', 6: 'Sábado', 7: 'Domingo',
  };

  /// Padrão para uma barbearia típica: Seg–Sáb 09:00–18:00, Dom fechado.
  static Map<int, WorkingHoursEntity> defaultSchedule() => {
    1: const WorkingHoursEntity(isOpen: true),
    2: const WorkingHoursEntity(isOpen: true),
    3: const WorkingHoursEntity(isOpen: true),
    4: const WorkingHoursEntity(isOpen: true),
    5: const WorkingHoursEntity(isOpen: true),
    6: const WorkingHoursEntity(isOpen: true, openTime: '09:00', closeTime: '17:00'),
    7: const WorkingHoursEntity(isOpen: false),
  };
}
