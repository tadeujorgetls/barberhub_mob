import 'service_model.dart';
import 'barber_model.dart';

enum AppointmentStatus { scheduled, completed, cancelled }

class AppointmentModel {
  final String id;
  final String clientId;
  final String clientName;
  final ServiceModel service;
  final BarberModel barber;
  final DateTime date;
  final String timeSlot;
  AppointmentStatus status;

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.service,
    required this.barber,
    required this.date,
    required this.timeSlot,
    this.status = AppointmentStatus.scheduled,
  });

  String get statusLabel {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Agendado';
      case AppointmentStatus.completed:
        return 'Concluído';
      case AppointmentStatus.cancelled:
        return 'Cancelado';
    }
  }

  bool get canCancel => status == AppointmentStatus.scheduled;
  bool get canReschedule => status == AppointmentStatus.scheduled;
  bool get canComplete => status == AppointmentStatus.scheduled;

  String get formattedDate {
    const months = [
      '', 'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return '${date.day} de ${months[date.month]}';
  }

  String get monthAbbr {
    const months = [
      '', 'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
      'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'
    ];
    return months[date.month];
  }
}
