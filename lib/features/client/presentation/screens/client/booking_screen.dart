import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_hub/features/barber_shop/presentation/providers/shop_management_providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:barber_hub/features/client/presentation/providers/app_data_provider.dart';
import 'package:barber_hub/shared/mock/mock_data.dart';
import 'package:barber_hub/features/auth/presentation/providers/auth_providers.dart';
import 'package:barber_hub/features/client/data/models/barber_model.dart';
import 'package:barber_hub/features/client/data/models/barbershop_model.dart';
import 'package:barber_hub/features/client/data/models/service_model.dart';
import 'package:barber_hub/core/theme/app_theme.dart';
import 'package:barber_hub/shared/widgets/app_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BookingScreen
// Recebe via arguments: Map{'service': ServiceModel, 'barbershop': BarbershopModel}
// ─────────────────────────────────────────────────────────────────────────────
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  BarberModel? _selectedBarber;
  DateTime? _selectedDate;
  String? _selectedTime;
  int _step = 0; // 0=barbeiro, 1=data/hora, 2=confirmar

  /// Parse seguro dos arguments. Garante que barbershop sempre vem
  /// de uma barbearia real (args ou provider).
  (ServiceModel service, BarbershopModel barbershop) _parseArgs(
      Object? args, AppDataProvider data) {
    ServiceModel? service;
    BarbershopModel? barbershop;

    if (args is Map) {
      service = args['service'] as ServiceModel?;
      barbershop = args['barbershop'] as BarbershopModel?;
    } else if (args is ServiceModel) {
      service = args;
    }

    // Fallback para provider se não vier via args
    barbershop ??= data.selectedBarbershop ?? data.barbershops.first;

    if (service == null) {
      throw StateError('BookingScreen requer um ServiceModel nos arguments.');
    }

    return (service, barbershop);
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AppDataProvider>();
    final args = ModalRoute.of(context)!.settings.arguments;
    final (service, barbershop) = _parseArgs(args, data);

    // Barbeiros APENAS da barbearia em questão
    final barbers =
        barbershop.barbers.where((b) => b.isActive).toList();

    // Horários já ocupados para o barbeiro/data selecionados
    final bookedSlots = (_selectedBarber != null && _selectedDate != null)
        ? data.bookedSlotsFor(_selectedBarber!.id, _selectedDate!)
        : <String>{};

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: AppTheme.textSecondary),
                    onPressed: () {
                      if (_step > 0) {
                        setState(() => _step--);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  const Spacer(),
                  Text(
                    'AGENDAMENTO',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.textHint,
                          fontSize: 11,
                          letterSpacing: 3,
                        ),
                  ),
                ],
              ),
            ),

            // ── Step indicator ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _StepIndicator(currentStep: _step),
            ),

            // ── Service + Barbershop summary ───────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: _BookingSummaryBar(
                service: service,
                barbershopName: barbershop.name,
              ),
            ),

            const SizedBox(height: 4),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _buildStep(
                  service: service,
                  barbershop: barbershop,
                  barbers: barbers,
                  bookedSlots: bookedSlots,
                  data: data,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required ServiceModel service,
    required BarbershopModel barbershop,
    required List<BarberModel> barbers,
    required Set<String> bookedSlots,
    required AppDataProvider data,
  }) {
    switch (_step) {
      case 0:
        return _BarberStep(
          key: const ValueKey('step0'),
          barbers: barbers,
          selected: _selectedBarber,
          onSelect: (b) => setState(() => _selectedBarber = b),
          onNext: () => setState(() => _step = 1),
        );
      case 1:
        // Carrega bloqueios de datas da barbearia selecionada
        final shopMgmt = ref.read(shopManagementProvider);
        final blocked = shopMgmt.blockedDates;
        // Converte bloqueios em lista de strings 'ano-mes-dia' para o predicate
        final blockedKeys = <String>[];
        final now = DateTime.now();
        for (var i = 1; i <= 60; i++) {
          final day = now.add(Duration(days: i));
          if (blocked.any((b) => b.shopId == barbershop.id && b.blocks(day))) {
            blockedKeys.add('${day.year}-${day.month}-${day.day}');
          }
        }
        return _DateTimeStep(
          key: const ValueKey('step1'),
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          bookedSlots: bookedSlots,
          blockedShopIds: blockedKeys,
          onDateSelected: (d) =>
              setState(() {
                _selectedDate = d;
                _selectedTime = null; // reset horário ao trocar data
              }),
          onTimeSelected: (t) => setState(() => _selectedTime = t),
          onNext: () => setState(() => _step = 2),
        );
      case 2:
        return _ConfirmStep(
          key: const ValueKey('step2'),
          service: service,
          barber: _selectedBarber!,
          barbershop: barbershop,
          date: _selectedDate!,
          timeSlot: _selectedTime!,
          onConfirm: () => _confirm(service, barbershop, data),
          isLoading: data.isLoading,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _confirm(
    ServiceModel service,
    BarbershopModel barbershop,
    AppDataProvider data,
  ) async {
    final authState = ref.read(authNotifierProvider);
    final authUser = authState is AuthAuthenticated ? authState.user : null;
    try {
      await data.bookAppointment(
        clientId: authUser?.id ?? 'guest',
        clientName: authUser?.name ?? 'Visitante',
        service: service,
        barber: _selectedBarber!,
        barbershop: barbershop,
        date: _selectedDate!,
        timeSlot: _selectedTime!,
      );
      if (!mounted) return;
      _showSuccessDialog(barbershop.name);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.error,
          content: Text('Erro: ${e.toString()}'),
        ),
      );
    }
  }

  void _showSuccessDialog(String barbershopName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.gold.withOpacity(0.12),
                  border: Border.all(
                      color: AppTheme.gold.withOpacity(0.3), width: 2),
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppTheme.gold, size: 36),
              ),
              const SizedBox(height: 20),
              Text('Agendado!',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Seu horário em\n$barbershopName\nfoi confirmado!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('VER AGENDAMENTOS'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Voltar ao início'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  static const _labels = ['Barbeiro', 'Data & Hora', 'Confirmar'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          final active = currentStep > stepIndex;
          return Expanded(
            child: Container(
              height: 1.5,
              color: active ? AppTheme.gold : AppTheme.divider,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final active = stepIndex <= currentStep;
        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active
                    ? AppTheme.gold.withOpacity(0.15)
                    : AppTheme.surfaceElevated,
                border: Border.all(
                  color: active ? AppTheme.gold : AppTheme.inputBorder,
                  width: active ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  '${stepIndex + 1}',
                  style: GoogleFonts.jost(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? AppTheme.gold : AppTheme.textHint,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _labels[stepIndex],
              style: GoogleFonts.jost(
                fontSize: 10,
                color: active ? AppTheme.gold : AppTheme.textHint,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Booking summary bar ───────────────────────────────────────────────────────
class _BookingSummaryBar extends StatelessWidget {
  final ServiceModel service;
  final String barbershopName;
  const _BookingSummaryBar(
      {required this.service, required this.barbershopName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_outlined,
                  size: 11, color: AppTheme.gold),
              const SizedBox(width: 5),
              Text(
                barbershopName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      color: AppTheme.gold.withOpacity(0.85),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  service.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 14),
                ),
              ),
              Text(
                service.formattedPrice,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.gold, fontSize: 15),
              ),
              const SizedBox(width: 12),
              Container(height: 14, width: 1, color: AppTheme.divider),
              const SizedBox(width: 12),
              Text(
                service.formattedDuration,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Step 0: Barber ────────────────────────────────────────────────────────────
class _BarberStep extends StatelessWidget {
  final List<BarberModel> barbers;
  final BarberModel? selected;
  final ValueChanged<BarberModel> onSelect;
  final VoidCallback onNext;

  const _BarberStep({
    super.key,
    required this.barbers,
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
          child: Text('Escolha o barbeiro',
              style: Theme.of(context).textTheme.headlineMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Text('Quem vai te atender hoje?',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: barbers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final barber = barbers[i];
              final isSel = selected?.id == barber.id;
              return GestureDetector(
                onTap: () => onSelect(barber),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppTheme.gold.withOpacity(0.06)
                        : AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSel ? AppTheme.gold : AppTheme.inputBorder,
                      width: isSel ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      BarberAvatar(
                          initials: barber.avatarInitials, selected: isSel),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(barber.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontSize: 15)),
                            const SizedBox(height: 3),
                            Text(barber.specialty,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontSize: 12)),
                            const SizedBox(height: 6),
                            StarRating(
                                rating: barber.rating,
                                reviewCount: barber.reviewCount),
                          ],
                        ),
                      ),
                      if (isSel)
                        const Icon(Icons.check_circle_rounded,
                            color: AppTheme.gold, size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: PrimaryButton(
            label: 'Próximo',
            onPressed: selected != null ? onNext : null,
          ),
        ),
      ],
    );
  }
}

// ── Step 1: Data & Hora ───────────────────────────────────────────────────────
class _DateTimeStep extends StatelessWidget {
  final DateTime? selectedDate;
  final String? selectedTime;
  final Set<String> bookedSlots;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String> onTimeSelected;
  final VoidCallback onNext;
  final List<String> blockedShopIds;

  const _DateTimeStep({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.bookedSlots,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.onNext,
    this.blockedShopIds = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
          child: Text('Data e horário',
              style: Theme.of(context).textTheme.headlineMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Text('Quando você quer ser atendido?',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date picker
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ??
                          DateTime.now().add(const Duration(days: 1)),
                      firstDate:
                          DateTime.now().add(const Duration(days: 1)),
                      lastDate:
                          DateTime.now().add(const Duration(days: 60)),
                      selectableDayPredicate: (day) => !blockedShopIds.contains(
                          '${day.year}-${day.month}-${day.day}'),
                      builder: (ctx, child) => Theme(
                        data: Theme.of(ctx).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppTheme.gold,
                            onPrimary: AppTheme.background,
                            surface: AppTheme.surfaceElevated,
                            onSurface: AppTheme.textPrimary,
                          ),
                          dialogTheme: const DialogThemeData(
                              backgroundColor: AppTheme.surface),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) onDateSelected(picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selectedDate != null
                            ? AppTheme.gold
                            : AppTheme.inputBorder,
                        width: selectedDate != null ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            color: selectedDate != null
                                ? AppTheme.gold
                                : AppTheme.textHint,
                            size: 20),
                        const SizedBox(width: 14),
                        Text(
                          selectedDate != null
                              ? _fmt(selectedDate!)
                              : 'Selecionar data',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: selectedDate != null
                                    ? AppTheme.textPrimary
                                    : AppTheme.textHint,
                                fontSize: 15,
                              ),
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppTheme.textHint, size: 20),
                      ],
                    ),
                  ),
                ),

                if (selectedDate != null) ...[
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Horários disponíveis'),
                  const SizedBox(height: 6),
                  if (bookedSlots.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 12, color: AppTheme.textHint),
                          const SizedBox(width: 5),
                          Text(
                            'Horários indisponíveis estão acinzentados.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    fontSize: 11,
                                    color: AppTheme.textHint),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: MockData.timeSlots.map((slot) {
                      final isSel = selectedTime == slot;
                      final isBooked = bookedSlots.contains(slot);
                      return GestureDetector(
                        onTap: isBooked
                            ? null
                            : () => onTimeSelected(slot),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isBooked
                                ? AppTheme.surface
                                : isSel
                                    ? AppTheme.gold.withOpacity(0.12)
                                    : AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isBooked
                                  ? AppTheme.divider
                                  : isSel
                                      ? AppTheme.gold
                                      : AppTheme.inputBorder,
                              width: isSel ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            slot,
                            style: GoogleFonts.jost(
                              fontSize: 14,
                              fontWeight: isSel
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isBooked
                                  ? AppTheme.textHint
                                  : isSel
                                      ? AppTheme.gold
                                      : AppTheme.textSecondary,
                              decoration: isBooked
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: PrimaryButton(
            label: 'Próximo',
            onPressed:
                (selectedDate != null && selectedTime != null) ? onNext : null,
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime d) {
    const months = [
      '', 'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    const weekdays = [
      '', 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado', 'domingo'
    ];
    return '${weekdays[d.weekday]}, ${d.day} de ${months[d.month]} de ${d.year}';
  }
}

// ── Step 2: Confirmar ─────────────────────────────────────────────────────────
class _ConfirmStep extends StatelessWidget {
  final ServiceModel service;
  final BarberModel barber;
  final BarbershopModel barbershop;
  final DateTime date;
  final String timeSlot;
  final VoidCallback onConfirm;
  final bool isLoading;

  const _ConfirmStep({
    super.key,
    required this.service,
    required this.barber,
    required this.barbershop,
    required this.date,
    required this.timeSlot,
    required this.onConfirm,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
          child: Text('Confirmar',
              style: Theme.of(context).textTheme.headlineMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Text('Revise os detalhes do agendamento.',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _ConfirmRow(
                  icon: Icons.storefront_outlined,
                  label: 'Barbearia',
                  value: barbershop.name,
                  subValue: barbershop.address,
                ),
                const SizedBox(height: 12),
                _ConfirmRow(
                  icon: Icons.content_cut_rounded,
                  label: 'Serviço',
                  value: service.name,
                  subValue: service.formattedPrice,
                ),
                const SizedBox(height: 12),
                _ConfirmRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Barbeiro',
                  value: barber.name,
                  subValue: barber.specialty,
                ),
                const SizedBox(height: 12),
                _ConfirmRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Data',
                  value: _fmtDate(date),
                  subValue: null,
                ),
                const SizedBox(height: 12),
                _ConfirmRow(
                  icon: Icons.schedule_outlined,
                  label: 'Horário',
                  value: timeSlot,
                  subValue: service.formattedDuration,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: AppTheme.gold.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppTheme.gold, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Chegue 5 minutos antes do horário marcado.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: PrimaryButton(
            label: 'Confirmar agendamento',
            onPressed: onConfirm,
            isLoading: isLoading,
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      '', 'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return '${d.day} de ${months[d.month]} de ${d.year}';
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;

  const _ConfirmRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.gold, size: 18),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11, letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 15),
                ),
                if (subValue != null)
                  Text(
                    subValue!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12, color: AppTheme.gold),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
