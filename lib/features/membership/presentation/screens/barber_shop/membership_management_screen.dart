import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_hub/core/theme/app_theme.dart';
import 'package:barber_hub/features/auth/presentation/providers/auth_providers.dart';
import 'package:barber_hub/features/membership/domain/entities/membership_entity.dart';
import 'package:barber_hub/features/membership/domain/entities/membership_plan_entity.dart';
import 'package:barber_hub/features/membership/presentation/providers/membership_providers.dart';
import 'package:barber_hub/features/membership/presentation/widgets/membership_widgets.dart';
import 'package:barber_hub/features/barber_shop/presentation/widgets/bs_widgets.dart';

/// Painel de gestão de assinaturas para o proprietário da barbearia.
class MembershipManagementScreen extends ConsumerStatefulWidget {
  const MembershipManagementScreen({super.key});

  @override
  ConsumerState<MembershipManagementScreen> createState() => _State();
}

class _State extends ConsumerState<MembershipManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  void _load() {
    final authState = ref.read(authNotifierProvider);
    if (authState is AuthAuthenticated) {
      final shopId = authState.user.linkedId;
      if (shopId != null) {
        ref.read(shopMembershipProvider.notifier).load(shopId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shopMembershipProvider);
    final authState = ref.watch(authNotifierProvider);
    final shopId =
        authState is AuthAuthenticated ? authState.user.linkedId : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.textSecondary, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium_rounded,
                                color: AppTheme.gold, size: 11),
                            const SizedBox(width: 5),
                            Text(
                              'MEMBERSHIPS',
                              style: GoogleFonts.jost(
                                  color: AppTheme.gold,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Assinaturas',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 28),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Stats Row ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  MembershipStatCard(
                    label: 'Assinantes',
                    value: '${state.activeSubscriberCount}',
                    icon: Icons.people_outline_rounded,
                    valueColor: AppTheme.gold,
                  ),
                  const SizedBox(width: 10),
                  MembershipStatCard(
                    label: 'Receita mensal',
                    value: 'R\$ ${state.monthlyRevenue.toStringAsFixed(0)}',
                    icon: Icons.attach_money_rounded,
                    valueColor: Colors.green,
                  ),
                  const SizedBox(width: 10),
                  MembershipStatCard(
                    label: 'Planos ativos',
                    value: '${state.plans.where((p) => p.isActive).length}',
                    icon: Icons.layers_outlined,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Tab Bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.inputBorder),
                ),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: AppTheme.gold,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: GoogleFonts.jost(
                      fontSize: 12, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: GoogleFonts.jost(
                      fontSize: 12, fontWeight: FontWeight.w400),
                  labelColor: AppTheme.background,
                  unselectedLabelColor: AppTheme.textSecondary,
                  tabs: const [
                    Tab(text: 'Assinantes'),
                    Tab(text: 'Planos'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Tab Content ──────────────────────────────────────────────
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.gold))
                  : TabBarView(
                      controller: _tab,
                      children: [
                        _SubscribersTab(
                          subscribers: state.subscribers,
                          onRegisterCut: shopId == null
                              ? null
                              : (id) => ref
                                  .read(shopMembershipProvider.notifier)
                                  .registerCutUsage(id),
                        ),
                        _PlansTab(
                          plans: state.plans,
                          isSaving: state.isSaving,
                          onToggle: shopId == null
                              ? null
                              : (planId) => ref
                                  .read(shopMembershipProvider.notifier)
                                  .togglePlan(shopId, planId),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab: Assinantes ───────────────────────────────────────────────────────────

class _SubscribersTab extends StatelessWidget {
  final List<MembershipEntity> subscribers;
  final void Function(String membershipId)? onRegisterCut;

  const _SubscribersTab({
    required this.subscribers,
    this.onRegisterCut,
  });

  @override
  Widget build(BuildContext context) {
    final active = subscribers
        .where((s) => s.status == MembershipStatus.active)
        .toList()
      ..sort((a, b) => b.plan.tier.sortOrder.compareTo(a.plan.tier.sortOrder));

    if (active.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline_rounded,
                color: AppTheme.textHint, size: 48),
            const SizedBox(height: 12),
            Text(
              'Nenhum assinante ainda.',
              style: GoogleFonts.jost(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      itemCount: active.length,
      separatorBuilder: (_, __) =>
          Container(height: 1, color: AppTheme.divider),
      itemBuilder: (_, i) => _SubscriberTile(
        membership: active[i],
        onRegisterCut:
            onRegisterCut == null ? null : () => onRegisterCut!(active[i].id),
      ),
    );
  }
}

class _SubscriberTile extends StatelessWidget {
  final MembershipEntity membership;
  final VoidCallback? onRegisterCut;

  const _SubscriberTile({
    required this.membership,
    this.onRegisterCut,
  });

  @override
  Widget build(BuildContext context) {
    final plan = membership.plan;
    final color = plan.tier.accentColor;
    final initials = membership.clientName
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.jost(
                    color: color, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  membership.clientName,
                  style: GoogleFonts.jost(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                Row(
                  children: [
                    Icon(plan.tier.icon, color: color, size: 11),
                    const SizedBox(width: 4),
                    Text(
                      'Plano ${plan.name}',
                      style: GoogleFonts.jost(color: color, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${membership.cutsUsedThisMonth} corte${membership.cutsUsedThisMonth != 1 ? 's' : ''} este mês',
                      style: GoogleFonts.jost(
                          color: AppTheme.textHint, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Registrar corte
          if (membership.hasCutsAvailable && onRegisterCut != null)
            GestureDetector(
              onTap: onRegisterCut,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.content_cut_rounded, color: color, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '+Corte',
                      style: GoogleFonts.jost(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Tab: Planos ───────────────────────────────────────────────────────────────

class _PlansTab extends StatelessWidget {
  final List<MembershipPlanEntity> plans;
  final bool isSaving;
  final void Function(String planId)? onToggle;

  const _PlansTab({
    required this.plans,
    required this.isSaving,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return Center(
        child: Text(
          'Nenhum plano configurado.',
          style: GoogleFonts.jost(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      itemCount: plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => BsCard(
        highlight: plans[i].isActive,
        child: Row(
          children: [
            Icon(plans[i].tier.icon,
                color: plans[i].tier.accentColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plans[i].name,
                    style: GoogleFonts.jost(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                  Text(
                    '${plans[i].formattedPrice}/mês · ${plans[i].cutsLabel}',
                    style: GoogleFonts.jost(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Switch(
              value: plans[i].isActive,
              onChanged: isSaving || onToggle == null
                  ? null
                  : (_) => onToggle!(plans[i].id),
              activeThumbColor: plans[i].tier.accentColor,
              inactiveTrackColor: AppTheme.inputBorder,
            ),
          ],
        ),
      ),
    );
  }
}
