import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_hub/core/theme/app_theme.dart';
import 'package:barber_hub/features/barber_shop/presentation/providers/shop_management_providers.dart';
import 'barber_shop_dashboard_screen.dart';
import 'barber_shop_barbers_screen.dart';
import 'barber_shop_products_screen.dart';
import 'barber_shop_schedule_screen.dart';
import 'barber_shop_settings_screen.dart';

class BarberShopShell extends ConsumerStatefulWidget {
  const BarberShopShell({super.key});
  @override
  ConsumerState<BarberShopShell> createState() => _State();
}

class _State extends ConsumerState<BarberShopShell> {
  int _index = 0;

  final _pages = const [
    BarberShopDashboardScreen(),
    BarberShopScheduleScreen(),
    BarberShopBarbersScreen(),
    BarberShopProductsScreen(),
    BarberShopSettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Carrega dados de gestão uma única vez ao entrar no shell
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shopManagementProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _Nav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
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
    const items = [
      (Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
      (Icons.calendar_today_outlined, Icons.calendar_today_rounded, 'Agenda'),
      (Icons.people_outline_rounded, Icons.people_rounded, 'Barbeiros'),
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
          child: Row(children: List.generate(items.length, (i) {
            final (icon, activeIcon, label) = items[i];
            final sel = currentIndex == i;
            return Expanded(child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(sel ? activeIcon : icon, key: ValueKey(sel),
                      color: sel ? AppTheme.gold : AppTheme.textHint, size: 22),
                ),
                const SizedBox(height: 4),
                Text(label, style: GoogleFonts.jost(
                  fontSize: 9, fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                  color: sel ? AppTheme.gold : AppTheme.textHint, letterSpacing: 0.2)),
              ]),
            ));
          })),
        ),
      ),
    );
  }
}
