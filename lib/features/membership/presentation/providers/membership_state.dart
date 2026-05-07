import 'package:barber_hub/features/membership/domain/entities/membership_entity.dart';
import 'package:barber_hub/features/membership/domain/entities/membership_plan_entity.dart';

// ── Estado do cliente ─────────────────────────────────────────────────────────

/// Estado do módulo de assinaturas na perspectiva do cliente.
class ClientMembershipState {
  final bool isLoading;
  final bool isSubscribing;
  final List<MembershipEntity> memberships;
  final List<MembershipPlanEntity> availablePlans;
  final String? error;
  final String? successMessage;

  const ClientMembershipState({
    this.isLoading = false,
    this.isSubscribing = false,
    this.memberships = const [],
    this.availablePlans = const [],
    this.error,
    this.successMessage,
  });

  bool get hasActiveMembership =>
      memberships.any((m) => m.status == MembershipStatus.active);

  MembershipEntity? activeForShop(String shopId) => memberships
      .where((m) =>
          m.barbershopId == shopId && m.status == MembershipStatus.active)
      .firstOrNull;

  ClientMembershipState copyWith({
    bool? isLoading,
    bool? isSubscribing,
    List<MembershipEntity>? memberships,
    List<MembershipPlanEntity>? availablePlans,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) =>
      ClientMembershipState(
        isLoading: isLoading ?? this.isLoading,
        isSubscribing: isSubscribing ?? this.isSubscribing,
        memberships: memberships ?? this.memberships,
        availablePlans: availablePlans ?? this.availablePlans,
        error: clearError ? null : (error ?? this.error),
        successMessage:
            clearSuccess ? null : (successMessage ?? this.successMessage),
      );
}

// ── Estado da barbearia ───────────────────────────────────────────────────────

/// Estado do módulo de assinaturas na perspectiva da barbearia.
class ShopMembershipState {
  final bool isLoading;
  final bool isSaving;
  final List<MembershipPlanEntity> plans;
  final List<MembershipEntity> subscribers;
  final String? error;

  const ShopMembershipState({
    this.isLoading = false,
    this.isSaving = false,
    this.plans = const [],
    this.subscribers = const [],
    this.error,
  });

  int get activeSubscriberCount =>
      subscribers.where((s) => s.status == MembershipStatus.active).length;

  double get monthlyRevenue => subscribers
      .where((s) => s.status == MembershipStatus.active)
      .fold(0.0, (sum, s) => sum + s.plan.priceMonthly);

  ShopMembershipState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<MembershipPlanEntity>? plans,
    List<MembershipEntity>? subscribers,
    String? error,
    bool clearError = false,
  }) =>
      ShopMembershipState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        plans: plans ?? this.plans,
        subscribers: subscribers ?? this.subscribers,
        error: clearError ? null : (error ?? this.error),
      );
}
