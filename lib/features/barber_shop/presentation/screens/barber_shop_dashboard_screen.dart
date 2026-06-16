import 'package:flutter/material.dart';
import 'package:barber_hub/core/utils/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_hub/core/theme/app_theme.dart';
import 'package:barber_hub/core/utils/app_utils.dart';
import 'package:barber_hub/features/auth/presentation/providers/auth_providers.dart';
import 'package:barber_hub/features/barber_shop/presentation/providers/barber_shop_providers.dart';
import 'package:barber_hub/features/barber_shop/presentation/providers/shop_management_providers.dart';
import 'package:barber_hub/models/appointment_model.dart';

class BarberShopDashboardScreen extends ConsumerStatefulWidget {
  const BarberShopDashboardScreen({super.key});
  @override
  ConsumerState<BarberShopDashboardScreen> createState() => _State();
}

class _State extends ConsumerState<BarberShopDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(barberShopNotifierProvider.notifier).loadDashboard();
    });
  }

  Future<void> _refreshDashboard() {
    return ref.read(barberShopNotifierProvider.notifier).loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(barberShopNotifierProvider);
    final mgmt = ref.watch(shopManagementProvider);
    final authState = ref.watch(authNotifierProvider);
    final ownerName = authState is AuthAuthenticated
        ? authState.user.name.split(' ').first
        : 'Proprietario';

    return Scaffold(
      body: SafeArea(
        child: switch (state) {
          BarberShopLoading() => const Center(
              child: CircularProgressIndicator(color: AppTheme.gold)),
          BarberShopError(:final message) => _ErrorView(
              message: message,
              onRetry: () => ref
                  .read(barberShopNotifierProvider.notifier)
                  .loadDashboard()),
          BarberShopLoaded(
            :final shop,
            :final stats,
            :final todayAppointments,
            :final upcomingAppointments,
            :final recentReviews
          ) =>
            Builder(builder: (context) {
              final displayName =
                  _preferredText(mgmt.settings?.name, shop.name);
              final displayAddress =
                  _preferredText(mgmt.settings?.address, shop.address);
              return RefreshIndicator(
                color: AppTheme.gold,
                backgroundColor: AppTheme.surfaceElevated,
                onRefresh: _refreshDashboard,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    SliverToBoxAdapter(
                        child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.gold.withOpacity(0.14),
                            AppTheme.gold.withOpacity(0.02)
                          ],
                        ),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                AppTheme.gold.withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: AppTheme.gold
                                                    .withOpacity(0.3)),
                                          ),
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                    Icons.storefront_rounded,
                                                    color: AppTheme.gold,
                                                    size: 11),
                                                const SizedBox(width: 5),
                                                Text('PAINEL DA BARBEARIA',
                                                    style: GoogleFonts.jost(
                                                        color: AppTheme.gold,
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: 2)),
                                              ]),
                                        ),
                                        const SizedBox(height: 14),
                                        Text('Ola, $ownerName!',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(fontSize: 26)),
                                        const SizedBox(height: 4),
                                        Text(displayName,
                                            style: GoogleFonts.jost(
                                                color: AppTheme.textSecondary,
                                                fontSize: 14)),
                                        const SizedBox(height: 4),
                                        Row(children: [
                                          const Icon(Icons.location_on_outlined,
                                              size: 12,
                                              color: AppTheme.textHint),
                                          const SizedBox(width: 4),
                                          // usa settings se disponÃ­vel, senÃ£o usa shop.address
                                          Expanded(
                                              child: Text(displayAddress,
                                                  style: GoogleFonts.jost(
                                                      color: AppTheme.textHint,
                                                      fontSize: 12),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis)),
                                        ]),
                                      ])),
                                  const SizedBox(width: 12),
                                  Column(children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await ref
                                            .read(authNotifierProvider.notifier)
                                            .logout();
                                        if (context.mounted)
                                          Navigator.pushReplacementNamed(
                                              context, '/login');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceElevated,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: AppTheme.inputBorder),
                                        ),
                                        child: const Icon(Icons.logout_rounded,
                                            color: AppTheme.textSecondary,
                                            size: 18),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Icon(
                                        BarbershopIcons.fromKey(
                                            shop.coverEmoji),
                                        color: AppTheme.gold,
                                        size: 32),
                                  ]),
                                ]),
                          ]),
                    )),

                    // â”€â”€ Alertas rÃ¡pidos â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    if (mgmt.blockedDates.isNotEmpty)
                      SliverToBoxAdapter(
                          child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppTheme.gold.withOpacity(0.25)),
                          ),
                          child: Row(children: [
                            const Icon(Icons.block_rounded,
                                color: AppTheme.gold, size: 16),
                            const SizedBox(width: 10),
                            Text(
                                '${mgmt.blockedDates.length} bloqueio${mgmt.blockedDates.length != 1 ? 's' : ''} de data ativo${mgmt.blockedDates.length != 1 ? 's' : ''}',
                                style: GoogleFonts.jost(
                                    color: AppTheme.gold, fontSize: 12)),
                          ]),
                        ),
                      )),

                    // â”€â”€ Stats Grid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    SliverToBoxAdapter(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('VISAO GERAL',
                                style: GoogleFonts.jost(
                                    color: AppTheme.textHint,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 3)),
                            const SizedBox(height: 14),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              childAspectRatio: 2.4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              children: [
                                _StatCard(
                                    label: 'Hoje',
                                    value: '${stats.todayAppointments}',
                                    icon: Icons.today_rounded,
                                    color: AppTheme.gold),
                                _StatCard(
                                    label: 'Pendentes',
                                    value: '${stats.pendingAppointments}',
                                    icon: Icons.pending_actions_rounded,
                                    color: Colors.orangeAccent),
                                _StatCard(
                                    label: 'Barbeiros ativos',
                                    value:
                                        '${mgmt.barbers.where((b) => b.isActive).length}',
                                    icon: Icons.people_rounded,
                                    color: Colors.blueAccent),
                                _StatCard(
                                    label: 'Receita/mes',
                                    value:
                                        'R\$ ${stats.monthRevenue.toStringAsFixed(0)}',
                                    icon: Icons.payments_rounded,
                                    color: AppTheme.gold,
                                    gold: true),
                              ],
                            ),
                          ]),
                    )),

                    // â”€â”€ Rating + Total â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    SliverToBoxAdapter(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppTheme.gold.withOpacity(0.2)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.star_rounded,
                              color: AppTheme.gold, size: 32),
                          const SizedBox(width: 12),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(shop.rating.toStringAsFixed(1),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                            color: AppTheme.gold,
                                            fontSize: 26)),
                                Text('${shop.reviewCount} avaliacoes',
                                    style: GoogleFonts.jost(
                                        color: AppTheme.textSecondary,
                                        fontSize: 12)),
                              ]),
                          const Spacer(),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    'R\$ ${stats.totalRevenue.toStringAsFixed(0)}',
                                    style: GoogleFonts.jost(
                                        color: AppTheme.textPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                                Text('receita total',
                                    style: GoogleFonts.jost(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11)),
                              ]),
                        ]),
                      ),
                    )),

                    // â”€â”€ Agenda do dia â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    SliverToBoxAdapter(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: Text('AGENDA DO DIA',
                          style: GoogleFonts.jost(
                              color: AppTheme.textHint,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3)),
                    )),

                    if (todayAppointments.isEmpty)
                      SliverToBoxAdapter(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.divider),
                          ),
                          child: Row(children: [
                            const Icon(Icons.event_available_rounded,
                                color: AppTheme.textHint, size: 24),
                            const SizedBox(width: 12),
                            Text('Nenhum agendamento para hoje.',
                                style: GoogleFonts.jost(
                                    color: AppTheme.textHint, fontSize: 13)),
                          ]),
                        ),
                      ))
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                          (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ApptTile(appt: todayAppointments[i]),
                          ),
                          childCount: todayAppointments.length,
                        )),
                      ),

                    // â”€â”€ PrÃ³ximos â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                    if (upcomingAppointments.isNotEmpty) ...[
                      SliverToBoxAdapter(
                          child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                        child: Text('PROXIMOS',
                            style: GoogleFonts.jost(
                                color: AppTheme.textHint,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3)),
                      )),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                          (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ApptTile(
                                appt: upcomingAppointments[i], showDate: true),
                          ),
                          childCount: upcomingAppointments.take(5).length,
                        )),
                      ),
                    ],

                    SliverToBoxAdapter(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: Row(children: [
                        Text('AVALIACOES RECENTES',
                            style: GoogleFonts.jost(
                                color: AppTheme.textHint,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3)),
                        const Spacer(),
                        if (shop.reviewCount > 0)
                          Text('${shop.reviewCount} avaliacoes',
                              style: GoogleFonts.jost(
                                  color: AppTheme.textSecondary, fontSize: 11)),
                      ]),
                    )),
                    if (recentReviews.isEmpty)
                      SliverToBoxAdapter(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _EmptyReviewsCard(rating: shop.rating),
                      ))
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                          (_, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _ReviewTile(review: recentReviews[i]),
                          ),
                          childCount: recentReviews.length,
                        )),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              );
            }),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }
}

