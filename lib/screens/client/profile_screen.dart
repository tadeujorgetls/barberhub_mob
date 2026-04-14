import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_provider.dart';
import '../../models/app_data_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = context.watch<AppDataProvider>();
    final user = auth.currentUser;
    final initials =
        user?.name.split(' ').take(2).map((e) => e[0].toUpperCase()).join() ??
            'U';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────
              Stack(
                children: [
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.gold.withOpacity(0.12),
                          AppTheme.gold.withOpacity(0.03),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(Icons.logout_rounded,
                          color: AppTheme.textSecondary, size: 20),
                      onPressed: () {
                        auth.logout();
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.login);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.gold.withOpacity(0.15),
                            border: Border.all(color: AppTheme.gold, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: AppTheme.gold,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Usuário',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? '',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Stats row ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    _StatCard(
                      value:
                          '${data.appointmentsForClient(auth.currentUser?.id ?? '').length}',
                      label: 'Total',
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      value:
                          '${data.activeForClient(auth.currentUser?.id ?? '').length}',
                      label: 'Ativos',
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      value:
                          '${data.pastForClient(auth.currentUser?.id ?? '').length}',
                      label: 'Histórico',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Menu items ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Conta'),
                    const SizedBox(height: 12),
                    const _MenuItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Editar perfil',
                        tag: 'Em breve'),
                    const _MenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notificações',
                        tag: 'Em breve'),
                    const _MenuItem(
                        icon: Icons.lock_outline_rounded,
                        label: 'Alterar senha',
                        tag: 'Em breve'),
                    const SizedBox(height: 20),
                    const SectionHeader(title: 'Suporte'),
                    const SizedBox(height: 12),
                    const _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Central de ajuda',
                        tag: 'Em breve'),
                    const _MenuItem(
                        icon: Icons.star_outline_rounded,
                        label: 'Avaliar o app',
                        tag: 'Em breve'),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          auth.logout();
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.login);
                        },
                        style: OutlinedButton.styleFrom(
                          side:
                              const BorderSide(color: AppTheme.error, width: 1),
                          foregroundColor: AppTheme.error,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: const Text('SAIR DA CONTA'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Text(
                        'Barber Hub v1.0.0',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.gold,
                    fontSize: 26,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tag;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                  ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.textHint.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tag,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 10,
                    color: AppTheme.textHint,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: AppTheme.textHint),
        ],
      ),
    );
  }
}
