import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_data_provider.dart';
import '../../models/auth_provider.dart';
import '../../models/appointment_model.dart';
import '../../models/barbershop_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class BarbershopListScreen extends StatefulWidget {
  const BarbershopListScreen({super.key});

  @override
  State<BarbershopListScreen> createState() => _BarbershopListScreenState();
}

class _BarbershopListScreenState extends State<BarbershopListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = context.watch<AppDataProvider>();
    final firstName = auth.currentUser?.name.split(' ').first ?? 'Visitante';
    final clientId = auth.currentUser?.id ?? '';

    final nextAppt = data.activeForClient(clientId).isNotEmpty
        ? data.activeForClient(clientId).first
        : null;

    final filtered = _search.isEmpty
        ? data.barbershops
        : data.barbershops
            .where((b) =>
                b.name.toLowerCase().contains(_search.toLowerCase()) ||
                b.address.toLowerCase().contains(_search.toLowerCase()))
            .toList();

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppTheme.gold.withOpacity(0.06),
                  Colors.transparent,
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
                    child: Row(
                      children: [
                        const BarberLogo(size: 30),
                        const SizedBox(width: 10),
                        Text(
                          'BARBER HUB',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                  color: AppTheme.gold,
                                  fontSize: 9,
                                  letterSpacing: 3),
                        ),
                        const Spacer(),
                        _AvatarButton(initial: firstName[0].toUpperCase()),
                      ],
                    ),
                  ),
                ),

                // ── Greeting ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Olá, $firstName.',
                            style:
                                Theme.of(context).textTheme.displayMedium),
                        const SizedBox(height: 6),
                        Text(
                          'Escolha uma barbearia.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Próximo agendamento (se houver) ───────────────────────
                if (nextAppt != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: _NextAppointmentBanner(appointment: nextAppt),
                    ),
                  ),

                // ── Busca ─────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: _SearchBar(
                        onChanged: (v) => setState(() => _search = v)),
                  ),
                ),

                // ── Section header ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                    child: SectionHeader(
                      title: _search.isEmpty
                          ? 'Barbearias'
                          : 'Resultados (${filtered.length})',
                    ),
                  ),
                ),

                // ── Lista ─────────────────────────────────────────────────
                filtered.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.search_off_rounded,
                                    color: AppTheme.textHint, size: 40),
                                const SizedBox(height: 12),
                                Text(
                                  'Nenhuma barbearia encontrada.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppTheme.textHint),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final shop = filtered[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _BarbershopCard(
                                  shop: shop,
                                  onTap: () {
                                    context
                                        .read<AppDataProvider>()
                                        .selectBarbershop(shop);
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.barbershopDetail,
                                      arguments: shop,
                                    );
                                  },
                                ),
                              );
                            },
                            childCount: filtered.length,
                          ),
                        ),
                      ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar button ─────────────────────────────────────────────────────────────
class _AvatarButton extends StatelessWidget {
  final String initial;
  const _AvatarButton({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.gold.withOpacity(0.12),
        border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          initial,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: AppTheme.gold, fontSize: 14),
        ),
      ),
    );
  }
}

// ── Next appointment banner ───────────────────────────────────────────────────
class _NextAppointmentBanner extends StatelessWidget {
  final AppointmentModel appointment;
  const _NextAppointmentBanner({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.gold.withOpacity(0.16),
            AppTheme.gold.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.gold.withOpacity(0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
            ),
            child: const Icon(Icons.calendar_month_outlined,
                color: AppTheme.gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRÓXIMO AGENDAMENTO',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.gold,
                        fontSize: 9,
                        letterSpacing: 2.5,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${a.service.name} · ${a.timeSlot}',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  '${a.barbershop.name} · ${a.formattedDate}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppTheme.textHint, size: 18),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: TextField(
        onChanged: onChanged,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Buscar barbearia ou endereço...',
          hintStyle: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppTheme.textHint),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppTheme.textHint, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ── Barbershop card ───────────────────────────────────────────────────────────
class _BarbershopCard extends StatelessWidget {
  final BarbershopModel shop;
  final VoidCallback onTap;
  const _BarbershopCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.gold.withOpacity(0.18),
                    AppTheme.gold.withOpacity(0.04),
                  ],
                ),
                border: Border(
                    bottom: BorderSide(
                        color: AppTheme.gold.withOpacity(0.12))),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(shop.coverEmoji,
                        style: const TextStyle(fontSize: 52)),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _OpenBadge(isOpen: shop.isOpen),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(shop.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontSize: 17)),
                      ),
                      const SizedBox(width: 10),
                      _RatingBadge(
                          rating: shop.rating, count: shop.reviewCount),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(children: [
                    const Icon(Icons.location_on_outlined,
                        size: 13, color: AppTheme.textHint),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        shop.address,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                fontSize: 12,
                                color: AppTheme.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    _InfoChip(
                      icon: Icons.content_cut_rounded,
                      label:
                          '${shop.services.where((s) => s.isActive).length} serviços',
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.people_outline_rounded,
                      label: '${shop.barbers.length} barbeiros',
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 12, color: AppTheme.textHint),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  final bool isOpen;
  const _OpenBadge({required this.isOpen});
  @override
  Widget build(BuildContext context) {
    final color = isOpen ? const Color(0xFF2ECC71) : AppTheme.error;
    final bg = isOpen ? const Color(0xFF1A3A1A) : const Color(0xFF3A1A1A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        isOpen ? 'Aberto' : 'Fechado',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  final int count;
  const _RatingBadge({required this.rating, required this.count});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.gold.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 12, color: AppTheme.gold),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.gold,
                fontSize: 12,
                fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
