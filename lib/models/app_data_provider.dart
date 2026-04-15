import 'package:flutter/foundation.dart';
import 'service_model.dart';
import 'barber_model.dart';
import 'appointment_model.dart';
import '../mock/mock_data.dart';

class AppDataProvider extends ChangeNotifier {
  late List<BarbershopModel> _barbershops;
  late List<ServiceModel> _services;
  late List<BarberModel> _barbers;
  late List<AppointmentModel> _appointments;
  BarbershopModel? _selectedBarbershop;
  bool _isLoading = false;

  AppDataProvider() {
    _barbershops = MockData.barbershops();
    _services = MockData.services();
    _barbers = MockData.barbers();
    _appointments = MockData.seedAppointments(_barbershops);
  }

  // ── Getters gerais ────────────────────────────────────────────────────────
  List<BarbershopModel> get barbershops => List.unmodifiable(_barbershops);

  BarbershopModel? get selectedBarbershop => _selectedBarbershop;

  bool get isBarbershopSelected => _selectedBarbershop != null;

  /// Serviços ativos da barbearia selecionada, ou da 1ª por compatibilidade.
  List<ServiceModel> get services {
    final src = _selectedBarbershop?.services ?? _services;
    return List.unmodifiable(src.where((s) => s.isActive));
  }

  List<ServiceModel> get allServices {
    final src = _selectedBarbershop?.services ?? _services;
    return List.unmodifiable(src);
  }

  /// Barbeiros ativos da barbearia selecionada, ou da 1ª por compatibilidade.
  List<BarberModel> get barbers {
    final src = _selectedBarbershop?.barbers ?? _barbers;
    return List.unmodifiable(src.where((b) => b.isActive));
  }

  List<BarberModel> get allBarbers {
    final src = _selectedBarbershop?.barbers ?? _barbers;
    return List.unmodifiable(src);
  }

  List<AppointmentModel> get appointments => List.unmodifiable(_appointments);

  bool get isLoading => _isLoading;

  // ── Seleção de barbearia ──────────────────────────────────────────────────
  void selectBarbershop(BarbershopModel shop) {
    _selectedBarbershop = shop;
    notifyListeners();
  }

  void clearSelectedBarbershop() {
    _selectedBarbershop = null;
    notifyListeners();
  }

  // ── Queries por barbearia ─────────────────────────────────────────────────
  List<ServiceModel> servicesFor(BarbershopModel shop) =>
      shop.services.where((s) => s.isActive).toList();

  List<BarberModel> barbersFor(BarbershopModel shop) =>
      shop.barbers.where((b) => b.isActive).toList();

  List<AppointmentModel> appointmentsForShop(String shopId) =>
      _appointments.where((a) => a.barbershop.id == shopId).toList();

  // ── Queries de cliente ────────────────────────────────────────────────────
  List<AppointmentModel> appointmentsForClient(String clientId) =>
      _appointments.where((a) => a.clientId == clientId).toList();

  List<AppointmentModel> activeForClient(String clientId) =>
      appointmentsForClient(clientId)
          .where((a) => a.status == AppointmentStatus.scheduled)
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  List<AppointmentModel> pastForClient(String clientId) =>
      appointmentsForClient(clientId)
          .where((a) => a.status != AppointmentStatus.scheduled)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  // ── Queries de barbeiro ───────────────────────────────────────────────────
  List<AppointmentModel> appointmentsForBarber(String barberId) =>
      _appointments
          .where((a) => a.barber.id == barberId)
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  List<AppointmentModel> todayForBarber(String barberId) {
    final today = DateTime.now();
    return appointmentsForBarber(barberId).where((a) {
      return a.date.year == today.year &&
          a.date.month == today.month &&
          a.date.day == today.day;
    }).toList();
  }

  // ── Admin ─────────────────────────────────────────────────────────────────
  List<AppointmentModel> get allAppointmentsSorted =>
      List.of(_appointments)..sort((a, b) => b.date.compareTo(a.date));

  int get totalRevenue => _appointments
      .where((a) => a.status == AppointmentStatus.completed)
      .fold(0, (sum, a) => sum + a.service.price.toInt());

  int get scheduledCount =>
      _appointments
          .where((a) => a.status == AppointmentStatus.scheduled)
          .length;

  int get completedCount =>
      _appointments
          .where((a) => a.status == AppointmentStatus.completed)
          .length;

  // ── Validações de agendamento ─────────────────────────────────────────────

