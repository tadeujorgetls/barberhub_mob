import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auth_provider.dart';
import '../../models/app_data_provider.dart';
import '../../models/appointment_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class BarberProfileScreen extends StatelessWidget {
  const BarberProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final data = context.watch<AppDataProvider>();
    final user = auth.currentUser!;
    final barberId = auth.linkedBarberId ?? '';
    final barber = data.allBarbers.where((b) => b.id == barberId).firstOrNull;
    final appts = data.appointmentsForBarber(barberId);
    final completed =
        appts.where((a) => a.status == AppointmentStatus.completed).length;
    final revenue = appts
        .where((a) => a.status == AppointmentStatus.completed)
        .fold(0.0, (s, a) => s + a.service.price);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            // Hero
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.gold.withOpacity(.1),
                    AppTheme.gold.withOpacity(.02)
                  ],
                ),
              ),
              child: Row(children: [
                BarberAvatar(initials: user.initials, size: 72),
                const SizedBox(width: 16),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(user.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontSize: 18)),
                      const SizedBox(height: 4),
                      if (barber != null)
                        Text(barber.specialty,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontSize: 13)),
                      const SizedBox(height: 8),
                      Row(children: [
                        RoleBadge(label: user.roleLabel.toUpperCase()),
                        if (barber != null) ...[
                          const SizedBox(width: 8),
                          StarRating(
                              rating: barber.rating,
                              reviewCount: barber.reviewCount),
                        ],
                      ]),
                    ])),
                IconButton(
                  icon: const Icon(Icons.logout_rounded,
                      color: AppTheme.textSecondary, size: 20),
                  onPressed: () {
                    auth.logout();
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  },
                ),
              ]),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(children: [
                StatCard(value: '${appts.length}', label: 'Total'),
                const SizedBox(width: 10),
                StatCard(value: '$completed', label: 'Concluídos'),
                const SizedBox(width: 10),
                StatCard(
                    value: 'R\$ ${revenue.toStringAsFixed(0)}',
                    label: 'Receita',
                    valueColor: const Color(0xFF4CAF50)),
              ]),
            ),

            const SizedBox(height: 28),

            // Info section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Informações'),
                    const SizedBox(height: 14),
                    _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'E-mail',
                        value: user.email),
                    if (barber?.phone.isNotEmpty == true) ...[
                      const SizedBox(height: 10),
                      _InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'Telefone',
                          value: barber!.phone),
                    ],
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Conta'),
                    const SizedBox(height: 14),
                    const _MenuItem(
                        icon: Icons.lock_outline_rounded,
                        label: 'Alterar senha'),
                    const _MenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notificações'),
                    const SizedBox(height: 24),
                    CustomButton(
                      label: 'Sair da conta',
                      isDanger: true,
                      icon: Icons.logout_rounded,
                      onPressed: () {
                        auth.logout();
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.login);
                      },
                    ),
                    const SizedBox(height: 32),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.inputBorder)),
        child: Row(children: [
          Icon(icon, color: AppTheme.gold, size: 18),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontSize: 14)),
          ]),
        ]),
      );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.inputBorder)),
        child: Row(children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 14),
          Expanded(
              child: Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 14))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: AppTheme.textHint.withOpacity(.15),
                borderRadius: BorderRadius.circular(4)),
            child: Text('Em breve',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 10, color: AppTheme.textHint)),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: AppTheme.textHint),
        ]),
      );
}
