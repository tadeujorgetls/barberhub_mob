import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/app_data_provider.dart';
import '../../mock/mock_data.dart';
import '../../models/auth_provider.dart';
import '../../models/barber_model.dart';
import '../../models/service_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  BarberModel? _selectedBarber;
  DateTime? _selectedDate;
  String? _selectedTime;

  // Steps: 0 = barber, 1 = date/time, 2 = confirm
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final service = ModalRoute.of(context)!.settings.arguments as ServiceModel;
    final data = context.watch<AppDataProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
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

            // ── Progress indicator ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _StepIndicator(currentStep: _step),
            ),

            // ── Service summary ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: _ServiceSummaryBar(service: service),
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
                child: _stepWidget(service, data),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepWidget(ServiceModel service, AppDataProvider data) {
    switch (_step) {
      case 0:
        return _BarberStep(
          key: const ValueKey('step0'),
          barbers: data.barbers,
          selected: _selectedBarber,
          onSelect: (b) => setState(() {
            _selectedBarber = b;
          }),
          onNext: () => setState(() => _step = 1),
        );
      case 1:
        return _DateTimeStep(
          key: const ValueKey('step1'),
          selectedDate: _selectedDate,
          selectedTime: _selectedTime,
          onDateSelected: (d) => setState(() => _selectedDate = d),
          onTimeSelected: (t) => setState(() => _selectedTime = t),
          onNext: () => setState(() => _step = 2),
        );
      case 2:
        return _ConfirmStep(
          key: const ValueKey('step2'),
          service: service,
          barber: _selectedBarber!,
          date: _selectedDate!,
          timeSlot: _selectedTime!,
          onConfirm: () => _confirm(service, data),
          isLoading: data.isLoading,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _confirm(ServiceModel service, AppDataProvider data) async {
    final auth = context.read<AuthProvider>();
    await data.bookAppointment(
      clientId: auth.currentUser?.id ?? 'guest',
      clientName: auth.currentUser?.name ?? 'Visitante',
      service: service,
      barber: _selectedBarber!,
      date: _selectedDate!,
      timeSlot: _selectedTime!,
    );

    if (!mounted) return;

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              Text(
                'Agendado!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Seu horário foi confirmado.\nAté lá!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // dialog
                    Navigator.of(context).pop(); // booking
                    Navigator.of(context).pop(); // detail
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

// ── Step Indicator ─────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  const _StepIndicator({required this.currentStep});

  static const _labels = ['Barbeiro', 'Data & Hora', 'Confirmar'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          // connector
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
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Service Summary ────────────────────────────────────────────────────────────
class _ServiceSummaryBar extends StatelessWidget {
  final ServiceModel service;
  const _ServiceSummaryBar({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.inputBorder),
      ),
      child: Row(
        children: [
          Text(
            service.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 14,
                ),
          ),
          const Spacer(),
          Text(
            service.formattedPrice,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.gold,
                  fontSize: 15,
                ),
          ),
          const SizedBox(width: 12),
          Container(height: 14, width: 1, color: AppTheme.divider),
          const SizedBox(width: 12),
          Text(
            service.formattedDuration,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}

// ── Step 0: Barber ─────────────────────────────────────────────────────────────
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
          child: Text(
            'Escolha o barbeiro',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Text(
            'Quem vai te atender hoje?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: barbers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final barber = barbers[i];
              final isSelected = selected?.id == barber.id;
              return GestureDetector(
                onTap: () => onSelect(barber),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.gold.withOpacity(0.06)
                        : AppTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppTheme.gold : AppTheme.inputBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      BarberAvatar(
                          initials: barber.avatarInitials,
                          selected: isSelected),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              barber.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              barber.specialty,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            StarRating(
                                rating: barber.rating,
                                reviewCount: barber.reviewCount),
                          ],
                        ),
                      ),
                      if (isSelected)
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

// ── Step 1: Date & Time ────────────────────────────────────────────────────────
class _DateTimeStep extends StatelessWidget {
  final DateTime? selectedDate;
  final String? selectedTime;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String> onTimeSelected;
  final VoidCallback onNext;

  const _DateTimeStep({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 4),
          child: Text(
            'Data e horário',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Text(
            'Quando você quer ser atendido?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date picker button
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ??
                          DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
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
                        Icon(
                          Icons.calendar_today_outlined,
                          color: selectedDate != null
                              ? AppTheme.gold
                              : AppTheme.textHint,
                          size: 20,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          selectedDate != null
                              ? _formatDate(selectedDate!)
                              : 'Selecionar data',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: MockData.timeSlots.map((slot) {
                      final isSelected = selectedTime == slot;
                      return GestureDetector(
                        onTap: () => onTimeSelected(slot),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.gold.withOpacity(0.12)
                                : AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.gold
                                  : AppTheme.inputBorder,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            slot,
                            style: GoogleFonts.jost(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? AppTheme.gold
                                  : AppTheme.textSecondary,
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

  String _formatDate(DateTime d) {
    const months = [
      '',
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez'
    ];
    const weekdays = [
      '',
      'segunda',
      'terça',
      'quarta',
      'quinta',
      'sexta',
      'sábado',
      'domingo'
    ];
    return '${weekdays[d.weekday]}, ${d.day} de ${months[d.month]} de ${d.year}';
  }
}

// ── Step 2: Confirm ────────────────────────────────────────────────────────────
class _ConfirmStep extends StatelessWidget {
  final ServiceModel service;
  final BarberModel barber;
  final DateTime date;
  final String timeSlot;
  final VoidCallback onConfirm;
  final bool isLoading;

  const _ConfirmStep({
    super.key,
    required this.service,
    required this.barber,
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
          child: Text(
            'Confirmar',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Text(
            'Revise os detalhes do agendamento.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
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
                  value: _formatDate(date),
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
                    border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
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

  String _formatDate(DateTime d) {
    const months = [
      '',
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez'
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 15,
                    ),
              ),
              if (subValue != null)
                Text(
                  subValue!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: AppTheme.gold,
                      ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
