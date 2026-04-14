import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import 'admin_overview_screen.dart';
import 'admin_services_screen.dart';
import 'admin_barbers_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final _pages = const [
    AdminOverviewScreen(),
    AdminServicesScreen(),
    AdminBarbersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _AdminNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _AdminNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _AdminNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(children: [
            _Item(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Visão Geral', selected: currentIndex == 0, onTap: () => onTap(0)),
            _Item(icon: Icons.content_cut_outlined, activeIcon: Icons.content_cut_rounded, label: 'Serviços', selected: currentIndex == 1, onTap: () => onTap(1)),
            _Item(icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded, label: 'Barbeiros', selected: currentIndex == 2, onTap: () => onTap(2)),
          ]),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Item({required this.icon, required this.activeIcon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap, behavior: HitTestBehavior.opaque,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(selected ? activeIcon : icon, key: ValueKey(selected), color: selected ? AppTheme.gold : AppTheme.textHint, size: 22),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.jost(fontSize: 10, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? AppTheme.gold : AppTheme.textHint), overflow: TextOverflow.ellipsis),
      ]),
    ),
  );
}
