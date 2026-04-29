import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/cart_provider.dart';
import '../models/onboarding_provider.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../widgets/onboarding_overlay.dart';
import 'client/barbershop_list_screen.dart';
import 'client/appointments_screen.dart';
import 'client/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // GlobalKeys para cada item da BottomNav — usados pelo onboarding para
  // calcular a posicao do spotlight em cada etapa.
  final _navKey0 = GlobalKey(); // Inicio
  final _navKey1 = GlobalKey(); // Agendamentos
  final _navKey2 = GlobalKey(); // Carrinho
  final _navKey3 = GlobalKey(); // Perfil

  final List<Widget> _pages = const [
    BarbershopListScreen(),
    AppointmentsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OnboardingProvider>().checkFirstAccess();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: _BarberBottomNav(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            navKey0: _navKey0,
            navKey1: _navKey1,
            navKey2: _navKey2,
            navKey3: _navKey3,
          ),
        ),
        Consumer<OnboardingProvider>(
          builder: (_, prov, __) {
            if (!prov.isReady || !prov.shouldShow) {
              return const SizedBox.shrink();
            }
            return OnboardingOverlay(
              navKeys: [_navKey0, _navKey1, _navKey2, _navKey3],
            );
          },
        ),
      ],
    );
  }
}

class _BarberBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final GlobalKey navKey0;
  final GlobalKey navKey1;
  final GlobalKey navKey2;
  final GlobalKey navKey3;

  const _BarberBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.navKey0,
    required this.navKey1,
    required this.navKey2,
    required this.navKey3,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

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
            children: [
              _NavItem(
                key: navKey0,
                icon: Icons.storefront_outlined,
                activeIcon: Icons.storefront_rounded,
                label: 'Inicio',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                key: navKey1,
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today_rounded,
                label: 'Agendamentos',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _CartNavItem(key: navKey2, itemCount: cart.itemCount),
              _NavItem(
                key: navKey3,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Perfil',
                selected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartNavItem extends StatelessWidget {
  final int itemCount;
  const _CartNavItem({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  itemCount > 0
                      ? Icons.shopping_bag_rounded
                      : Icons.shopping_bag_outlined,
                  color: itemCount > 0 ? AppTheme.gold : AppTheme.textHint,
                  size: 22,
                ),
                if (itemCount > 0)
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.gold,
                      ),
                      child: Center(
                        child: Text(
                          itemCount > 9 ? '9+' : '$itemCount',
                          style: const TextStyle(
                            color: AppTheme.background,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Carrinho',
              style: GoogleFonts.jost(
                fontSize: 10,
                fontWeight: itemCount > 0 ? FontWeight.w600 : FontWeight.w400,
                color: itemCount > 0 ? AppTheme.gold : AppTheme.textHint,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                selected ? activeIcon : icon,
                key: ValueKey(selected),
                color: selected ? AppTheme.gold : AppTheme.textHint,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.jost(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? AppTheme.gold : AppTheme.textHint,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
