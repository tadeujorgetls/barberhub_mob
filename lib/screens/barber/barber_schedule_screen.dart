import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/app_data_provider.dart';
import '../../models/appointment_model.dart';
import '../../models/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../widgets/app_widgets.dart';

class BarberScheduleScreen extends StatefulWidget {
  const BarberScheduleScreen({super.key});

  @override
  State<BarberScheduleScreen> createState() => _BarberScheduleScreenState();
}

class _BarberScheduleScreenState extends State<BarberScheduleScreen>
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
    final auth = context.watch<AuthProvider>();
    final data = context.watch<AppDataProvider>();
    final barberId = auth.linkedBarberId ?? '';
    final today = data.todayForBarber(barberId);
    final all = data.appointmentsForBarber(barberId);
    final upcoming =
        all.where((a) => a.status == AppointmentStatus.scheduled).toList();
    final history = all
        .where((a) => a.status != AppointmentStatus.scheduled)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -80,
            child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppTheme.gold.withOpacity(.05),
                      Colors.transparent
                    ]))),
          ),
          SafeArea(
            child: Column(children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(children: [
                  const Expanded(
                      child: ScreenHeader(
                          eyebrow: 'BARBEIRO', title: 'Minha Agenda')),
                  _TodayBadge(count: today.length),
                ]),
              ),

              // Today summary
              if (today.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _TodaySummary(appointments: today),
                ),

              const SizedBox(height: 16),

              // Tab bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.inputBorder)),
                  child: TabBar(
                    controller: _tab,
                    indicator: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(5)),
                    indicatorPadding: const EdgeInsets.all(3),
                    labelStyle: GoogleFonts.jost(
                        fontSize: 12, fontWeight: FontWeight.w700),
                    unselectedLabelStyle: GoogleFonts.jost(fontSize: 12),
                    labelColor: AppTheme.background,
                    unselectedLabelColor: AppTheme.textSecondary,
                    tabs: [
                      Tab(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            const Text('Próximos'),
                            if (upcoming.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              _CountDot(upcoming.length)
                            ],
                          ])),
                      const Tab(text: 'Histórico'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _ScheduleList(
                      appointments: upcoming,
                      emptyTitle: 'Sem atendimentos',
                      emptySubtitle: 'Nenhum agendamento pendente.',
                      onStatusChange: (id, status) =>
                          _updateStatus(context, data, id, status),
                    ),
                    _ScheduleList(
                      appointments: history,
                      emptyTitle: 'Histórico vazio',
                      emptySubtitle:
                          'Seus atendimentos concluídos\naparecerão aqui.',
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
    BuildContext context,
    AppDataProvider data,
    String id,
    AppointmentStatus status,
  ) async {
    if (status == AppointmentStatus.cancelled) {
      final confirmed = await _confirmDialog(context, id);
      if (!confirmed) return;
    }
    await data.updateAppointmentStatus(id, status);
    if (context.mounted) {
      final label = status == AppointmentStatus.completed
          ? 'Atendimento concluído!'
          : 'Atendimento cancelado.';
      AppUtils.showSnack(context, label,
          isSuccess: status == AppointmentStatus.completed,
          isError: status == AppointmentStatus.cancelled);
    }
  }

  Future<bool> _confirmDialog(BuildContext context, String id) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.surfaceElevated,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Text('Cancelar atendimento',
                style: Theme.of(context).textTheme.titleLarge),
            content: Text('Confirmar cancelamento deste atendimento?',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(height: 1.5)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Não')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _TodayBadge extends StatelessWidget {
  final int count;
  const _TodayBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.gold.withOpacity(.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gold.withOpacity(.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.today_rounded, color: AppTheme.gold, size: 14),
        const SizedBox(width: 6),
        Text('$count hoje',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.gold, fontSize: 11, letterSpacing: 1)),
      ]),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  final List<AppointmentModel> appointments;
  const _TodaySummary({required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.gold.withOpacity(.12),
          AppTheme.gold.withOpacity(.04)
        ]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.gold.withOpacity(.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.wb_sunny_outlined, color: AppTheme.gold, size: 14),
          const SizedBox(width: 8),
          Text('HOJE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.gold, fontSize: 10, letterSpacing: 3)),
        ]),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: appointments
                .map((a) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.inputBorder)),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.timeSlot,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          color: AppTheme.gold, fontSize: 15)),
                              const SizedBox(height: 2),
                              Text(a.clientName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          fontSize: 12,
                                          color: AppTheme.textPrimary)),
                              Text(a.service.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontSize: 11)),
                            ]),
                      ),
                    ))
                .toList(),
          ),
        ),
      ]),
    );
  }
}

class _ScheduleList extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final String emptyTitle, emptySubtitle;
  final void Function(String, AppointmentStatus)? onStatusChange;

  const _ScheduleList({
    required this.appointments,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return EmptyState(
          icon: Icons.calendar_today_outlined,
          title: emptyTitle,
          subtitle: emptySubtitle);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: appointments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final a = appointments[i];
        return AppointmentCard(
          appointment: a,
          showClient: true,
          showBarber: false,
          onStatusChange: onStatusChange != null
              ? (status) => onStatusChange!(a.id, status)
              : null,
          onCancel: onStatusChange != null && a.canCancel
              ? () => onStatusChange!(a.id, AppointmentStatus.cancelled)
              : null,
        );
      },
    );
  }
}

class _CountDot extends StatelessWidget {
  final int count;
  const _CountDot(this.count);

  @override
  Widget build(BuildContext context) => Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: AppTheme.goldDark),
        child: Center(
            child: Text('$count',
                style: GoogleFonts.jost(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary))),
      );
}
