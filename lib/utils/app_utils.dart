import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/appointment_model.dart';

class AppUtils {
  static (Color, Color) statusColors(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return (const Color(0xFF4CAF50), const Color(0xFF4CAF50));
      case AppointmentStatus.completed:
        return (AppTheme.gold, AppTheme.gold);
      case AppointmentStatus.cancelled:
        return (AppTheme.error, AppTheme.error);
    }
  }

  static String formatDateShort(DateTime d) {
    const weekdays = ['', 'seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
    const months = [
      '', 'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return '${weekdays[d.weekday]}, ${d.day} ${months[d.month]}';
  }

  static String formatDateLong(DateTime d) {
    const weekdays = [
      '', 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado', 'domingo'
    ];
    const months = [
      '', 'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return '${weekdays[d.weekday]}, ${d.day} de ${months[d.month]} de ${d.year}';
  }

  static void showSnack(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.warning_amber_rounded
                  : isSuccess
                      ? Icons.check_circle_outline
                      : Icons.info_outline,
              color: isError
                  ? AppTheme.error
                  : isSuccess
                      ? AppTheme.gold
                      : AppTheme.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
