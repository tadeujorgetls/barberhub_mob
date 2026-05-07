import 'package:barber_hub/features/membership/domain/entities/membership_entity.dart';
import 'package:barber_hub/features/membership/domain/entities/membership_plan_entity.dart';

/// Datasource mock de assinaturas.
/// Dados em memória — substituir por chamadas HTTP em produção.
class MembershipMockDatasource {
  // ── Planos seed ────────────────────────────────────────────────────────────
  // Cada barbearia tem 3 planos: Basic, Premium, VIP.
  // Preços e benefícios customizáveis por shop.

  static final Map<String, List<MembershipPlanEntity>> _plans = {
    'bs1': _plansFor('bs1', 49.90, 89.90, 129.90),
    'bs2': _plansFor('bs2', 44.90, 79.90, 119.90),
    'bs3': _plansFor('bs3', 54.90, 99.90, 149.90),
  };

  static List<MembershipPlanEntity> _plansFor(
    String shopId,
    double basicPrice,
    double premiumPrice,
    double vipPrice,
  ) =>
      [
        MembershipPlanEntity(
          id: '${shopId}_plan_basic',
          barbershopId: shopId,
          tier: MembershipTier.basic,
          name: 'Basic',
          priceMonthly: basicPrice,
          cutsPerMonth: 2,
          includesBeard: false,
          priorityBooking: false,
          benefits: [
            '2 cortes por mês incluídos',
            '10% de desconto em produtos',
            'Agendamento facilitado pelo app',
            'Histórico completo de visitas',
          ],
        ),
        MembershipPlanEntity(
          id: '${shopId}_plan_premium',
          barbershopId: shopId,
          tier: MembershipTier.premium,
          name: 'Premium',
          priceMonthly: premiumPrice,
          cutsPerMonth: null, // ilimitado
          includesBeard: true,
          priorityBooking: false,
          benefits: [
            'Cortes ilimitados no mês',
            'Barba incluída sem custo extra',
            '20% de desconto em produtos',
            'Agendamento facilitado pelo app',
            'Notificação antecipada de horários',
          ],
        ),
        MembershipPlanEntity(
          id: '${shopId}_plan_vip',
          barbershopId: shopId,
          tier: MembershipTier.vip,
          name: 'VIP',
          priceMonthly: vipPrice,
          cutsPerMonth: null, // ilimitado
          includesBeard: true,
          priorityBooking: true,
          benefits: [
            'Cortes + Barba ilimitados',
            'Prioridade no agendamento',
            '30% de desconto em produtos',
            'Atendimento exclusivo sem fila',
            'Brinde mensal surpresa',
            'Acesso antecipado a novidades',
          ],
        ),
      ];

  // ── Assinaturas seed ──────────────────────────────────────────────────────
  static final List<MembershipEntity> _memberships = [
    MembershipEntity(
      id: 'mem_001',
      clientId: 'u1',
      clientName: 'Carlos Oliveira',
      barbershopId: 'bs1',
      barbershopName: 'Barbearia Clássica',
      plan: _plans['bs1']![0], // Basic
      status: MembershipStatus.active,
      startDate: DateTime.now().subtract(const Duration(days: 45)),
      nextBillingDate: DateTime.now().add(const Duration(days: 15)),
      cutsUsedThisMonth: 1,
      renewalCount: 1,
    ),
  ];

  // ── Métodos ───────────────────────────────────────────────────────────────

  Future<List<MembershipPlanEntity>> getPlansForShop(String shopId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_plans[shopId] ?? []);
  }

  Future<void> updatePlan(MembershipPlanEntity plan) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final shopPlans = _plans[plan.barbershopId];
    if (shopPlans == null) return;
    final idx = shopPlans.indexWhere((p) => p.id == plan.id);
    if (idx != -1) shopPlans[idx] = plan;
  }

  Future<List<MembershipEntity>> getClientMemberships(String clientId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _memberships.where((m) => m.clientId == clientId).toList();
  }

  Future<List<MembershipEntity>> getShopMemberships(String shopId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _memberships.where((m) => m.barbershopId == shopId).toList();
  }

  Future<MembershipEntity> subscribe({
    required String clientId,
    required String clientName,
    required String shopId,
    required String planId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final shopPlans = _plans[shopId] ?? [];
    final plan = shopPlans.firstWhere((p) => p.id == planId);

    final now = DateTime.now();
    final membership = MembershipEntity(
      id: 'mem_${DateTime.now().millisecondsSinceEpoch}',
      clientId: clientId,
      clientName: clientName,
      barbershopId: shopId,
      barbershopName: _shopName(shopId),
      plan: plan,
      status: MembershipStatus.active,
      startDate: now,
      nextBillingDate: DateTime(now.year, now.month + 1, now.day),
      cutsUsedThisMonth: 0,
      renewalCount: 0,
    );
    _memberships.add(membership);
    return membership;
  }

  Future<void> cancelMembership(String membershipId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _memberships.indexWhere((m) => m.id == membershipId);
    if (idx != -1) {
      _memberships[idx] =
          _memberships[idx].copyWith(status: MembershipStatus.cancelled);
    }
  }

  Future<void> pauseMembership(String membershipId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _memberships.indexWhere((m) => m.id == membershipId);
    if (idx != -1) {
      _memberships[idx] =
          _memberships[idx].copyWith(status: MembershipStatus.paused);
    }
  }

  Future<void> resumeMembership(String membershipId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final idx = _memberships.indexWhere((m) => m.id == membershipId);
    if (idx != -1) {
      _memberships[idx] =
          _memberships[idx].copyWith(status: MembershipStatus.active);
    }
  }

  Future<MembershipEntity> useCut(String membershipId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _memberships.indexWhere((m) => m.id == membershipId);
    if (idx == -1) throw Exception('Assinatura não encontrada');
    final updated = _memberships[idx].copyWith(
      cutsUsedThisMonth: _memberships[idx].cutsUsedThisMonth + 1,
    );
    _memberships[idx] = updated;
    return updated;
  }

  String _shopName(String shopId) {
    const names = {
      'bs1': 'Barbearia Clássica',
      'bs2': 'Studio Urbano',
      'bs3': 'Dom Navalha',
    };
    return names[shopId] ?? shopId;
  }
}
