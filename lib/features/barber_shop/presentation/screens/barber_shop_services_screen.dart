import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barber_hub/core/theme/app_theme.dart';

/// Tela de Serviços da Barbearia — placeholder (Prompt 2+).
class BarberShopServicesScreen extends ConsumerWidget {
  const BarberShopServicesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => const _PlaceholderScreen(
      icon: Icons.content_cut_rounded, title: 'Meus Serviços');
}

class _PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  const _PlaceholderScreen({required this.icon, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
            child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: AppTheme.gold, size: 48),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Em desenvolvimento',
              style: GoogleFonts.jost(color: AppTheme.textSecondary)),
        ]))),
      );
}
