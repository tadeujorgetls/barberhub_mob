import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/app_data_provider.dart';
import '../../models/appointment_model.dart';
import '../../mock/mock_data.dart';
import '../../models/barber_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_widgets.dart';

class RescheduleSheet extends StatefulWidget {
  final AppointmentModel appointment;
  final AppDataProvider data;

  const RescheduleSheet({
    super.key,
    required this.appointment,
    required this.data,
  });

  @override
  State<RescheduleSheet> createState() => _RescheduleSheetState();
}

class _RescheduleSheetState extends State<RescheduleSheet> {
  late BarberModel _selectedBarber;
  DateTime? _selectedDate;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedBarber = widget.appointment.barber;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: AppTheme.divider)),
          ),
          child: Column(
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Text(
                      'Remarcar',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppTheme.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                child: Text(
                  widget.appointment.service.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.gold,
                      ),
                ),
              ),
              const Divider(height: 1),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barber selection
                      const SectionHeader(title: 'Barbeiro'),
                      const SizedBox(height: 12),
                      ...widget.data.barbers.map((b) {
                        final sel = _selectedBarber.id == b.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedBarber = b),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppTheme.gold.withOpacity(0.06)
                                    : AppTheme.surfaceElevated,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: sel
                                      ? AppTheme.gold
                                      : AppTheme.inputBorder,
                                  width: sel ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  BarberAvatar(
                                      initials: b.avatarInitials,
                                      size: 40,
                                      selected: sel),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(b.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(fontSize: 14)),
                                        Text(b.specialty,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  if (sel)
                                    const Icon(Icons.check_circle_rounded,
                                        color: AppTheme.gold, size: 18),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 20),

                      // Date picker
                      const SectionHeader(title: 'Nova data'),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.now().add(const Duration(days: 1)),
                            firstDate:
                                DateTime.now().add(const Duration(days: 1)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 60)),
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
                          if (picked != null) {
                            setState(() {
                              _selectedDate = picked;
                              _selectedTime = null;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedDate != null
                                  ? AppTheme.gold
                                  : AppTheme.inputBorder,
                              width: _selectedDate != null ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                color: _selectedDate != null
                                    ? AppTheme.gold
                                    : AppTheme.textHint,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate != null
                                    ? _formatDate(_selectedDate!)
                                    : 'Selecionar nova data',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: _selectedDate != null
                                          ? AppTheme.textPrimary
                                          : AppTheme.textHint,
                                      fontSize: 14,
                                    ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppTheme.textHint, size: 18),
                            ],
                          ),
                        ),
                      ),

                      if (_selectedDate != null) ...[
                        const SizedBox(height: 20),
                        const SectionHeader(title: 'Novo horário'),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: MockData.timeSlots.map((slot) {
                            final sel = _selectedTime == slot;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedTime = slot),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppTheme.gold.withOpacity(0.12)
                                      : AppTheme.surfaceElevated,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: sel
                                        ? AppTheme.gold
                                        : AppTheme.inputBorder,
                                    width: sel ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  slot,
                                  style: GoogleFonts.jost(
                                    fontSize: 13,
                                    fontWeight:
                                        sel ? FontWeight.w600 : FontWeight.w400,
                                    color: sel
                                        ? AppTheme.gold
                                        : AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Confirm button
              Padding(
                padding: EdgeInsets.fromLTRB(
                    24, 12, 24, 12 + MediaQuery.of(context).viewPadding.bottom),
                child: PrimaryButton(
                  label: 'Confirmar remarcação',
                  isLoading: widget.data.isLoading,
                  onPressed: (_selectedDate != null && _selectedTime != null)
                      ? _confirm
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirm() async {
    final result = await widget.data.rescheduleAppointment(
      id: widget.appointment.id,
      newDate: _selectedDate!,
      newTimeSlot: _selectedTime!,
      newBarber: _selectedBarber,
    );

    if (!mounted) return;
    Navigator.pop(context);

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: AppTheme.gold, size: 16),
              const SizedBox(width: 10),
              Text('Remarcado para ${result.timeSlot}'),
            ],
          ),
        ),
      );
    }
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
