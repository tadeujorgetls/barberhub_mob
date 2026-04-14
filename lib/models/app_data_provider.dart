import 'package:flutter/foundation.dart';
import 'service_model.dart';
import 'barber_model.dart';
import 'appointment_model.dart';
import '../mock/mock_data.dart';

class AppDataProvider extends ChangeNotifier {
  late List<ServiceModel> _services;
  late List<BarberModel> _barbers;
  late List<AppointmentModel> _appointments;
  bool _isLoading = false;

  AppDataProvider() {
    _services = MockData.services();
    _barbers = MockData.barbers();
    _appointments = MockData.seedAppointments(_services, _barbers);
  }

  // ── Getters ──────────────────────────────────────────────────────────────────
  List<ServiceModel> get services =>
      List.unmodifiable(_services.where((s) => s.isActive));
  List<ServiceModel> get allServices => List.unmodifiable(_services);
  List<BarberModel> get barbers =>
      List.unmodifiable(_barbers.where((b) => b.isActive));
  List<BarberModel> get allBarbers => List.unmodifiable(_barbers);
  List<AppointmentModel> get appointments => List.unmodifiable(_appointments);
  bool get isLoading => _isLoading;

  // ── Client filtered ──────────────────────────────────────────────────────────
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

  // ── Barber filtered ──────────────────────────────────────────────────────────
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

  // ── Admin ────────────────────────────────────────────────────────────────────
  List<AppointmentModel> get allAppointmentsSorted =>
      List.of(_appointments)..sort((a, b) => b.date.compareTo(a.date));

  int get totalRevenue => _appointments
      .where((a) => a.status == AppointmentStatus.completed)
      .fold(0, (sum, a) => sum + a.service.price.toInt());

  int get scheduledCount =>
      _appointments.where((a) => a.status == AppointmentStatus.scheduled).length;

  int get completedCount =>
      _appointments.where((a) => a.status == AppointmentStatus.completed).length;

  // ── Client actions ───────────────────────────────────────────────────────────
  Future<AppointmentModel> bookAppointment({
    required String clientId,
    required String clientName,
    required ServiceModel service,
    required BarberModel barber,
    required DateTime date,
    required String timeSlot,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));

    final appt = AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: clientId,
      clientName: clientName,
      service: service,
      barber: barber,
      date: date,
      timeSlot: timeSlot,
    );

    _appointments.add(appt);
    _isLoading = false;
    notifyListeners();
    return appt;
  }

  Future<void> cancelAppointment(String id) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) _appointments[idx].status = AppointmentStatus.cancelled;
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
    await Future.delayed(const Duration(milliseconds: 900));

    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx == -1) {
      _isLoading = false;
      notifyListeners();
      return null;
    }

    final old = _appointments[idx];
    old.status = AppointmentStatus.cancelled;

    final newAppt = AppointmentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: old.clientId,
      clientName: old.clientName,
      service: old.service,
      barber: newBarber,
      date: newDate,
      timeSlot: newTimeSlot,
    );

    _appointments.add(newAppt);
    _isLoading = false;
    notifyListeners();
    return newAppt;
  }

  // ── Barber actions ───────────────────────────────────────────────────────────
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

  // ── Admin: Service CRUD ──────────────────────────────────────────────────────
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

  // ── Admin: Barber CRUD ───────────────────────────────────────────────────────
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
