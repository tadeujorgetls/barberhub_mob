import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/app_data_provider.dart';
import '../../models/appointment_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';
import 'reschedule_sheet.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MEUS',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.gold,
                          fontSize: 11,
                          letterSpacing: 4,
                        ),
                  ),
                  Text(
                    'Agendamentos',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Tab bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.inputBorder),
                ),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: AppTheme.gold,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  indicatorPadding: const EdgeInsets.all(3),
                  labelStyle: GoogleFonts.jost(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: GoogleFonts.jost(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  labelColor: AppTheme.background,
                  unselectedLabelColor: AppTheme.textSecondary,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Ativos'),
                          if (data.activeAppointments.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            _CountBadge(data.activeAppointments.length),
                          ],
                        ],
                      ),
                    ),
                    const Tab(text: 'Histórico'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 4),

            // ── Tab views ─────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _AppointmentList(
                    appointments: data.activeAppointments,
                    emptyTitle: 'Nenhum agendamento',
                    emptySubtitle:
                        'Você não tem horários marcados.\nQue tal agendar agora?',
                    emptyAction: 'Ver serviços',
                    onEmptyAction: () {
                      // Switch to home tab via MainShell
                      Navigator.pushReplacementNamed(context, AppRoutes.home);
                    },
                    onCancel: (a) => _confirmCancel(context, a, data),
                    onReschedule: (a) => _showReschedule(context, a, data),
                  ),
                  _AppointmentList(
                    appointments: data.pastAppointments,
                    emptyTitle: 'Histórico vazio',
                    emptySubtitle:
                        'Seus agendamentos concluídos\naparecerão aqui.',
                    onCancel: null,
                    onReschedule: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCancel(
    BuildContext context,
    AppointmentModel a,
    AppDataProvider data,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text(
          'Cancelar agendamento',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Tem certeza que deseja cancelar o serviço "${a.service.name}" com ${a.barber.name} em ${a.timeSlot}?',
          style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Manter'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await data.cancelAppointment(a.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.cancel_outlined,
                            color: AppTheme.error, size: 16),
                        SizedBox(width: 10),
                        Text('Agendamento cancelado'),
                      ],
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showReschedule(
    BuildContext context,
    AppointmentModel a,
    AppDataProvider data,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RescheduleSheet(appointment: a, data: data),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge(this.count);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.goldDark,
      ),
      child: Center(
        child: Text(
          '$count',
          style: GoogleFonts.jost(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ── Appointment list ─────────────────────────────────────────────────────────
class _AppointmentList extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final String emptyTitle;
  final String emptySubtitle;
  final String? emptyAction;
  final VoidCallback? onEmptyAction;
  final void Function(AppointmentModel)? onCancel;
  final void Function(AppointmentModel)? onReschedule;

  const _AppointmentList({
    required this.appointments,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.emptyAction,
    this.onEmptyAction,
    required this.onCancel,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today_outlined,
        title: emptyTitle,
        subtitle: emptySubtitle,
        actionLabel: emptyAction,
        onAction: onEmptyAction,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        return _AppointmentCard(
          appointment: appointments[i],
          onCancel: onCancel,
          onReschedule: onReschedule,
        );
      },
    );
  }
}

// ── Appointment card ─────────────────────────────────────────────────────────
class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final void Function(AppointmentModel)? onCancel;
  final void Function(AppointmentModel)? onReschedule;

  const _AppointmentCard({
    required this.appointment,
    required this.onCancel,
    required this.onReschedule,
  });

  (Color, Color) get _statusColors {
    switch (appointment.status) {
      case AppointmentStatus.scheduled:
        return (const Color(0xFF4CAF50), const Color(0xFF4CAF50));
      case AppointmentStatus.completed:
        return (AppTheme.gold, AppTheme.gold);
      case AppointmentStatus.cancelled:
        return (AppTheme.error, AppTheme.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusColor, _) = _statusColors;
    final a = appointment;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date block
                Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.gold.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${a.date.day}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge
                            ?.copyWith(
                              color: AppTheme.gold,
                              fontSize: 24,
                              height: 1,
                            ),
                      ),
                      Text(
                        _monthAbbr(a.date.month),
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(
                              color: AppTheme.gold,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.service.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontSize: 15),
                            ),
                          ),
                          StatusBadge(
                            label: a.statusLabel.toUpperCase(),
                            color: statusColor,
                            bgColor: statusColor.withOpacity(0.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded,
                              size: 13, color: AppTheme.textHint),
                          const SizedBox(width: 5),
                          Text(
                            a.barber.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.schedule_outlined,
                              size: 13, color: AppTheme.textHint),
                          const SizedBox(width: 5),
                          Text(
                            a.timeSlot,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontSize: 13),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '·',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontSize: 13),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            a.service.formattedPrice,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 13,
                                  color: AppTheme.gold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Actions
          if (a.canCancel || a.canReschedule) ...[
            Container(height: 1, color: AppTheme.divider),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  if (a.canReschedule && onReschedule != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => onReschedule!(a),
                        icon: const Icon(Icons.edit_calendar_outlined,
                            size: 15),
                        label: const Text('Remarcar'),
                        style: TextButton.styleFrom(
                          textStyle: GoogleFonts.jost(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  if (a.canCancel && a.canReschedule)
                    Container(
                        width: 1, height: 20, color: AppTheme.divider),
                  if (a.canCancel && onCancel != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => onCancel!(a),
                        icon: const Icon(Icons.cancel_outlined, size: 15),
                        label: const Text('Cancelar'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          textStyle: GoogleFonts.jost(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _monthAbbr(int m) {
    const months = [
      '', 'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
      'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'
    ];
    return months[m];
  }
}
