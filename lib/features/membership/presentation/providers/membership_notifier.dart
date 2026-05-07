import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_hub/features/membership/domain/entities/membership_entity.dart';
import 'package:barber_hub/features/membership/domain/entities/membership_plan_entity.dart';
import 'package:barber_hub/features/membership/domain/repositories/i_membership_repository.dart';
import 'membership_state.dart';

// ── Notifier do cliente ────────────────────────────────────────────────────────

class ClientMembershipNotifier extends StateNotifier<ClientMembershipState> {
  final IMembershipRepository _repo;
  ClientMembershipNotifier(this._repo) : super(const ClientMembershipState());

  /// Carrega as assinaturas do cliente e os planos de uma barbearia específica.
  Future<void> load({required String clientId, String? shopId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final (memberships, failure) = await _repo.getClientMemberships(clientId);
      if (failure != null) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return;
      }

      List<MembershipPlanEntity> plans = [];
      if (shopId != null) {
        final (p, _) = await _repo.getPlansForShop(shopId);
        plans = p;
      }

      state = state.copyWith(
        isLoading: false,
        memberships: memberships,
        availablePlans: plans,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Carrega planos disponíveis para uma barbearia.
  Future<void> loadPlansForShop(String shopId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final (plans, failure) = await _repo.getPlansForShop(shopId);
    state = state.copyWith(
      isLoading: false,
      availablePlans: plans,
      error: failure?.message,
    );
  }

  /// Assina um plano.
  Future<bool> subscribe({
    required String clientId,
    required String clientName,
    required String shopId,
    required String planId,
  }) async {
    state = state.copyWith(isSubscribing: true, clearError: true);
    final (membership, failure) = await _repo.subscribe(
      clientId: clientId,
      clientName: clientName,
      shopId: shopId,
      planId: planId,
    );

    if (failure != null || membership == null) {
      state = state.copyWith(
          isSubscribing: false, error: failure?.message ?? 'Erro desconhecido');
      return false;
    }

    state = state.copyWith(
      isSubscribing: false,
      memberships: [...state.memberships, membership],
      successMessage: 'Assinatura ativada com sucesso!',
    );
    return true;
  }

  /// Cancela uma assinatura.
  Future<void> cancel(String membershipId) async {
    state = state.copyWith(isLoading: true);
    final failure = await _repo.cancelMembership(membershipId);
    if (failure != null) {
      state = state.copyWith(isLoading: false, error: failure.message);
      return;
    }
    state = state.copyWith(
      isLoading: false,
      memberships: state.memberships
          .map((m) => m.id == membershipId
              ? m.copyWith(status: MembershipStatus.cancelled)
              : m)
          .toList(),
      successMessage: 'Assinatura cancelada.',
    );
  }

  /// Pausa uma assinatura.
  Future<void> pause(String membershipId) async {
    final failure = await _repo.pauseMembership(membershipId);
    if (failure != null) {
      state = state.copyWith(error: failure.message);
      return;
    }
    state = state.copyWith(
      memberships: state.memberships
          .map((m) => m.id == membershipId
              ? m.copyWith(status: MembershipStatus.paused)
              : m)
          .toList(),
      successMessage: 'Assinatura pausada.',
    );
  }

  /// Reativa uma assinatura pausada.
  Future<void> resume(String membershipId) async {
    final failure = await _repo.resumeMembership(membershipId);
    if (failure != null) {
      state = state.copyWith(error: failure.message);
      return;
    }
    state = state.copyWith(
      memberships: state.memberships
          .map((m) => m.id == membershipId
              ? m.copyWith(status: MembershipStatus.active)
              : m)
          .toList(),
      successMessage: 'Assinatura reativada!',
    );
  }

  void clearMessages() =>
      state = state.copyWith(clearError: true, clearSuccess: true);
}

// ── Notifier da barbearia ─────────────────────────────────────────────────────

class ShopMembershipNotifier extends StateNotifier<ShopMembershipState> {
  final IMembershipRepository _repo;
  ShopMembershipNotifier(this._repo) : super(const ShopMembershipState());

  /// Carrega planos e assinantes da barbearia.
  Future<void> load(String shopId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final (plans, plansFailure) = await _repo.getPlansForShop(shopId);
      final (subscribers, subsFailure) = await _repo.getShopMemberships(shopId);

      if (plansFailure != null || subsFailure != null) {
        state = state.copyWith(
          isLoading: false,
          error: plansFailure?.message ?? subsFailure?.message,
        );
        return;
      }
      state = state.copyWith(
        isLoading: false,
        plans: plans,
        subscribers: subscribers,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Ativa ou desativa um plano.
  Future<void> togglePlan(String shopId, String planId) async {
    final plan = state.plans.firstWhere((p) => p.id == planId);
    final updated = plan.copyWith(isActive: !plan.isActive);
    state = state.copyWith(isSaving: true);
    final failure = await _repo.updatePlan(updated);
    if (failure != null) {
      state = state.copyWith(isSaving: false, error: failure.message);
      return;
    }
    state = state.copyWith(
      isSaving: false,
      plans: state.plans.map((p) => p.id == planId ? updated : p).toList(),
    );
  }

  /// Registra uso de corte por um assinante (feito pelo barbeiro).
  Future<void> registerCutUsage(String membershipId) async {
    final (updated, failure) = await _repo.useCut(membershipId);
    if (failure != null) {
      state = state.copyWith(error: failure.message);
      return;
    }
    state = state.copyWith(
      subscribers: state.subscribers
          .map((s) => s.id == membershipId ? updated! : s)
          .toList(),
    );
  }
}
