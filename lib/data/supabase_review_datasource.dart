import 'package:barber_hub/core/services/supabase_service.dart';
import 'package:barber_hub/models/appointment_model.dart';

class SupabaseReviewDatasource {
  bool get isConfigured => SupabaseService.client != null;

  Future<List<ReviewModel>> loadReviews() async {
    final client = SupabaseService.client;
    if (client == null) return const [];

    try {
      final response = await client
          .from('reviews')
          .select()
          .order('created_at', ascending: false);

      return _rows(response)
          .map(_reviewFromRow)
          .whereType<ReviewModel>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<ReviewModel> createReview({
    required AppointmentModel appointment,
    required int rating,
    String? comment,
  }) async {
    final client = SupabaseService.client;
    if (client == null) {
      throw StateError('Supabase nao configurado para avaliacoes.');
    }

    final cleanComment = comment?.trim();
    final row = await client
        .from('reviews')
        .insert({
          'appointment_id': appointment.id,
          'client_id': appointment.clientId,
          'client_name': appointment.clientName,
          'barbershop_id': appointment.barbershop.id,
          'barbershop_name': appointment.barbershop.name,
          'barber_id': appointment.barber.id,
          'barber_name': appointment.barber.name,
          'service_name': appointment.service.name,
          'rating': rating,
          'comment': cleanComment == null || cleanComment.isEmpty
              ? null
              : cleanComment,
        })
        .select()
        .single();

    return _reviewFromRow(Map<String, dynamic>.from(row))!;
  }

  List<Map<String, dynamic>> _rows(Object? value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .toList();
    }
    return const [];
  }

  ReviewModel? _reviewFromRow(Map<String, dynamic> row) {
    final createdAt = DateTime.tryParse(_string(row['created_at']));
    final rating = _int(row['rating']);
    if (createdAt == null || rating < 1 || rating > 5) return null;

    return ReviewModel(
      id: _string(row['id']),
      appointmentId: _string(row['appointment_id']),
      clientId: _string(row['client_id']),
      clientName: _string(row['client_name'], fallback: 'Cliente'),
      barbershopId: _string(row['barbershop_id']),
      barbershopName: _string(row['barbershop_name']),
      barberId: _string(row['barber_id']),
      barberName: _string(row['barber_name']),
      serviceName: _string(row['service_name']),
      rating: rating,
      comment: _nullableString(row['comment']),
      createdAt: createdAt,
    );
  }

  int _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _string(Object? value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString();
    return text.isEmpty ? fallback : text;
  }

  String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
