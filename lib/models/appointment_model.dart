import 'service_model.dart';
import 'barber_model.dart';
import 'barbershop_model.dart';
import 'review_model.dart';

export 'barbershop_model.dart';
export 'review_model.dart';

enum AppointmentStatus {
  scheduled,
  pendingCompletion,
  completed,
  cancelled,
  noShow,
  expired,
}

class AppointmentModel {
  static const staleGracePeriod = Duration(hours: 24);

  final String id;
  final String clientId;
  final String clientName;
  final ServiceModel service;
  final BarberModel barber;
  final BarbershopModel barbershop;
  final DateTime date;
  final String timeSlot;
  AppointmentStatus status;

  /// Avaliacao do cliente para este agendamento.
  /// null = ainda nao avaliado.
  ReviewModel? review;

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.service,
    required this.barber,
    required this.barbershop,
    required this.date,
    required this.timeSlot,
    this.status = AppointmentStatus.scheduled,
    this.review,
  }) {
    assert(
      barbershop.services.any((s) => s.id == service.id),
      'O servico "${service.name}" nao pertence a barbearia "${barbershop.name}".',
    );
    assert(
      barbershop.barbers.any((b) => b.id == barber.id),
      'O barbeiro "${barber.name}" nao pertence a barbearia "${barbershop.name}".',
    );
  }

  DateTime get startsAt {
    final parts = timeSlot.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  DateTime get endsAt =>
      startsAt.add(Duration(minutes: service.durationMinutes));

  DateTime get staleAt => endsAt.add(staleGracePeriod);

  bool get hasStarted => !DateTime.now().isBefore(startsAt);

  bool get hasEnded => DateTime.now().isAfter(endsAt);

  bool get isStale => DateTime.now().isAfter(staleAt);

  AppointmentStatus get effectiveStatus {
    if (status != AppointmentStatus.scheduled) return status;
    if (isStale) return AppointmentStatus.expired;
    if (hasEnded) return AppointmentStatus.pendingCompletion;
    return AppointmentStatus.scheduled;
  }

  String get statusLabel {
    switch (effectiveStatus) {
      case AppointmentStatus.scheduled:
        return 'Agendado';
      case AppointmentStatus.pendingCompletion:
        return 'Aguardando finalização';
      case AppointmentStatus.completed:
        return 'Concluído';
      case AppointmentStatus.cancelled:
        return 'Cancelado';
      case AppointmentStatus.noShow:
        return 'Não compareceu';
      case AppointmentStatus.expired:
        return 'Expirado';
    }
  }

  bool get canCancel =>
      effectiveStatus == AppointmentStatus.scheduled && !hasStarted;
  bool get canReschedule => canCancel;

  bool get canComplete =>
      (status == AppointmentStatus.scheduled && hasStarted) ||
      status == AppointmentStatus.expired;

  bool get canMarkNoShow => canComplete;

  bool get isUpcoming => effectiveStatus == AppointmentStatus.scheduled;

  /// O cliente pode avaliar somente agendamentos concluidos e ainda nao avaliados.
  bool get canReview => status == AppointmentStatus.completed && review == null;

  bool get isReviewed =>
      status == AppointmentStatus.completed && review != null;

  String get formattedDate {
    const months = [
      '',
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez'
    ];
    return '${date.day} de ${months[date.month]}';
  }

  String get formattedDateFull {
    const months = [
      '',
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez'
    ];
    return '${date.day} de ${months[date.month]} de ${date.year}';
  }

  String get monthAbbr {
    const months = [
      '',
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ'
    ];
    return months[date.month];
  }
}
