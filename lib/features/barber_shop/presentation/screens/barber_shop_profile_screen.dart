import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_hub/core/theme/app_theme.dart';
import 'package:barber_hub/core/routes/app_routes.dart';
import 'package:barber_hub/features/auth/presentation/providers/auth_providers.dart';
import 'package:barber_hub/features/barber_shop/presentation/providers/shop_management_providers.dart';

class BarberShopProfileScreen extends ConsumerWidget {
  const BarberShopProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final mgmt = ref.watch(shopManagementProvider);
    final settings = mgmt.settings;
    final barbers = mgmt.barbers;
    final products = mgmt.products;
    final blocks = mgmt.blockedDates;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(slivers: [
          // ── Hero ────────────────────────────────────────────────────────────
          SliverToBoxAdapter(child: Container(
            width: double.infinity, padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [AppTheme.gold.withOpacity(0.12), AppTheme.gold.withOpacity(0.02)]),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: AppTheme.gold.withOpacity(0.15),
                    border: Border.all(color: AppTheme.gold.withOpacity(0.4), width: 2)),
                child: Center(child: Text(user?.initials ?? 'BH',
                    style: GoogleFonts.cormorantGaramond(
                        color: AppTheme.gold, fontSize: 28, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(height: 14),
              Text(settings?.name ?? user?.name ?? '', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(user?.email ?? '', style: GoogleFonts.jost(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                ),
                child: Text('PROPRIETÁRIO', style: GoogleFonts.jost(
                    color: AppTheme.gold, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
              ),
            ]),
          )),

          // ── Stats da barbearia ───────────────────────────────────────────────
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('RESUMO DA BARBEARIA', style: GoogleFonts.jost(
                  color: AppTheme.textHint, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 3)),
              const SizedBox(height: 14),
              Row(children: [
                _InfoTile(label: 'Barbeiros', value: '${barbers.where((b) => b.isActive).length}/${barbers.length}',
                    icon: Icons.people_rounded),
                const SizedBox(width: 12),
                _InfoTile(label: 'Produtos', value: '${products.length}', icon: Icons.inventory_2_rounded),
                const SizedBox(width: 12),
                _InfoTile(label: 'Bloqueios', value: '${blocks.length}', icon: Icons.block_rounded),
              ]),
            ]),
          )),

          if (settings?.address.isNotEmpty ?? false)
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.inputBorder),
                ),
                child: Row(children: [
                  const Icon(Icons.location_on_rounded, color: AppTheme.gold, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(settings!.address,
                      style: GoogleFonts.jost(color: AppTheme.textSecondary, fontSize: 13))),
                ]),
              ),
            )),

          // ── Logout ───────────────────────────────────────────────────────────
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Sair da conta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.error,
                  side: BorderSide(color: AppTheme.error.withOpacity(0.5)),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                ),
              ),
            ),
          )),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ]),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _InfoTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
    decoration: BoxDecoration(
      color: AppTheme.surfaceElevated,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.inputBorder),
    ),
    child: Column(children: [
      Icon(icon, color: AppTheme.gold, size: 20),
      const SizedBox(height: 6),
      Text(value, style: GoogleFonts.cormorantGaramond(
          color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
      Text(label, style: GoogleFonts.jost(color: AppTheme.textSecondary, fontSize: 10),
          textAlign: TextAlign.center),
    ]),
  ));
}
