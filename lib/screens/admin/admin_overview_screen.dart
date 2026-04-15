import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_data_provider.dart';
import '../../models/appointment_model.dart';
import '../../models/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/app_widgets.dart';

class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = context.watch<AppDataProvider>();
    final all = data.allAppointmentsSorted;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.gold.withOpacity(.05),
                  Colors.transparent
                ]),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── Header ───────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Row(children: [
                      const BarberLogo(size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text('ADMINISTRADOR',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                        color: AppTheme.gold,
                                        fontSize: 9,
                                        letterSpacing: 3)),
                            Text('Barber Hub',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontSize: 16)),
                          ])),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded,
                            color: AppTheme.textSecondary, size: 20),
                        onPressed: () {
                          auth.logout();
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.login);
                        },
                      ),
                    ]),
                  ),
                ),

                // ── Title ────────────────────────────────────────────────
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: ScreenHeader(
                        eyebrow: 'VISÃO GERAL', title: 'Dashboard'),
                  ),
                ),

                // ── Global stats ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(title: 'Resumo global'),
                          const SizedBox(height: 14),
                          Row(children: [
                            StatCard(
                                value: '${all.length}',
                                label: 'Total',
                                icon: Icons.calendar_month_outlined),
                            const SizedBox(width: 10),
                            StatCard(
                                value: '${data.scheduledCount}',
                                label: 'Pendentes',
                                icon: Icons.pending_outlined),
                            const SizedBox(width: 10),
                            StatCard(
                                value: '${data.completedCount}',
                                label: 'Concluídos',
                                icon: Icons.check_circle_outline),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            StatCard(
                              value: 'R\$ ${data.totalRevenue}',
                              label: 'Receita total',
                              icon: Icons.attach_money_rounded,
                              valueColor: const Color(0xFF4CAF50),
                            ),
                            const SizedBox(width: 10),
                            StatCard(
                                value: '${data.barbershops.length}',
                                label: 'Barbearias',
                                icon: Icons.storefront_outlined),
                            const SizedBox(width: 10),
                            StatCard(
                                value: '${data.services.length}',
                                label: 'Serviços',
                                icon: Icons.spa_outlined),
                          ]),
                        ]),
                  ),
                ),

                // ── Por barbearia ─────────────────────────────────────────
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 28, 24, 14),
                    child: SectionHeader(title: 'Por barbearia'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 130,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: data.barbershops.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final shop = data.barbershops[i];
                        final shopAppts = data.appointmentsForShop(shop.id);
                        final shopRevenue = shopAppts
                            .where(
                                (a) => a.status == AppointmentStatus.completed)
                            .fold(0.0, (s, a) => s + a.service.price);
                        final pending = shopAppts
                            .where(
                                (a) => a.status == AppointmentStatus.scheduled)
                            .length;
                        return _ShopStatCard(
                          emoji: shop.coverEmoji,
                          name: shop.name,
                          total: shopAppts.length,
                          pending: pending,
                          revenue: shopRevenue.toInt(),
                        );
                      },
                    ),
                  ),
                ),

                // ── Distribuição de status ────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: _StatusBreakdown(appointments: all),
                  ),
                ),

                // ── Todos os agendamentos ────────────────────────────────
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 12),
                    child: SectionHeader(title: 'Todos os agendamentos'),
                  ),
                ),

                if (all.isEmpty)
                  const SliverToBoxAdapter(
                    child: EmptyState(
                      icon: Icons.calendar_today_outlined,
                      title: 'Sem agendamentos',
                      subtitle: 'Os agendamentos realizados aparecerão aqui.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppointmentCard(
                            appointment: all[i],
                            showClient: true,
                            showBarber: true,
                            showBarbershop: true,
                            onCancel: all[i].canCancel
                                ? () => _cancelConfirm(context, data, all[i].id)
                                : null,
                          ),
                        ),
                        childCount: all.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelConfirm(
      BuildContext ctx, AppDataProvider data, String id) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text('Cancelar agendamento',
            style: Theme.of(ctx).textTheme.titleLarge),
        content: Text('Confirmar cancelamento?',
            style: Theme.of(ctx).textTheme.bodyMedium),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Não')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await data.cancelAppointment(id);
      if (ctx.mounted) {
        AppUtils.showSnack(ctx, 'Agendamento cancelado.', isError: true);
      }
    }
  }
}

// ── Shop stat card ─────────────────────────────────────────────────────────────
class _ShopStatCard extends StatelessWidget {
  final String emoji, name;
  final int total, pending, revenue;
  const _ShopStatCard({
    required this.emoji,
    required this.name,
    required this.total,
    required this.pending,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const Spacer(),
          Row(children: [
            _MiniStat(
                value: '$total',
                label: 'agend.',
                icon: Icons.calendar_today_outlined),
            const SizedBox(width: 12),
            _MiniStat(
                value: '$pending',
                label: 'pend.',
                icon: Icons.pending_outlined),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border:
                  Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.attach_money_rounded,
                  size: 12, color: Color(0xFF4CAF50)),
              Text('R\$ $revenue',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: const Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const _MiniStat(
      {required this.value, required this.label, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: AppTheme.textHint),
      const SizedBox(width: 4),
      Text('$value $label',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontSize: 11, color: AppTheme.textSecondary)),
    ]);
  }
}

// ── Status breakdown ──────────────────────────────────────────────────────────
class _StatusBreakdown extends StatelessWidget {
  final List<AppointmentModel> appointments;
  const _StatusBreakdown({required this.appointments});
  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) return const SizedBox.shrink();
    final total = appointments.length;
    final byStatus = <AppointmentStatus, int>{};
    for (final a in appointments) {
      byStatus[a.status] = (byStatus[a.status] ?? 0) + 1;
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('DISTRIBUIÇÃO',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.textHint, fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 14),
        ...AppointmentStatus.values.map((s) {
          final count = byStatus[s] ?? 0;
          final pct = total > 0 ? count / total : 0.0;
          final (color, _) = AppUtils.statusColors(s);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: color)),
              const SizedBox(width: 10),
              SizedBox(
                width: 80,
                child: Text(
                  s == AppointmentStatus.scheduled
                      ? 'Agendados'
                      : s == AppointmentStatus.completed
                          ? 'Concluídos'
                          : 'Cancelados',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppTheme.inputBorder,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(color.withOpacity(.7)),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('$count',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600)),
            ]),
          );
        }),
      ]),
    );
  }
}