  /// Valida se o serviço pertence à barbearia.
  bool isServiceFromShop(ServiceModel service, BarbershopModel shop) =>
      shop.services.any((s) => s.id == service.id);

  /// Valida se o barbeiro pertence à barbearia.
  bool isBarberFromShop(BarberModel barber, BarbershopModel shop) =>
      shop.barbers.any((b) => b.id == barber.id);

  /// Retorna horários já ocupados para um barbeiro em uma data.
  Set<String> bookedSlotsFor(String barberId, DateTime date) {
    return _appointments
        .where((a) =>
            a.barber.id == barberId &&
            a.date.year == date.year &&
            a.date.month == date.month &&
            a.date.day == date.day &&
            a.status == AppointmentStatus.scheduled)
        .map((a) => a.timeSlot)
        .toSet();
  }

  // ── Client: Agendar ───────────────────────────────────────────────────────
  /// Requer barbearia selecionada. Lança exceção se dados inconsistentes.
  Future<AppointmentModel> bookAppointment({
    required String clientId,
    required String clientName,
    required ServiceModel service,
    required BarberModel barber,
    required BarbershopModel barbershop,
    required DateTime date,
    required String timeSlot,
  }) async {
    // Validação de consistência
    if (!isServiceFromShop(service, barbershop)) {
      throw ArgumentError(
          'O serviço "${service.name}" não pertence à barbearia "${barbershop.name}".');
    }
    if (!isBarberFromShop(barber, barbershop)) {
      throw ArgumentError(
          'O barbeiro "${barber.name}" não pertence à barbearia "${barbershop.name}".');
    }

    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));

    final appt = AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: clientId,
      clientName: clientName,
      service: service,
      barber: barber,
      barbershop: barbershop,
      date: date,
      timeSlot: timeSlot,
    );

    _appointments.add(appt);
    _isLoading = false;
    notifyListeners();
    return appt;
  }

  // ── Client: Cancelar ──────────────────────────────────────────────────────
  Future<void> cancelAppointment(String id) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) _appointments[idx].status = AppointmentStatus.cancelled;
    _isLoading = false;
    notifyListeners();
  }

  // ── Client: Remarcar ──────────────────────────────────────────────────────
  Future<AppointmentModel?> rescheduleAppointment({
    required String id,
    required DateTime newDate,
    required String newTimeSlot,
    required BarberModel newBarber,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));

    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx == -1) {
      _isLoading = false;
      notifyListeners();
      return null;
    }

    final old = _appointments[idx];

    // Valida que o novo barbeiro pertence à mesma barbearia
    if (!isBarberFromShop(newBarber, old.barbershop)) {
      _isLoading = false;
      notifyListeners();
      throw ArgumentError(
          'O barbeiro "${newBarber.name}" não pertence à barbearia "${old.barbershop.name}".');
    }

    old.status = AppointmentStatus.cancelled;

    final newAppt = AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: old.clientId,
      clientName: old.clientName,
      service: old.service,
      barber: newBarber,
      barbershop: old.barbershop,
      date: newDate,
      timeSlot: newTimeSlot,
    );

    _appointments.add(newAppt);
    _isLoading = false;
    notifyListeners();
    return newAppt;
  }

  // ── Barber: Atualizar status ──────────────────────────────────────────────
  Future<void> updateAppointmentStatus(
      String id, AppointmentStatus status) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) _appointments[idx].status = status;
    _isLoading = false;
    notifyListeners();
  }

  // ── Admin: Service CRUD ───────────────────────────────────────────────────
  Future<void> addService(ServiceModel service) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _services.add(service);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateService(String id, ServiceModel updated) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _services.indexWhere((s) => s.id == id);
    if (idx != -1) _services[idx] = updated;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteService(String id) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _services.indexWhere((s) => s.id == id);
    if (idx != -1) _services[idx].isActive = false;
    _isLoading = false;
    notifyListeners();
  }

  // ── Admin: Barber CRUD ────────────────────────────────────────────────────
  Future<void> addBarber(BarberModel barber) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _barbers.add(barber);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateBarber(String id, BarberModel updated) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _barbers.indexWhere((b) => b.id == id);
    if (idx != -1) _barbers[idx] = updated;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteBarber(String id) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _barbers.indexWhere((b) => b.id == id);
    if (idx != -1) _barbers[idx].isActive = false;
    _isLoading = false;
    notifyListeners();
  }
}