// â”€â”€ Stat Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
String _preferredText(String? value, String fallback) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? fallback : trimmed;
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final bool gold;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      this.gold = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color:
              gold ? AppTheme.gold.withOpacity(0.08) : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color:
                  gold ? AppTheme.gold.withOpacity(0.3) : AppTheme.inputBorder),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(value,
                    style: GoogleFonts.jost(
                        color: gold ? AppTheme.gold : AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                Text(label,
                    style: GoogleFonts.jost(
                        color: AppTheme.textSecondary, fontSize: 10)),
              ])),
        ]),
      );
}

// â”€â”€ Appointment Tile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _ApptTile extends StatelessWidget {
  final AppointmentModel appt;
  final bool showDate;
  const _ApptTile({required this.appt, this.showDate = false});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Center(
                child: Text(appt.timeSlot,
                    style: GoogleFonts.jost(
                        color: AppTheme.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(appt.clientName,
                    style: GoogleFonts.jost(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text('${appt.service.name} - ${appt.barber.name}',
                    style: GoogleFonts.jost(
                        color: AppTheme.textSecondary, fontSize: 12)),
                if (showDate)
                  Text(AppUtils.formatDateShort(appt.date),
                      style: GoogleFonts.jost(
                          color: AppTheme.textHint, fontSize: 11)),
              ])),
          Text('R\$ ${appt.service.price.toStringAsFixed(0)}',
              style: GoogleFonts.jost(
                  color: AppTheme.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ]),
      );
}

