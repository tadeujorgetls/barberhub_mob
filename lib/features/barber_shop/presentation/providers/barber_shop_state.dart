import 'package:barber_hub/features/barber_shop/domain/entities/barber_shop_entity.dart';
import 'package:barber_hub/models/appointment_model.dart';

sealed class BarberShopState {
  const BarberShopState();
}

final class BarberShopInitial extends BarberShopState {
  const BarberShopInitial();
}

final class BarberShopLoading extends BarberShopState {
  const BarberShopLoading();
}

final class BarberShopLoaded extends BarberShopState {
  final BarberShopEntity shop;
  final BarberShopStats stats;
  final List<AppointmentModel> todayAppointments;
  final List<AppointmentModel> upcomingAppointments;
  final List<ReviewModel> recentReviews;

  const BarberShopLoaded({
    required this.shop,
    required this.stats,
    required this.todayAppointments,
    required this.upcomingAppointments,
    required this.recentReviews,
  });
}

final class BarberShopError extends BarberShopState {
  final String message;
  const BarberShopError(this.message);
}
