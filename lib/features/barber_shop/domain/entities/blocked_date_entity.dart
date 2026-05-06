/// Tipo de bloqueio de data.
enum BlockType {
  /// Data específica (feriado, manutenção, etc.)
  specificDate,
  /// Bloqueia todos os domingos
  allSundays,
  /// Bloqueia todos os sábados
  allSaturdays,
}

extension BlockTypeExt on BlockType {
  String get label {
    switch (this) {
      case BlockType.specificDate: return 'Data específica';
      case BlockType.allSundays:   return 'Todos os domingos';
      case BlockType.allSaturdays: return 'Todos os sábados';
    }
  }
  String get icon {
    switch (this) {
      case BlockType.specificDate: return '📅';
      case BlockType.allSundays:   return '🔄';
      case BlockType.allSaturdays: return '🔄';
    }
  }
}

/// Representa um bloqueio de data/período em uma barbearia.
class BlockedDateEntity {
  final String id;
  final String shopId;
  final BlockType type;
  final DateTime? date;     // apenas para [BlockType.specificDate]
  final String reason;

  const BlockedDateEntity({
    required this.id,
    required this.shopId,
    required this.type,
    this.date,
    required this.reason,
  });

  /// Verifica se [day] é bloqueado por esta regra.
  bool blocks(DateTime day) {
    switch (type) {
      case BlockType.specificDate:
        if (date == null) return false;
        return date!.year == day.year &&
            date!.month == day.month &&
            date!.day == day.day;
      case BlockType.allSundays:
        return day.weekday == DateTime.sunday;
      case BlockType.allSaturdays:
        return day.weekday == DateTime.saturday;
    }
  }

  String get displayLabel {
    switch (type) {
      case BlockType.specificDate:
        if (date == null) return reason;
        final d = date!;
        return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      case BlockType.allSundays:   return 'Todos os domingos';
      case BlockType.allSaturdays: return 'Todos os sábados';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'shopId': shopId,
        'type': type.name,
        if (date != null) 'date': date!.toIso8601String(),
        'reason': reason,
      };

  factory BlockedDateEntity.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'specificDate';
    final type = BlockType.values.firstWhere(
      (t) => t.name == typeStr,
      orElse: () => BlockType.specificDate,
    );
    return BlockedDateEntity(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      type: type,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
      reason: json['reason'] as String? ?? '',
    );
  }
}
