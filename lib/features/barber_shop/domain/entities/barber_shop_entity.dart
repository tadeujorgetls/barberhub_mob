/// Entidade que representa uma barbearia gerenciada por um proprietário.
class BarberShopEntity {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int reviewCount;
  final String phone;
  final String coverEmoji;

  const BarberShopEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.phone,
    required this.coverEmoji,
  });
}

/// Estatísticas do dashboard de uma barbearia.
class BarberShopStats {
  final int totalAppointments;
  final int todayAppointments;
  final int pendingAppointments;
  final int completedAppointments;
  final double totalRevenue;
  final double monthRevenue;
  final double averageRating;

  const BarberShopStats({
    this.totalAppointments = 0,
    this.todayAppointments = 0,
    this.pendingAppointments = 0,
    this.completedAppointments = 0,
    this.totalRevenue = 0,
    this.monthRevenue = 0,
    this.averageRating = 0,
  });
}
