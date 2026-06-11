import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_hub/core/theme/app_theme.dart';
import 'package:barber_hub/core/routes/app_routes.dart';
import 'package:barber_hub/features/auth/presentation/providers/auth_providers.dart';
import 'package:barber_hub/features/barber_shop/presentation/providers/shop_management_providers.dart';
import 'barber_shop_dashboard_screen.dart';
import 'barber_shop_barbers_screen.dart';
import 'barber_shop_products_screen.dart';
import 'barber_shop_schedule_screen.dart';
// MELHORIA #11: Serviços adicionado ao nav.
import 'barber_shop_services_screen.dart';
import 'barber_shop_settings_screen.dart';

class BarberShopShell extends ConsumerStatefulWidget {
  const BarberShopShell({super.key});
  @override
  ConsumerState<BarberShopShell> createState() => _State();
}

class _State extends ConsumerState<BarberShopShell> {
  int _index = 0;

  // MELHORIA #11: BarberShopServicesScreen adicionada.
  // Membership é acessada via rota push (não como tab) — mantém 6 tabs.
  final _pages = const [
    BarberShopDashboardScreen(),
    BarberShopScheduleScreen(),
    BarberShopBarbersScreen(),
    BarberShopServicesScreen(),
    BarberShopProductsScreen(),
    BarberShopSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shopManagementProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      // Floating action button para acesso rápido ao painel de assinaturas.
      floatingActionButton: _index == 0
          ? _MembershipFab(
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.membershipManagement),
            )
          : null,
      bottomNavigationBar: _Nav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// FAB de acesso rápido ao painel de assinaturas — visível no Dashboard.
class _MembershipFab extends ConsumerWidget {
  final VoidCallback onTap;
  const _MembershipFab({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    return FloatingActionButton.extended(
      onPressed: onTap,
      backgroundColor: AppTheme.surfaceElevated,
      foregroundColor: AppTheme.gold,
      elevation: 2,
      icon: const Icon(Icons.workspace_premium_rounded, size: 18),
      label: Text(
        'Assinaturas',
        style: GoogleFonts.jost(
            fontWeight: FontWeight.w600, fontSize: 13, letterSpacing: 0.5),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.4)),
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _Nav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // MELHORIA #11: 6 tabs (Dashboard, Agenda, Barbeiros, Serviços, Produtos, Config.)
    const items = [
      (Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
      (Icons.calendar_today_outlined, Icons.calendar_today_rounded, 'Agenda'),
      (Icons.people_outline_rounded, Icons.people_rounded, 'Barbeiros'),
      (Icons.content_cut_outlined, Icons.content_cut_rounded, 'Serviços'),
      (Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'Produtos'),
      (Icons.settings_outlined, Icons.settings_rounded, 'Config.'),
    ];
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
              children: List.generate(items.length, (i) {
            final (icon, activeIcon, label) = items[i];
            final sel = currentIndex == i;
            return Expanded(
                child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(sel ? activeIcon : icon,
                          key: ValueKey(sel),
                          color: sel ? AppTheme.gold : AppTheme.textHint,
                          size: 22),
                    ),
                    const SizedBox(height: 4),
                    Text(label,
                        style: GoogleFonts.jost(
                            fontSize: 9,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                            color: sel ? AppTheme.gold : AppTheme.textHint,
                            letterSpacing: 0.2)),
                  ]),
            ));
          })),
        ),
      ),
    );
  }
}
