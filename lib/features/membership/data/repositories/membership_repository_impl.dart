import 'package:barber_hub/core/errors/failures.dart';
import 'package:barber_hub/features/membership/data/datasources/membership_mock_datasource.dart';
import 'package:barber_hub/features/membership/domain/entities/membership_entity.dart';
import 'package:barber_hub/features/membership/domain/entities/membership_plan_entity.dart';
import 'package:barber_hub/features/membership/domain/repositories/i_membership_repository.dart';

class MembershipRepositoryImpl implements IMembershipRepository {
  final MembershipMockDatasource _datasource;
  const MembershipRepositoryImpl(this._datasource);

  @override
  Future<(List<MembershipPlanEntity>, Failure?)> getPlansForShop(
      String shopId) async {
    try {
      final plans = await _datasource.getPlansForShop(shopId);
      return (plans, null);
    } catch (e) {
      return (
        <MembershipPlanEntity>[],
        const UnknownFailure('Erro ao carregar planos.')
      );
    }
  }

  @override
  Future<Failure?> updatePlan(MembershipPlanEntity plan) async {
    try {
      await _datasource.updatePlan(plan);
      return null;
    } catch (e) {
      return const UnknownFailure('Erro ao atualizar plano.');
    }
  }

  @override
  Future<(List<MembershipEntity>, Failure?)> getClientMemberships(
      String clientId) async {
    try {
      final memberships = await _datasource.getClientMemberships(clientId);
      return (memberships, null);
    } catch (e) {
      return (
        <MembershipEntity>[],
        const UnknownFailure('Erro ao carregar assinaturas.')
      );
    }
  }

  @override
  Future<(List<MembershipEntity>, Failure?)> getShopMemberships(
      String shopId) async {
    try {
      final memberships = await _datasource.getShopMemberships(shopId);
      return (memberships, null);
    } catch (e) {
      return (
        <MembershipEntity>[],
        const UnknownFailure('Erro ao carregar assinantes.')
      );
    }
  }

  @override
  Future<(MembershipEntity?, Failure?)> subscribe({
    required String clientId,
    required String clientName,
    required String shopId,
    required String planId,
  }) async {
    try {
      final membership = await _datasource.subscribe(
        clientId: clientId,
        clientName: clientName,
        shopId: shopId,
        planId: planId,
      );
      return (membership, null);
    } catch (e) {
      return (null, const UnknownFailure('Erro ao realizar assinatura.'));
    }
  }

  @override
  Future<Failure?> cancelMembership(String membershipId) async {
    try {
      await _datasource.cancelMembership(membershipId);
      return null;
    } catch (e) {
      return const UnknownFailure('Erro ao cancelar assinatura.');
    }
  }

  @override
  Future<Failure?> pauseMembership(String membershipId) async {
    try {
      await _datasource.pauseMembership(membershipId);
      return null;
    } catch (e) {
      return const UnknownFailure('Erro ao pausar assinatura.');
    }
  }

  @override
  Future<Failure?> resumeMembership(String membershipId) async {
    try {
      await _datasource.resumeMembership(membershipId);
      return null;
    } catch (e) {
      return const UnknownFailure('Erro ao reativar assinatura.');
    }
  }

  @override
  Future<(MembershipEntity?, Failure?)> useCut(String membershipId) async {
    try {
      final updated = await _datasource.useCut(membershipId);
      return (updated, null);
    } catch (e) {
      return (null, const UnknownFailure('Erro ao registrar uso.'));
    }
  }
}
