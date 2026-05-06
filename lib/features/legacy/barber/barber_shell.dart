import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_hub/core/theme/app_theme.dart';
import 'package:barber_hub/features/legacy/barber/barber_schedule_screen.dart';
import 'package:barber_hub/features/legacy/barber/barber_profile_screen.dart';

class BarberShell extends StatefulWidget {
  const BarberShell({super.key});

  @override
  State<BarberShell> createState() => _BarberShellState();
}

class _BarberShellState extends State<BarberShell> {
  int _index = 0;

  final _pages = const [
    BarberScheduleScreen(),
    BarberProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _BarberNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BarberNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BarberNav({required this.currentIndex, required this.onTap});

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
            _Item(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: 'Agenda', selected: currentIndex == 0, onTap: () => onTap(0)),
            _Item(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Perfil', selected: currentIndex == 1, onTap: () => onTap(1)),
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
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(selected ? activeIcon : icon, key: ValueKey(selected), color: selected ? AppTheme.gold : AppTheme.textHint, size: 22),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.jost(fontSize: 10, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? AppTheme.gold : AppTheme.textHint)),
      ]),
    ),
  );
}
