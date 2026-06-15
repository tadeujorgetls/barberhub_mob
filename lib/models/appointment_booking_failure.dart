enum AppointmentBookingFailure {
  notAuthenticated,
  pastDate,
  blockedDate,
  slotUnavailable,
  unauthorized,
  network,
  unknown,
}

class AppointmentBookingException implements Exception {
  final AppointmentBookingFailure failure;
  final Object? cause;

  const AppointmentBookingException(this.failure, {this.cause});

  @override
  String toString() => 'AppointmentBookingException($failure)';
}
