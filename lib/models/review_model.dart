/// Modelo de avaliação de um agendamento concluído.
/// Uma avaliação está vinculada a um agendamento específico,
/// e impacta o rating da barbearia e do barbeiro.
class ReviewModel {
  final String id;
  final String appointmentId;
  final String clientId;
  final String clientName;
  final String barbershopId;
  final String barbershopName;
  final String barberId;
  final String barberName;
  final String serviceName;
  final int rating;           // 1 a 5
  final String? comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.appointmentId,
    required this.clientId,
    required this.clientName,
    required this.barbershopId,
    required this.barbershopName,
    required this.barberId,
    required this.barberName,
    required this.serviceName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  // ── Helpers ────────────────────────────────────────────────────────────────
  String get formattedDate {
    const months = [
      '', 'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${createdAt.day} de ${months[createdAt.month]} de ${createdAt.year}';
  }

  /// Retorna o emoji correspondente à nota.
  String get ratingEmoji {
    switch (rating) {
      case 5: return '🤩';
      case 4: return '😊';
      case 3: return '😐';
      case 2: return '😕';
      default: return '😞';
    }
  }

  /// Rótulo textual da nota.
  String get ratingLabel {
    switch (rating) {
      case 5: return 'Excelente';
      case 4: return 'Bom';
      case 3: return 'Regular';
      case 2: return 'Ruim';
      default: return 'Péssimo';
    }
  }
}
