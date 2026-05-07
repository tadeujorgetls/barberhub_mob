import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_hub/core/theme/app_theme.dart';
import 'package:barber_hub/features/membership/domain/entities/membership_entity.dart';
import 'package:barber_hub/features/membership/domain/entities/membership_plan_entity.dart';

// ── Plan Card ─────────────────────────────────────────────────────────────────

/// Card de exibição de um plano — usado na tela de seleção.
class MembershipPlanCard extends StatelessWidget {
  final MembershipPlanEntity plan;
  final bool isSelected;
  final bool isCurrentPlan;
  final VoidCallback? onTap;

  const MembershipPlanCard({
    super.key,
    required this.plan,
    this.isSelected = false,
    this.isCurrentPlan = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = plan.tier.accentColor;
    final isPremium = plan.tier == MembershipTier.premium;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : (isPremium
                    ? color.withOpacity(0.3)
                    : AppTheme.inputBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.4)),
                    ),
                    child: Icon(plan.tier.icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              plan.name,
                              style: GoogleFonts.jost(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            if (isPremium) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'POPULAR',
                                  style: GoogleFonts.jost(
                                      color: color,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5),
                                ),
                              ),
                            ],
                            if (isCurrentPlan) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'ATUAL',
                                  style: GoogleFonts.jost(
                                      color: Colors.green,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plan.tier.tagline,
                          style: GoogleFonts.jost(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.formattedPrice,
                        style: GoogleFonts.jost(
                          color: color,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '/mês',
                        style: GoogleFonts.jost(
                            color: AppTheme.textHint, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ── Benefits ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: plan.benefits
                    .map((b) => _BenefitRow(text: b, color: color))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;
  final Color color;
  const _BenefitRow({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(Icons.check_rounded, color: color, size: 14),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.jost(
                    color: AppTheme.textSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
      );
}

// ── Active Membership Card ─────────────────────────────────────────────────────

/// Card compacto de assinatura ativa — usado em "Minhas Assinaturas".
class ActiveMembershipCard extends StatelessWidget {
  final MembershipEntity membership;
  final VoidCallback? onTap;

  const ActiveMembershipCard({
    super.key,
    required this.membership,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final plan = membership.plan;
    final color = plan.tier.accentColor;
    final isActive = membership.status == MembershipStatus.active;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color.withOpacity(0.4) : AppTheme.inputBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(plan.tier.icon, color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        membership.barbershopName,
                        style: GoogleFonts.jost(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Plano ${plan.name}',
                        style: GoogleFonts.jost(
                            color: color, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                MembershipStatusBadge(status: membership.status),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 1,
              color: AppTheme.divider,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  label: 'Cortes',
                  value: membership.cutsRemainingLabel,
                  icon: Icons.content_cut_rounded,
                  color: color,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  label: 'Próx. cobrança',
                  value: '${membership.daysUntilBilling}d',
                  icon: Icons.calendar_today_rounded,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  label: 'Valor',
                  value: plan.formattedPrice,
                  icon: Icons.attach_money_rounded,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.jost(
                  color: AppTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: GoogleFonts.jost(
                    color: AppTheme.textHint, fontSize: 9),
              ),
            ],
          ),
        ),
      );
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class MembershipStatusBadge extends StatelessWidget {
  final MembershipStatus status;
  const MembershipStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      MembershipStatus.active    => (Colors.green, Colors.green.withOpacity(0.12)),
      MembershipStatus.paused    => (AppTheme.gold, AppTheme.gold.withOpacity(0.12)),
      MembershipStatus.cancelled => (AppTheme.error, AppTheme.error.withOpacity(0.12)),
      MembershipStatus.expired   => (AppTheme.textHint, AppTheme.inputBorder),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: GoogleFonts.jost(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ── Stats Card (Barbearia) ────────────────────────────────────────────────────

class MembershipStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const MembershipStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.inputBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.textHint, size: 16),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.jost(
                  color: valueColor ?? AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.jost(
                    color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      );
}
