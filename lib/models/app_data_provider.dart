import 'package:flutter/foundation.dart';
import 'service_model.dart';
import 'barber_model.dart';
import 'appointment_model.dart';
import '../mock/mock_data.dart';
import '../data/supabase_appointment_datasource.dart';
import '../data/supabase_catalog_datasource.dart';

class AppDataProvider extends ChangeNotifier {
  final _appointmentDatasource = SupabaseAppointmentDatasource();
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
    _loadCatalogFromSupabase();
  }

  Future<void> _loadCatalogFromSupabase() async {
    final datasource = SupabaseCatalogDatasource();
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
        _reviews = MockData.seedReviews(_appointments);

        if (_selectedBarbershop != null) {
          _selectedBarbershop = _barbershops
              .where((shop) => shop.id == _selectedBarbershop!.id)
              .firstOrNull;
        }
      }
    } catch (error) {
      debugPrint('[AppDataProvider] Falha ao carregar catalogo Supabase: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬ Getters gerais Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
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

  // Ã¢â€â‚¬Ã¢â€â‚¬ Reviews Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬

  List<ReviewModel> get allReviews => List.unmodifiable(_reviews);

  /// AvaliaÃƒÂ§ÃƒÂµes de uma barbearia, da mais recente para a mais antiga.
  List<ReviewModel> reviewsForShop(String shopId) =>
      _reviews.where((r) => r.barbershopId == shopId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// AvaliaÃƒÂ§ÃƒÂµes de um barbeiro especÃƒÂ­fico.
  List<ReviewModel> reviewsForBarber(String barberId) =>
      _reviews.where((r) => r.barberId == barberId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// AvaliaÃƒÂ§ÃƒÂµes feitas por um cliente.
  List<ReviewModel> reviewsByClient(String clientId) =>
      _reviews.where((r) => r.clientId == clientId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  /// MÃƒÂ©dia de rating de uma barbearia calculada a partir das avaliaÃƒÂ§ÃƒÂµes reais.
  double ratingForShop(String shopId) {
    final reviews = reviewsForShop(shopId);
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold(0, (s, r) => s + r.rating);
    return sum / reviews.length;
  }

  /// MÃƒÂ©dia de rating de um barbeiro.
  double ratingForBarber(String barberId) {
    final reviews = reviewsForBarber(barberId);
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold(0, (s, r) => s + r.rating);
    return sum / reviews.length;
  }

  /// DistribuiÃƒÂ§ÃƒÂ£o de notas (1Ã¢â‚¬â€œ5) de uma barbearia.
  Map<int, int> ratingDistributionForShop(String shopId) {
    final dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviewsForShop(shopId)) {
      dist[r.rating] = (dist[r.rating] ?? 0) + 1;
    }
    return dist;
  }

  /// DistribuiÃƒÂ§ÃƒÂ£o de notas (1Ã¢â‚¬â€œ5) de um barbeiro.
  Map<int, int> ratingDistributionForBarber(String barberId) {
    final dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviewsForBarber(barberId)) {
      dist[r.rating] = (dist[r.rating] ?? 0) + 1;
    }
    return dist;
  }

  /// Submete uma nova avaliaÃƒÂ§ÃƒÂ£o para um agendamento concluÃƒÂ­do.
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

    // Vincula a avaliaÃƒÂ§ÃƒÂ£o ao agendamento
    final apptIdx = _appointments.indexWhere((a) => a.id == appointment.id);
    if (apptIdx != -1) _appointments[apptIdx].review = review;

    // Atualiza rating em memÃƒÂ³ria da barbearia
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

    // Atualiza rating em memÃƒÂ³ria do barbeiro
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

  // Ã¢â€â‚¬Ã¢â€â‚¬ Produtos Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
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

  // Ã¢â€â‚¬Ã¢â€â‚¬ SeleÃƒÂ§ÃƒÂ£o de barbearia Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  void selectBarbershop(BarbershopModel shop) {
    _selectedBarbershop = shop;
    notifyListeners();
  }

  void clearSelectedBarbershop() {
    _selectedBarbershop = null;
    notifyListeners();
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬ Queries por barbearia Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  List<ServiceModel> servicesFor(BarbershopModel shop) =>
      shop.services.where((s) => s.isActive).toList();

  List<BarberModel> barbersFor(BarbershopModel shop) =>
      shop.barbers.where((b) => b.isActive).toList();

  List<AppointmentModel> appointmentsForShop(String shopId) =>
      _appointments.where((a) => a.barbershop.id == shopId).toList();

  // Ã¢â€â‚¬Ã¢â€â‚¬ Queries de cliente Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
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

  // Ã¢â€â‚¬Ã¢â€â‚¬ Queries de barbeiro Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
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

  // Ã¢â€â‚¬Ã¢â€â‚¬ Admin Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
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

  // Ã¢â€â‚¬Ã¢â€â‚¬ ValidaÃƒÂ§ÃƒÂµes Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
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

  // Ã¢â€â‚¬Ã¢â€â‚¬ Client: Agendar Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
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

  // Ã¢â€â‚¬Ã¢â€â‚¬ Admin: Service CRUD Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
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

  // Ã¢â€â‚¬Ã¢â€â‚¬ Admin: Barber CRUD Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
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

  /// Cria uma nova barbearia (admin). Persiste em memÃƒÂ³ria enquanto o app roda.
  void addBarbershop(BarbershopModel shop) {
    _barbershops.add(shop);
    notifyListeners();
  }

  // Ã¢â€â‚¬Ã¢â€â‚¬ Barbearia: serviÃƒÂ§os por shop (usados pelo BarberShopServicesScreen) Ã¢â€â‚¬Ã¢â€â‚¬Ã¢â€â‚¬
  // Distintos dos mÃƒÂ©todos de admin acima (operam em _services global).
  // Estes operam na lista services de cada BarbershopModel individualmente.

  List<ServiceModel> servicesForShop(String shopId) {
    final shop = _barbershops.where((s) => s.id == shopId).firstOrNull;
    return shop?.services ?? [];
  }

  void addShopService(String shopId, ServiceModel service) {
    final shop = _barbershops.where((s) => s.id == shopId).firstOrNull;
    if (shop == null) return;
    shop.services.add(service);
    notifyListeners();
  }

  void updateShopService(String shopId, ServiceModel updated) {
    final shop = _barbershops.where((s) => s.id == shopId).firstOrNull;
    if (shop == null) return;
    final idx = shop.services.indexWhere((s) => s.id == updated.id);
    if (idx != -1) shop.services[idx] = updated;
    notifyListeners();
  }

  void deleteShopService(String shopId, String serviceId) {
    final shop = _barbershops.where((s) => s.id == shopId).firstOrNull;
    if (shop == null) return;
    shop.services.removeWhere((s) => s.id == serviceId);
    notifyListeners();
  }

  void toggleShopServiceActive(String shopId, String serviceId) {
    final shop = _barbershops.where((s) => s.id == shopId).firstOrNull;
    if (shop == null) return;
    final idx = shop.services.indexWhere((s) => s.id == serviceId);
    if (idx != -1) {
      final s = shop.services[idx];
      shop.services[idx] = s.copyWith(isActive: !s.isActive);
    }
    notifyListeners();
  }
}
