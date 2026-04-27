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
  late List<ReviewModel> _reviews;
  BarbershopModel? _selectedBarbershop;
  bool _isLoading = false;

  AppDataProvider() {
    _barbershops = MockData.barbershops();
    _services = MockData.services();
    _barbers = MockData.barbers();
    _appointments = MockData.seedAppointments(_barbershops);
    _reviews = MockData.seedReviews(_appointments);
  }

  // ── Getters gerais ────────────────────────────────────────────────────────
  List<BarbershopModel> get barbershops => List.unmodifiable(_barbershops);
  BarbershopModel? get selectedBarbershop => _selectedBarbershop;
  bool get isBarbershopSelected => _selectedBarbershop != null;
  bool get isLoading => _isLoading;

  List<ServiceModel> get services {
    final src = _selectedBarbershop?.services ?? _services;
    return List.unmodifiable(src.where((s) => s.isActive));
  }

  List<ServiceModel> get allServices {
    final src = _selectedBarbershop?.services ?? _services;
    return List.unmodifiable(src);
  }

  List<BarberModel> get barbers {
    final src = _selectedBarbershop?.barbers ?? _barbers;
    return List.unmodifiable(src.where((b) => b.isActive));
  }

  List<BarberModel> get allBarbers {
    final src = _selectedBarbershop?.barbers ?? _barbers;
    return List.unmodifiable(src);
  }

  List<AppointmentModel> get appointments => List.unmodifiable(_appointments);

  // ── Reviews ───────────────────────────────────────────────────────────────

  List<ReviewModel> get allReviews => List.unmodifiable(_reviews);

  /// Avaliações de uma barbearia, da mais recente para a mais antiga.
  List<ReviewModel> reviewsForShop(String shopId) =>
      _reviews.where((r) => r.barbershopId == shopId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Avaliações de um barbeiro específico.
  List<ReviewModel> reviewsForBarber(String barberId) =>
      _reviews.where((r) => r.barberId == barberId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Avaliações feitas por um cliente.
  List<ReviewModel> reviewsByClient(String clientId) =>
      _reviews.where((r) => r.clientId == clientId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// Média de rating de uma barbearia calculada a partir das avaliações reais.
  double ratingForShop(String shopId) {
    final reviews = reviewsForShop(shopId);
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold(0, (s, r) => s + r.rating);
    return sum / reviews.length;
  }

  /// Média de rating de um barbeiro.
  double ratingForBarber(String barberId) {
    final reviews = reviewsForBarber(barberId);
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold(0, (s, r) => s + r.rating);
    return sum / reviews.length;
  }

  /// Distribuição de notas (1–5) de uma barbearia.
  Map<int, int> ratingDistributionForShop(String shopId) {
    final dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviewsForShop(shopId)) {
      dist[r.rating] = (dist[r.rating] ?? 0) + 1;
    }
    return dist;
  }

  /// Distribuição de notas (1–5) de um barbeiro.
  Map<int, int> ratingDistributionForBarber(String barberId) {
    final dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviewsForBarber(barberId)) {
      dist[r.rating] = (dist[r.rating] ?? 0) + 1;
    }
    return dist;
  }

  /// Submete uma nova avaliação para um agendamento concluído.
  Future<ReviewModel> submitReview({
    required AppointmentModel appointment,
    required int rating,
    String? comment,
  }) async {
    if (!appointment.canReview) {
      throw StateError(
          'Este agendamento não pode ser avaliado (já avaliado ou não concluído).');
    }
    if (rating < 1 || rating > 5) {
      throw ArgumentError('A nota deve ser entre 1 e 5.');
    }

    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 700));

    final review = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      appointmentId: appointment.id,
      clientId: appointment.clientId,
      clientName: appointment.clientName,
      barbershopId: appointment.barbershop.id,
      barbershopName: appointment.barbershop.name,
      barberId: appointment.barber.id,
      barberName: appointment.barber.name,
      serviceName: appointment.service.name,
      rating: rating,
      comment: comment?.trim().isEmpty == true ? null : comment?.trim(),
      createdAt: DateTime.now(),
    );

    _reviews.add(review);

    // Vincula a avaliação ao agendamento
    final apptIdx = _appointments.indexWhere((a) => a.id == appointment.id);
    if (apptIdx != -1) _appointments[apptIdx].review = review;

    // Atualiza rating em memória da barbearia
    final shopIdx =
        _barbershops.indexWhere((s) => s.id == appointment.barbershop.id);
    if (shopIdx != -1) {
      final newRating = ratingForShop(appointment.barbershop.id);
      final newCount = reviewsForShop(appointment.barbershop.id).length;
      _barbershops[shopIdx] = _barbershops[shopIdx].copyWith(
        rating: double.parse(newRating.toStringAsFixed(1)),
        reviewCount: newCount,
      );
    }

    // Atualiza rating em memória do barbeiro
    final allBarbers = _barbershops.expand((s) => s.barbers).toList()
      ..addAll(_barbers);
    for (final b in allBarbers) {
      if (b.id == appointment.barber.id) {
        final newRating = ratingForBarber(b.id);
        final newCount = reviewsForBarber(b.id).length;
        b.rating = double.parse(newRating.toStringAsFixed(1));
        b.reviewCount = newCount;
      }
    }

    _isLoading = false;
    notifyListeners();
    return review;
  }

  // ── Produtos ──────────────────────────────────────────────────────────────
  List<ProductModel> get products {
    final src = _selectedBarbershop?.availableProducts ?? [];
    return List.unmodifiable(src);
  }

  List<ProductModel> get featuredProducts {
    final src = _selectedBarbershop?.featuredProducts ?? [];
    return List.unmodifiable(src);
  }

  List<ProductModel> productsFor(BarbershopModel shop) =>
      List.unmodifiable(shop.availableProducts);

  List<ProductModel> featuredProductsFor(BarbershopModel shop) =>
      List.unmodifiable(shop.featuredProducts);

  List<ProductModel> productsByCategory(
          BarbershopModel shop, ProductCategory cat) =>
      List.unmodifiable(shop.productsByCategory(cat));

  List<ProductCategory> availableCategoriesFor(BarbershopModel shop) {
    final cats = shop.availableProducts.map((p) => p.category).toSet();
    return ProductCategory.values.where((c) => cats.contains(c)).toList();
  }

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
      _appointments.where((a) => a.barber.id == barberId).toList()
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

  int get scheduledCount => _appointments
      .where((a) => a.status == AppointmentStatus.scheduled)
      .length;

  int get completedCount => _appointments
      .where((a) => a.status == AppointmentStatus.completed)
      .length;

  // ── Validações ────────────────────────────────────────────────────────────
  bool isServiceFromShop(ServiceModel service, BarbershopModel shop) =>
      shop.services.any((s) => s.id == service.id);

  bool isBarberFromShop(BarberModel barber, BarbershopModel shop) =>
      shop.barbers.any((b) => b.id == barber.id);

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
  Future<AppointmentModel> bookAppointment({
    required String clientId,
    required String clientName,
    required ServiceModel service,
    required BarberModel barber,
    required BarbershopModel barbershop,
    required DateTime date,
    required String timeSlot,
  }) async {
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
