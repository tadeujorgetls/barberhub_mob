import 'package:flutter/foundation.dart';
import 'service_model.dart';
import 'barber_model.dart';
import 'appointment_model.dart';

class AppDataProvider extends ChangeNotifier {
  // ── Mock Services ────────────────────────────────────────────────────────────
  final List<ServiceModel> _services = const [
    ServiceModel(
      id: 's1',
      name: 'Corte Clássico',
      description:
          'Corte tradicional com tesoura e máquina. Inclui lavagem, corte personalizado e finalização com produtos premium. Ideal para quem busca um visual elegante e atemporal.',
      price: 45.00,
      durationMinutes: 30,
      iconName: 'cut',
    ),
    ServiceModel(
      id: 's2',
      name: 'Barba Completa',
      description:
          'Modelagem e aparação da barba com navalha e toalha quente. Inclui hidratação pós-barba e finalização com balm. O tratamento favorito dos homens modernos.',
      price: 35.00,
      durationMinutes: 25,
      iconName: 'face',
    ),
    ServiceModel(
      id: 's3',
      name: 'Corte + Barba',
      description:
          'Combo completo: corte de cabelo e barba na mesma sessão. O pacote mais popular da casa, com lavagem, corte, modelagem de barba e finalização.',
      price: 70.00,
      durationMinutes: 50,
      iconName: 'combo',
    ),
    ServiceModel(
      id: 's4',
      name: 'Platinado / Coloração',
      description:
          'Descoloração, mechas ou coloração completa. Usamos produtos profissionais de alta qualidade para garantir resultado duradouro sem agredir os fios.',
      price: 120.00,
      durationMinutes: 90,
      iconName: 'color',
    ),
    ServiceModel(
      id: 's5',
      name: 'Hidratação Capilar',
      description:
          'Tratamento intensivo com máscara nutritiva, vitaminas e óleos essenciais. Recupera o brilho e a saúde dos cabelos ressecados ou danificados.',
      price: 55.00,
      durationMinutes: 40,
      iconName: 'spa',
    ),
    ServiceModel(
      id: 's6',
      name: 'Sobrancelha',
      description:
          'Design e alinhamento das sobrancelhas com linha e pinça. Realça o olhar e garante uma aparência mais cuidada e jovem.',
      price: 20.00,
      durationMinutes: 15,
      iconName: 'brow',
    ),
  ];

  // ── Mock Barbers ─────────────────────────────────────────────────────────────
  final List<BarberModel> _barbers = const [
    BarberModel(
      id: 'b1',
      name: 'Rafael Mendes',
      specialty: 'Cortes Clássicos & Fade',
      rating: 4.9,
      reviewCount: 238,
      avatarInitials: 'RM',
    ),
    BarberModel(
      id: 'b2',
      name: 'Diego Costa',
      specialty: 'Barba & Navalha',
      rating: 4.8,
      reviewCount: 175,
      avatarInitials: 'DC',
    ),
    BarberModel(
      id: 'b3',
      name: 'Thiago Alves',
      specialty: 'Coloração & Química',
      rating: 4.7,
      reviewCount: 112,
      avatarInitials: 'TA',
    ),
    BarberModel(
      id: 'b4',
      name: 'Lucas Ferreira',
      specialty: 'Cortes Modernos',
      rating: 4.6,
      reviewCount: 89,
      avatarInitials: 'LF',
    ),
  ];

  // ── Appointments State ───────────────────────────────────────────────────────
  final List<AppointmentModel> _appointments = [];
  bool _isLoading = false;

  // ── Getters ──────────────────────────────────────────────────────────────────
  List<ServiceModel> get services => List.unmodifiable(_services);
  List<BarberModel> get barbers => List.unmodifiable(_barbers);
  List<AppointmentModel> get appointments => List.unmodifiable(_appointments);
  bool get isLoading => _isLoading;

  List<AppointmentModel> get activeAppointments => _appointments
      .where((a) => a.status == AppointmentStatus.scheduled)
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  List<AppointmentModel> get pastAppointments => _appointments
      .where((a) => a.status != AppointmentStatus.scheduled)
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  // ── Time slots ───────────────────────────────────────────────────────────────
  static const List<String> timeSlots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
  ];

  // ── Actions ──────────────────────────────────────────────────────────────────
  Future<AppointmentModel> bookAppointment({
    required ServiceModel service,
    required BarberModel barber,
    required DateTime date,
    required String timeSlot,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    final appointment = AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      service: service,
      barber: barber,
      date: date,
      timeSlot: timeSlot,
      status: AppointmentStatus.scheduled,
    );

    _appointments.add(appointment);
    _isLoading = false;
    notifyListeners();
    return appointment;
  }

  Future<void> cancelAppointment(String id) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _appointments[idx].status = AppointmentStatus.cancelled;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<AppointmentModel?> rescheduleAppointment({
    required String id,
    required DateTime newDate,
    required String newTimeSlot,
    required BarberModel newBarber,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx == -1) {
      _isLoading = false;
      notifyListeners();
      return null;
    }

    final old = _appointments[idx];
    old.status = AppointmentStatus.cancelled;

    final newAppointment = AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      service: old.service,
      barber: newBarber,
      date: newDate,
      timeSlot: newTimeSlot,
      status: AppointmentStatus.scheduled,
    );

    _appointments.add(newAppointment);
    _isLoading = false;
    notifyListeners();
    return newAppointment;
  }
}
