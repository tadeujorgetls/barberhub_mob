import 'package:flutter/foundation.dart';
import 'service_model.dart';
import 'barber_model.dart';
import 'appointment_model.dart';
import '../mock/mock_data.dart';
import '../data/supabase_appointment_datasource.dart';
import '../data/supabase_catalog_datasource.dart';
import '../data/supabase_review_datasource.dart';
import '../data/supabase_blocked_dates_datasource.dart';
import '../features/barber_shop/domain/entities/blocked_date_entity.dart';

class AppDataProvider extends ChangeNotifier {
  final _appointmentDatasource = SupabaseAppointmentDatasource();
  final _blockedDatesDatasource = SupabaseBlockedDatesDatasource();
  final _catalogDatasource = SupabaseCatalogDatasource();
  final _reviewDatasource = SupabaseReviewDatasource();
  late List<BarbershopModel> _barbershops;
  late List<ServiceModel> _services;
  late List<BarberModel> _barbers;
  late List<AppointmentModel> _appointments;
  late List<ReviewModel> _reviews;
  List<BlockedDateEntity> _blockedDates = [];
  BarbershopModel? _selectedBarbershop;
  bool _isLoading = false;

  AppDataProvider() {
    _barbershops = MockData.barbershops();
    _services = MockData.services();
    _barbers = MockData.barbers();
    _appointments = MockData.seedAppointments(_barbershops);
    _reviews = MockData.seedReviews(_appointments);
    _loadCatalogFromSupabase();
  }

  Future<void> refreshCatalog() => _loadCatalogFromSupabase();

