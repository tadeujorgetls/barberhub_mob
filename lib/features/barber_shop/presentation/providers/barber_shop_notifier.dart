import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_hub/data/supabase_appointment_datasource.dart';
import 'package:barber_hub/data/supabase_catalog_datasource.dart';
import 'package:barber_hub/data/supabase_review_datasource.dart';
import 'package:barber_hub/features/auth/presentation/providers/auth_providers.dart';
import 'package:barber_hub/features/barber_shop/domain/entities/barber_shop_entity.dart';
import 'package:barber_hub/models/appointment_model.dart';
import 'package:barber_hub/mock/mock_data.dart';
import 'barber_shop_state.dart';

class BarberShopNotifier extends StateNotifier<BarberShopState> {
  final Ref _ref;
  final _catalogDatasource = SupabaseCatalogDatasource();
  final _appointmentDatasource = SupabaseAppointmentDatasource();
  final _reviewDatasource = SupabaseReviewDatasource();

  BarberShopNotifier(this._ref) : super(const BarberShopInitial());

  Future<void> loadDashboard() async {
    state = const BarberShopLoading();
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final authState = _ref.read(authNotifierProvider);
      if (authState is! AuthAuthenticated) {
        state = const BarberShopError('Usuario nao autenticado.');
        return;
      }

      final shopId = authState.user.linkedId;
      if (shopId == null) {
        state = const BarberShopError('Barbearia nao vinculada ao perfil.');
        return;
      }

      final shops = _catalogDatasource.isConfigured
          ? await _catalogDatasource.loadBarbershops()
          : MockData.barbershops();
      final shopData = _shopById(shops, shopId);
      if (shopData == null) {
        state = const BarberShopError('Barbearia nao encontrada.');
        return;
      }

      final sourceAppointments = _appointmentDatasource.isConfigured
          ? await _appointmentDatasource.loadAppointments(shops)
          : MockData.seedAppointments(shops);
      final allAppts = sourceAppointments
          .where((a) => a.barbershop.id == shopData.id)
          .toList();

      final reviews = await _loadReviewsForShop(shopId, shopData.id, allAppts);
      final reviewCount = reviews.length;
      final rating = reviews.isEmpty
          ? 0.0
          : double.parse(
              (reviews.fold<int>(0, (sum, item) => sum + item.rating) /
                      reviews.length)
                  .toStringAsFixed(1),
            );

      final shop = BarberShopEntity(
        id: shopData.id,
        name: shopData.name,
        address: shopData.address,
        rating: rating,
        reviewCount: reviewCount,
        phone: shopData.phone ?? '',
        coverEmoji: shopData.coverEmoji,
      );

      final today = DateTime.now();
      final todayAppts = allAppts
          .where((a) =>
              a.date.year == today.year &&
              a.date.month == today.month &&
              a.date.day == today.day)
          .toList()
        ..sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

      final upcoming = allAppts
          .where((a) => a.status == AppointmentStatus.scheduled)
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      final completed =
          allAppts.where((a) => a.status == AppointmentStatus.completed);
      final totalRevenue = completed.fold(0.0, (s, a) => s + a.service.price);
      final monthRevenue = completed
          .where(
            (a) => a.date.month == today.month && a.date.year == today.year,
          )
          .fold(0.0, (s, a) => s + a.service.price);

      state = BarberShopLoaded(
        shop: shop,
        stats: BarberShopStats(
          totalAppointments: allAppts.length,
          todayAppointments: todayAppts.length,
          pendingAppointments: upcoming.length,
          completedAppointments: completed.length,
          totalRevenue: totalRevenue,
          monthRevenue: monthRevenue,
          averageRating: rating,
        ),
        todayAppointments: todayAppts,
        upcomingAppointments: upcoming,
        recentReviews: reviews.take(3).toList(),
      );
    } catch (e) {
      state = BarberShopError('Erro ao carregar dashboard: $e');
    }
  }

  Future<List<ReviewModel>> _loadReviewsForShop(
    String linkedShopId,
    String resolvedShopId,
    List<AppointmentModel> appointments,
  ) async {
    final acceptedIds = <String>{
      linkedShopId,
      resolvedShopId,
      _legacyShopId(linkedShopId),
      _legacyShopId(resolvedShopId),
    };

    if (_reviewDatasource.isConfigured) {
      final reviews = await _reviewDatasource.loadReviews();
      return reviews
          .where((item) => acceptedIds.contains(item.barbershopId))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final seeded = MockData.seedReviews(appointments);
    return seeded
        .where((item) => acceptedIds.contains(item.barbershopId))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  BarbershopModel? _shopById(List<BarbershopModel> shops, String shopId) {
    final exact = shops.where((s) => s.id == shopId).firstOrNull;
    if (exact != null) return exact;

    final legacyId = _legacyShopId(shopId);
    return shops.where((s) => s.id == legacyId).firstOrNull;
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
