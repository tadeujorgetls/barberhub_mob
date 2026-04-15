import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_data_provider.dart';
import '../../models/barbershop_model.dart';
import '../../models/service_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class BarbershopDetailScreen extends StatelessWidget {
  const BarbershopDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shop = ModalRoute.of(context)!.settings.arguments as BarbershopModel;

    // Garante que a barbearia está selecionada no provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppDataProvider>().selectBarbershop(shop);
    });

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Top bar ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: AppTheme.textSecondary),
                      onPressed: () {
                        context
                            .read<AppDataProvider>()
                            .clearSelectedBarbershop();
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    Text(
                      'BARBEARIA',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.textHint,
                            fontSize: 11,
                            letterSpacing: 3,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Cover ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _CoverCard(shop: shop),
              ),
            ),

            // ── Info ────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: _ShopInfo(shop: shop),
              ),
            ),

            // ── Stats ────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: _StatsRow(shop: shop),
              ),
            ),

            // ── Equipe ──────────────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: SectionHeader(title: 'Equipe'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: SizedBox(
                  height: 100,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    scrollDirection: Axis.horizontal,
                    itemCount: shop.barbers.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) =>
                        _BarberChip(barber: shop.barbers[i]),
                  ),
                ),
              ),
            ),

            // ── Serviços ────────────────────────────────────────────────────
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 28, 24, 14),
                child: SectionHeader(title: 'Serviços disponíveis'),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final activeServices =
                        shop.services.where((s) => s.isActive).toList();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ServiceBookingCard(
                        service: activeServices[index],
                        shop: shop,
                      ),
                    );
                  },
                  childCount:
                      shop.services.where((s) => s.isActive).length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cover card ────────────────────────────────────────────────────────────────
class _CoverCard extends StatelessWidget {
  final BarbershopModel shop;
  const _CoverCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.gold.withOpacity(0.20),
            AppTheme.gold.withOpacity(0.04),
          ],
        ),
        border: Border.all(color: AppTheme.gold.withOpacity(0.22)),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(shop.coverEmoji,
                style: const TextStyle(fontSize: 68)),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: _OpenBadge(isOpen: shop.isOpen),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 5),
          Text(
            isOpen ? 'Aberto' : 'Fechado',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Shop info ─────────────────────────────────────────────────────────────────
class _ShopInfo extends StatelessWidget {
  final BarbershopModel shop;
  const _ShopInfo({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                shop.name,
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 30, height: 1.1),
              ),
            ),
            const SizedBox(width: 12),
            _RatingPill(rating: shop.rating, count: shop.reviewCount),
          ],
        ),
        const SizedBox(height: 12),
        _IconRow(icon: Icons.location_on_outlined, text: shop.address),
        if (shop.phone != null) ...[
          const SizedBox(height: 7),
          _IconRow(icon: Icons.phone_outlined, text: shop.phone!),
        ],
        if (shop.description != null) ...[
          const SizedBox(height: 16),
          const GoldAccent(),
          const SizedBox(height: 14),
          Text(
            shop.description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.65,
                ),
          ),
        ],
      ],
    );
  }
}

class _IconRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _IconRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppTheme.textHint),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;
  final int count;
  const _RatingPill({required this.rating, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.gold.withOpacity(0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.gold.withOpacity(0.28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 14, color: AppTheme.gold),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.gold,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count avaliações',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontSize: 11, color: AppTheme.textHint),
        ),
      ],
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final BarbershopModel shop;
  const _StatsRow({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(
          icon: Icons.content_cut_rounded,
          value: '${shop.services.where((s) => s.isActive).length}',
          label: 'serviços',
        ),
        const SizedBox(width: 10),
        _StatTile(
          icon: Icons.people_outline_rounded,
          value: '${shop.barbers.where((b) => b.isActive).length}',
          label: 'barbeiros',
        ),
        const SizedBox(width: 10),
        _StatTile(
          icon: Icons.star_outline_rounded,
          value: shop.formattedRating,
          label: 'avaliação',
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatTile(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppTheme.gold),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 10, color: AppTheme.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Barber chip ───────────────────────────────────────────────────────────────
class _BarberChip extends StatelessWidget {
  final dynamic barber;
  const _BarberChip({required this.barber});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.gold.withOpacity(0.12),
              border: Border.all(
                  color: AppTheme.gold.withOpacity(0.3), width: 1.5),
            ),
            child: Center(
              child: Text(
                barber.avatarInitials,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppTheme.gold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  barber.name.split(' ').first,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  barber.specialty,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 10, color: AppTheme.textHint),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 11, color: AppTheme.gold),
                    const SizedBox(width: 3),
                    Text(
                      (barber.rating as double).toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Service booking card ──────────────────────────────────────────────────────
class _ServiceBookingCard extends StatelessWidget {
  final ServiceModel service;
  final BarbershopModel shop;

  const _ServiceBookingCard({required this.service, required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Info ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
                  ),
                  child: Icon(ServiceCard.iconFor(service.iconName),
                      color: AppTheme.gold, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.schedule_outlined,
                              size: 12, color: AppTheme.textHint),
                          const SizedBox(width: 4),
                          Text(
                            service.formattedDuration,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                              color: AppTheme.textHint,
                              height: 1.4,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  service.formattedPrice,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.gold,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),

          // ── Agendar CTA ───────────────────────────────────────────────
          Container(height: 1, color: AppTheme.divider),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.booking,
                arguments: {'service': service, 'barbershop': shop},
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(10)),
              splashColor: AppTheme.gold.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month_outlined,
                        size: 15, color: AppTheme.gold),
                    const SizedBox(width: 8),
                    Text(
                      'Agendar este serviço',
                      style:
                          Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppTheme.gold,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
