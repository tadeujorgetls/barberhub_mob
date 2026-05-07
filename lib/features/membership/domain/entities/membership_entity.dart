import 'membership_plan_entity.dart';

/// Status de uma assinatura ativa.
enum MembershipStatus { active, paused, cancelled, expired }

extension MembershipStatusExt on MembershipStatus {
  String get label {
    switch (this) {
      case MembershipStatus.active:    return 'Ativa';
      case MembershipStatus.paused:    return 'Pausada';
      case MembershipStatus.cancelled: return 'Cancelada';
      case MembershipStatus.expired:   return 'Expirada';
    }
  }

  bool get isUsable => this == MembershipStatus.active;
}

/// Assinatura de um cliente em uma barbearia.
/// Representa o vínculo entre cliente, plano e barbearia.
class MembershipEntity {
  final String id;
  final String clientId;
  final String clientName;
  final String barbershopId;
  final String barbershopName;
  final MembershipPlanEntity plan;
  final MembershipStatus status;
  final DateTime startDate;

  /// Próxima data de cobrança recorrente.
  final DateTime nextBillingDate;

  /// Número de cortes usados no mês corrente.
  final int cutsUsedThisMonth;

  /// Quantas vezes a assinatura foi renovada (ciclos completos).
  final int renewalCount;

  const MembershipEntity({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.barbershopId,
    required this.barbershopName,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.nextBillingDate,
    this.cutsUsedThisMonth = 0,
    this.renewalCount = 0,
  });

  // ── Helpers de negócio ────────────────────────────────────────────────────

  /// Se ainda há cortes disponíveis no mês.
  bool get hasCutsAvailable {
    if (plan.cutsPerMonth == null) return true; // ilimitado
    return cutsUsedThisMonth < plan.cutsPerMonth!;
  }

  /// Cortes restantes no mês. null = ilimitado.
  int? get cutsRemaining {
    if (plan.cutsPerMonth == null) return null;
    final rem = plan.cutsPerMonth! - cutsUsedThisMonth;
    return rem < 0 ? 0 : rem;
  }

  String get cutsRemainingLabel {
    final rem = cutsRemaining;
    if (rem == null) return 'Ilimitados';
    return '$rem restante${rem == 1 ? '' : 's'}';
  }

  /// Dias até a próxima cobrança.
  int get daysUntilBilling =>
      nextBillingDate.difference(DateTime.now()).inDays.clamp(0, 999);

  MembershipEntity copyWith({
    String? id, String? clientId, String? clientName,
    String? barbershopId, String? barbershopName,
    MembershipPlanEntity? plan, MembershipStatus? status,
    DateTime? startDate, DateTime? nextBillingDate,
    int? cutsUsedThisMonth, int? renewalCount,
  }) =>
      MembershipEntity(
        id: id ?? this.id,
        clientId: clientId ?? this.clientId,
        clientName: clientName ?? this.clientName,
        barbershopId: barbershopId ?? this.barbershopId,
        barbershopName: barbershopName ?? this.barbershopName,
        plan: plan ?? this.plan,
        status: status ?? this.status,
        startDate: startDate ?? this.startDate,
        nextBillingDate: nextBillingDate ?? this.nextBillingDate,
        cutsUsedThisMonth: cutsUsedThisMonth ?? this.cutsUsedThisMonth,
        renewalCount: renewalCount ?? this.renewalCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is MembershipEntity && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
