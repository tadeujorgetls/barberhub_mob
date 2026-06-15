import 'package:barber_hub/core/services/supabase_service.dart';
import 'package:barber_hub/features/barber_shop/domain/entities/blocked_date_entity.dart';

class SupabaseBlockedDatesDatasource {
  bool get isConfigured => SupabaseService.client != null;

  Future<List<BlockedDateEntity>> loadBlockedDates([String? shopId]) async {
    final client = SupabaseService.client;
    if (client == null) return const [];

    dynamic query = client.from('blocked_dates').select();
    if (shopId != null && shopId.isNotEmpty) {
      query = query.eq('barbershop_id', shopId);
    }

    final response = await query.order('created_at');
    return _rows(response)
        .map(_fromRow)
        .whereType<BlockedDateEntity>()
        .toList();
  }

  Future<void> replaceBlockedDates(
    String shopId,
    List<BlockedDateEntity> blocks,
  ) async {
    final client = SupabaseService.client;
    if (client == null) return;

    await client.from('blocked_dates').delete().eq('barbershop_id', shopId);
    if (blocks.isEmpty) return;

    await client.from('blocked_dates').insert(blocks.map(_toRow).toList());
  }

  BlockedDateEntity? _fromRow(Map<String, dynamic> row) {
    final typeName =
        _string(row['type'], fallback: BlockType.specificDate.name);
    final type = BlockType.values.firstWhere(
      (item) => item.name == typeName,
      orElse: () => BlockType.specificDate,
    );

    return BlockedDateEntity(
      id: _string(row['id']),
      shopId: _string(row['barbershop_id']),
      type: type,
      date: DateTime.tryParse(_string(row['date'])),
      reason: _string(row['reason']),
    );
  }

  Map<String, dynamic> _toRow(BlockedDateEntity block) {
    return {
      'barbershop_id': block.shopId,
      'type': block.type.name,
      'date': block.date == null ? null : _dateOnly(block.date!),
      'reason': block.reason,
    };
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

  String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  String _string(Object? value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString();
    return text.isEmpty ? fallback : text;
  }
}