  Future<void> _loadCatalogFromSupabase() async {
    final datasource = _catalogDatasource;
    if (!datasource.isConfigured) return;

    try {
      _isLoading = true;
      notifyListeners();

      final remoteShops = await datasource.loadBarbershops();
      if (remoteShops.isNotEmpty) {
        _barbershops = remoteShops;
        _services = remoteShops.expand((shop) => shop.services).toList();
        _barbers = remoteShops.expand((shop) => shop.barbers).toList();
        _appointments =
            await _appointmentDatasource.loadAppointments(_barbershops);
        _reviews = await _reviewDatasource.loadReviews();
        _attachReviewsToAppointments();
        _syncReviewStats();
        _blockedDates = await _blockedDatesDatasource.loadBlockedDates();

        if (_selectedBarbershop != null) {
          _selectedBarbershop = _barbershops
              .where((shop) => shop.id == _selectedBarbershop!.id)
              .firstOrNull;
        }
      }
    } catch (error) {
      debugPrint(
          '[AppDataProvider] Falha ao carregar catalogo Supabase: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
  List<BlockedDateEntity> get blockedDates => List.unmodifiable(_blockedDates);

  bool isDateBlockedForShop(String shopId, DateTime date) {
    return _blockedDates
        .any((block) => block.shopId == shopId && block.blocks(date));
  }

  Future<void> refreshBlockedDates() async {
    if (!_blockedDatesDatasource.isConfigured) return;
    _blockedDates = await _blockedDatesDatasource.loadBlockedDates();
    notifyListeners();
  }

  List<ReviewModel> get allReviews => List.unmodifiable(_reviews);

  List<ReviewModel> reviewsForShop(String shopId) {
    final acceptedIds = _acceptedShopIds(shopId);
    return _reviews.where((r) => acceptedIds.contains(r.barbershopId)).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<ReviewModel> reviewsForBarber(String barberId) =>
      _reviews.where((r) => r.barberId == barberId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<ReviewModel> reviewsByClient(String clientId) =>
      _reviews.where((r) => r.clientId == clientId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  double ratingForShop(String shopId) {
    final reviews = reviewsForShop(shopId);
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold(0, (s, r) => s + r.rating);
    return sum / reviews.length;
  }

  double ratingForBarber(String barberId) {
    final reviews = reviewsForBarber(barberId);
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold(0, (s, r) => s + r.rating);
    return sum / reviews.length;
  }

  Map<int, int> ratingDistributionForShop(String shopId) {
    final dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviewsForShop(shopId)) {
      dist[r.rating] = (dist[r.rating] ?? 0) + 1;
    }
    return dist;
  }

  Map<int, int> ratingDistributionForBarber(String barberId) {
    final dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviewsForBarber(barberId)) {
      dist[r.rating] = (dist[r.rating] ?? 0) + 1;
    }
    return dist;
  }

  Future<ReviewModel> submitReview({
    required AppointmentModel appointment,
    required int rating,
    String? comment,
  }) async {
    if (!appointment.canReview) {
      throw StateError(
          'Este agendamento nao pode ser avaliado (ja avaliado ou nao concluido).');
    }
    if (rating < 1 || rating > 5) {
      throw ArgumentError('A nota deve ser entre 1 e 5.');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final review = _reviewDatasource.isConfigured
          ? await _reviewDatasource.createReview(
              appointment: appointment,
              rating: rating,
              comment: comment,
            )
          : ReviewModel(
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

      _reviews
          .removeWhere((item) => item.appointmentId == review.appointmentId);
      _reviews.add(review);
      _attachReviewToAppointment(review);
      _syncReviewStats();
      return review;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _attachReviewsToAppointments() {
    for (final appointment in _appointments) {
      appointment.review = null;
    }
    for (final review in _reviews) {
      _attachReviewToAppointment(review);
    }
  }

  void _attachReviewToAppointment(ReviewModel review) {
    final apptIdx =
        _appointments.indexWhere((a) => a.id == review.appointmentId);
    if (apptIdx != -1) _appointments[apptIdx].review = review;
  }

  void _syncReviewStats() {
    for (var i = 0; i < _barbershops.length; i++) {
      final shop = _barbershops[i];
      _barbershops[i] = shop.copyWith(rating: 0, reviewCount: 0);
    }

    final uniqueBarbers = <String, BarberModel>{};
    for (final barber in _barbers) {
      uniqueBarbers[barber.id] = barber;
    }
    for (final barber in _barbershops.expand((shop) => shop.barbers)) {
      uniqueBarbers[barber.id] = barber;
    }

    for (final barber in uniqueBarbers.values) {
      barber.rating = 0;
      barber.reviewCount = 0;
    }

    for (var i = 0; i < _barbershops.length; i++) {
      final shop = _barbershops[i];
      final reviews = reviewsForShop(shop.id);
      if (reviews.isEmpty) continue;
      final rating =
          reviews.fold<int>(0, (sum, r) => sum + r.rating) / reviews.length;
      _barbershops[i] = shop.copyWith(
        rating: double.parse(rating.toStringAsFixed(1)),
        reviewCount: reviews.length,
      );
    }

    for (final barber in uniqueBarbers.values) {
      final reviews = reviewsForBarber(barber.id);
      if (reviews.isEmpty) continue;
      final rating =
          reviews.fold<int>(0, (sum, r) => sum + r.rating) / reviews.length;
      barber.rating = double.parse(rating.toStringAsFixed(1));
      barber.reviewCount = reviews.length;
    }
  }

  List<ProductModel> get products {
    final src = _selectedBarbershop?.availableProducts ?? [];
    return List.unmodifiable(src);
  }

  List<ProductModel> get featuredProducts {
    final src = _selectedBarbershop?.featuredProducts ?? [];
    return List.unmodifiable(src);
  }

  List<ProductModel> productsFor(BarbershopModel shop) =>
      List.unmodifiable(shopFor(shop).availableProducts);

  List<ProductModel> featuredProductsFor(BarbershopModel shop) =>
      List.unmodifiable(shopFor(shop).featuredProducts);

  List<ProductModel> productsByCategory(
          BarbershopModel shop, ProductCategory cat) =>
      List.unmodifiable(shopFor(shop).productsByCategory(cat));

  List<ProductCategory> availableCategoriesFor(BarbershopModel shop) {
    final cats = shopFor(shop).availableProducts.map((p) => p.category).toSet();
    return ProductCategory.values.where((c) => cats.contains(c)).toList();
  }

  BarbershopModel shopFor(BarbershopModel shop) => _shopById(shop.id) ?? shop;

  void selectBarbershop(BarbershopModel shop) {
    _selectedBarbershop = shopFor(shop);
    notifyListeners();
  }

  void clearSelectedBarbershop() {
    _selectedBarbershop = null;
    notifyListeners();
  }

  List<ServiceModel> servicesFor(BarbershopModel shop) =>
      shop.services.where((s) => s.isActive).toList();

  List<BarberModel> barbersFor(BarbershopModel shop) =>
      shop.barbers.where((b) => b.isActive).toList();

  List<AppointmentModel> appointmentsForShop(String shopId) {
    final acceptedIds = _acceptedShopIds(shopId);
    return _appointments
        .where((a) => acceptedIds.contains(a.barbershop.id))
        .toList();
  }

  List<AppointmentModel> appointmentsForClient(String clientId) =>
      _appointments.where((a) => a.clientId == clientId).toList();

  List<AppointmentModel> activeForClient(String clientId) =>
      appointmentsForClient(clientId)
          .where((a) => a.effectiveStatus == AppointmentStatus.scheduled)
          .toList()
        ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  List<AppointmentModel> pastForClient(String clientId) =>
      appointmentsForClient(clientId)
          .where((a) => a.effectiveStatus != AppointmentStatus.scheduled)
          .toList()
        ..sort((a, b) => b.startsAt.compareTo(a.startsAt));

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

  List<AppointmentModel> get allAppointmentsSorted =>
      List.of(_appointments)..sort((a, b) => b.date.compareTo(a.date));

  int get totalRevenue => _appointments
      .where((a) => a.status == AppointmentStatus.completed)
      .fold(0, (sum, a) => sum + a.service.price.toInt());

  int get scheduledCount => _appointments
      .where((a) => a.effectiveStatus == AppointmentStatus.scheduled)
      .length;

  int get completedCount => _appointments
      .where((a) => a.status == AppointmentStatus.completed)
      .length;

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
          'O servico "${service.name}" nao pertence a barbearia "${barbershop.name}".');
    }
    if (!isBarberFromShop(barber, barbershop)) {
      throw ArgumentError(
          'O barbeiro "${barber.name}" nao pertence a barbearia "${barbershop.name}".');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final appt = _appointmentDatasource.isConfigured
          ? await _appointmentDatasource.createAppointment(
              clientId: clientId,
              clientName: clientName,
              service: service,
              barber: barber,
              barbershop: barbershop,
              date: date,
              timeSlot: timeSlot,
            )
          : AppointmentModel(
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
      return appt;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelAppointment(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_appointmentDatasource.isConfigured) {
        await _appointmentDatasource.updateStatus(
          id,
          AppointmentStatus.cancelled,
        );
      }
      final idx = _appointments.indexWhere((a) => a.id == id);
      if (idx != -1) _appointments[idx].status = AppointmentStatus.cancelled;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AppointmentModel?> rescheduleAppointment({
    required String id,
    required DateTime newDate,
    required String newTimeSlot,
    required BarberModel newBarber,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final idx = _appointments.indexWhere((a) => a.id == id);
      if (idx == -1) return null;

      final old = _appointments[idx];
      if (!isBarberFromShop(newBarber, old.barbershop)) {
        throw ArgumentError(
            'O barbeiro "${newBarber.name}" nao pertence a barbearia "${old.barbershop.name}".');
      }

      final newAppt = _appointmentDatasource.isConfigured
          ? await _appointmentDatasource.rescheduleAppointment(
              old: old,
              newDate: newDate,
              newTimeSlot: newTimeSlot,
              newBarber: newBarber,
            )
          : AppointmentModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              clientId: old.clientId,
              clientName: old.clientName,
              service: old.service,
              barber: newBarber,
              barbershop: old.barbershop,
              date: newDate,
              timeSlot: newTimeSlot,
            );

      old.status = AppointmentStatus.cancelled;
      _appointments.add(newAppt);
      return newAppt;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAppointmentStatus(
      String id, AppointmentStatus status) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_appointmentDatasource.isConfigured) {
        await _appointmentDatasource.updateStatus(id, status);
      }
      final idx = _appointments.indexWhere((a) => a.id == id);
      if (idx != -1) _appointments[idx].status = status;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  void addBarbershop(BarbershopModel shop) {
    _barbershops.add(shop);
    notifyListeners();
  }

  // Estes operam na lista services de cada BarbershopModel individualmente.

  List<ServiceModel> servicesForShop(String shopId) {
    final shop = _shopById(shopId);
    return shop?.services ?? [];
  }

  Future<void> addShopService(String shopId, ServiceModel service) async {
    final shop = _shopById(shopId);
    if (shop == null) return;

    final saved = _catalogDatasource.isConfigured
        ? await _catalogDatasource.createService(
            barbershopId: _remoteShopId(shopId),
            service: service,
          )
        : service;

    shop.services.add(saved);
    notifyListeners();
  }

  Future<void> updateShopService(String shopId, ServiceModel updated) async {
    final shop = _shopById(shopId);
    if (shop == null) return;
    final idx = shop.services.indexWhere((s) => s.id == updated.id);
    if (idx == -1) return;

    final saved = _catalogDatasource.isConfigured
        ? await _catalogDatasource.updateService(
            serviceId: updated.id,
            service: updated,
          )
        : updated;

    shop.services[idx] = saved;
    notifyListeners();
  }

  Future<void> deleteShopService(String shopId, String serviceId) async {
    final shop = _shopById(shopId);
    if (shop == null) return;

    if (_catalogDatasource.isConfigured) {
      await _catalogDatasource.deactivateService(serviceId);
    }

    shop.services.removeWhere((s) => s.id == serviceId);
    notifyListeners();
  }

  Future<void> toggleShopServiceActive(String shopId, String serviceId) async {
    final shop = _shopById(shopId);
    if (shop == null) return;
    final idx = shop.services.indexWhere((s) => s.id == serviceId);
    if (idx == -1) return;

    final updated = shop.services[idx].copyWith(
      isActive: !shop.services[idx].isActive,
    );
    final saved = _catalogDatasource.isConfigured
        ? await _catalogDatasource.updateService(
            serviceId: updated.id,
            service: updated,
          )
        : updated;

    shop.services[idx] = saved;
    notifyListeners();
  }

  BarbershopModel? _shopById(String shopId) {
    final exact = _barbershops.where((s) => s.id == shopId).firstOrNull;
    if (exact != null) return exact;

    final legacyId = _legacyShopId(shopId);
    return _barbershops.where((s) => s.id == legacyId).firstOrNull;
  }

  Set<String> _acceptedShopIds(String shopId) => {
        shopId,
        _remoteShopId(shopId),
        _legacyShopId(shopId),
      };

  String _remoteShopId(String shopId) {
    switch (shopId) {
      case 'bs1':
        return '00000000-0000-0000-0000-000000000b01';
      case 'bs2':
        return '00000000-0000-0000-0000-000000000b02';
      case 'bs3':
        return '00000000-0000-0000-0000-000000000b03';
      default:
        return shopId;
    }
  }

  String _legacyShopId(String shopId) {
    switch (shopId) {
      case '00000000-0000-0000-0000-000000000b01':
        return 'bs1';
      case '00000000-0000-0000-0000-000000000b02':
        return 'bs2';
      case '00000000-0000-0000-0000-000000000b03':
        return 'bs3';
      default:
        return shopId;
    }
  }
}
