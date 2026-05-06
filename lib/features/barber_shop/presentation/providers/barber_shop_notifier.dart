import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_hub/features/auth/presentation/providers/auth_providers.dart';
import 'package:barber_hub/features/barber_shop/domain/entities/barber_shop_entity.dart';
import 'package:barber_hub/features/client/data/models/appointment_model.dart';
import 'package:barber_hub/shared/mock/mock_data.dart';
import 'barber_shop_state.dart';

class BarberShopNotifier extends StateNotifier<BarberShopState> {
  final Ref _ref;
  BarberShopNotifier(this._ref) : super(const BarberShopInitial());

  Future<void> loadDashboard() async {
    state = const BarberShopLoading();
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final authState = _ref.read(authNotifierProvider);
      if (authState is! AuthAuthenticated) {
        state = const BarberShopError('Usuário não autenticado.');
        return;
      }

      final shopId = authState.user.linkedId;
      if (shopId == null) {
        state = const BarberShopError('Barbearia não vinculada ao perfil.');
        return;
      }

      final shops = MockData.barbershops();
      final shopData = shops.where((s) => s.id == shopId).firstOrNull;
      if (shopData == null) {
        state = const BarberShopError('Barbearia não encontrada.');
        return;
      }

      final shop = BarberShopEntity(
        id: shopData.id,
        name: shopData.name,
        address: shopData.address,
        rating: shopData.rating,
        reviewCount: shopData.reviewCount,
        phone: shopData.phone ?? '',
        coverEmoji: shopData.coverEmoji,
      );

      final allAppts = MockData.seedAppointments(shops)
          .where((a) => a.barbershop.id == shopId)
          .toList();

      final today = DateTime.now();
      final todayAppts = allAppts.where((a) =>
          a.date.year == today.year &&
          a.date.month == today.month &&
          a.date.day == today.day).toList()
        ..sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

      final upcoming = allAppts
          .where((a) => a.status == AppointmentStatus.scheduled)
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      final completed = allAppts.where((a) => a.status == AppointmentStatus.completed);
      final totalRevenue = completed.fold(0.0, (s, a) => s + a.service.price);
      final monthRevenue = completed
          .where((a) => a.date.month == today.month && a.date.year == today.year)
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
          averageRating: shopData.rating,
        ),
        todayAppointments: todayAppts,
        upcomingAppointments: upcoming,
      );
    } catch (e) {
      state = BarberShopError('Erro ao carregar dashboard: $e');
    }
  }
}