class _ReviewTile extends StatelessWidget {
  final ReviewModel review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final comment = review.comment?.trim();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.gold.withOpacity(0.14),
            child: Text(
              _initialsFor(review.clientName),
              style: GoogleFonts.jost(
                  color: AppTheme.gold,
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(review.clientName,
                    style: GoogleFonts.jost(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${review.serviceName} - ${review.barberName}',
                    style: GoogleFonts.jost(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _StarsRow(rating: review.rating),
            const SizedBox(height: 4),
            Text(review.formattedDate,
                style:
                    GoogleFonts.jost(color: AppTheme.textHint, fontSize: 11)),
          ]),
        ]),
        if (comment != null && comment.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Text(comment,
                style: GoogleFonts.jost(
                    color: AppTheme.textSecondary, fontSize: 12, height: 1.45)),
          ),
        ],
      ]),
    );
  }
}

class _EmptyReviewsCard extends StatelessWidget {
  final double rating;
  const _EmptyReviewsCard({required this.rating});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.reviews_outlined,
                color: AppTheme.gold, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                    rating > 0
                        ? 'Nota media ${rating.toStringAsFixed(1)}'
                        : 'Sem avaliacoes ainda',
                    style: GoogleFonts.jost(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                    'As avaliacoes dos clientes vao aparecer aqui conforme os atendimentos forem concluidos.',
                    style: GoogleFonts.jost(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.45)),
              ])),
        ]),
      );
}

class _StarsRow extends StatelessWidget {
  final int rating;
  const _StarsRow({required this.rating});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return Padding(
            padding: EdgeInsets.only(right: index == 4 ? 0 : 2),
            child: Icon(
              index < rating ? Icons.star_rounded : Icons.star_border_rounded,
              color: AppTheme.gold,
              size: 14,
            ),
          );
        }),
      );
}

String _initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((item) => item.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'CL';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
      .toUpperCase();
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
          child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded,
              color: AppTheme.error, size: 48),
          const SizedBox(height: 16),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.jost(color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
        ]),
      ));
}
