import 'dart:math';
import 'package:barber_hub/core/services/supabase_service.dart';
import 'package:barber_hub/models/barber_model.dart';
import 'package:barber_hub/models/barbershop_model.dart';
import 'package:barber_hub/models/service_model.dart';

class SupabaseCatalogDatasource {
  bool get isConfigured => SupabaseService.client != null;

  Future<void> updateBarbershopInfo({
    required String id,
    required String name,
    required String address,
    required String phone,
  }) async {
    final client = SupabaseService.client;
    if (client == null) return;

    final updatedRows = await client
        .from('barbershops')
        .update({
          'name': name,
          'address': address,
          'phone': phone,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select('id');

    if (updatedRows.isEmpty) {
      throw StateError(
        'Nenhuma barbearia foi atualizada. Verifique o linked_id do perfil e a policy da tabela barbershops.',
      );
    }
  }

  Future<ServiceModel> createService({
    required String barbershopId,
    required ServiceModel service,
  }) async {
    final client = SupabaseService.client;
    if (client == null) return service;

    final row = await client
        .from('services')
        .insert({
          'id': _uuidV4(),
          'barbershop_id': barbershopId,
          'name': service.name,
          'description': service.description,
          'price': service.price,
          'duration_minutes': service.durationMinutes,
          'icon_name': service.iconName,
          'is_active': service.isActive,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select()
        .single();

    return _service(Map<String, dynamic>.from(row as Map));
  }

  Future<ServiceModel> updateService({
    required String serviceId,
    required ServiceModel service,
  }) async {
    final client = SupabaseService.client;
    if (client == null) return service;

    final rows = await client
        .from('services')
        .update({
          'name': service.name,
          'description': service.description,
          'price': service.price,
          'duration_minutes': service.durationMinutes,
          'icon_name': service.iconName,
          'is_active': service.isActive,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', serviceId)
        .select();

    if (rows.isEmpty) {
      throw StateError('Nenhum serviço foi atualizado no Supabase.');
    }

    return _service(Map<String, dynamic>.from(rows.first as Map));
  }

  Future<void> deactivateService(String serviceId) async {
    final client = SupabaseService.client;
    if (client == null) return;

    final rows = await client
        .from('services')
        .update({
          'is_active': false,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', serviceId)
        .select('id');

    if (rows.isEmpty) {
      throw StateError('Nenhum serviço foi desativado no Supabase.');
    }
  }

  String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String hex(int value) => value.toRadixString(16).padLeft(2, '0');
    final chars = bytes.map(hex).join();
    return '${chars.substring(0, 8)}-${chars.substring(8, 12)}-${chars.substring(12, 16)}-${chars.substring(16, 20)}-${chars.substring(20)}';
  }

  Future<List<BarbershopModel>> loadBarbershops() async {
    final client = SupabaseService.client;
    if (client == null) return const [];

    final results = await Future.wait([
      client.from('barbershops').select().order('name'),
      client.from('services').select().order('name'),
      client.from('barbers').select().order('name'),
      client.from('products').select().order('name'),
    ]);

    final shopRows = _rows(results[0]);
    final serviceRows = _rows(results[1]);
    final barberRows = _rows(results[2]);
    final productRows = _rows(results[3]);

    if (shopRows.isEmpty) return const [];

    final servicesByShop = <String, List<ServiceModel>>{};
    for (final row in serviceRows) {
      final shopId = _string(row['barbershop_id']);
      if (shopId.isEmpty) continue;
      servicesByShop.putIfAbsent(shopId, () => []).add(_service(row));
    }

    final barbersByShop = <String, List<BarberModel>>{};
    for (final row in barberRows) {
      final shopId = _string(row['barbershop_id']);
      if (shopId.isEmpty) continue;
      barbersByShop.putIfAbsent(shopId, () => []).add(_barber(row));
    }

    final productsByShop = <String, List<ProductModel>>{};
    for (final row in productRows) {
      final shopId = _string(row['barbershop_id']);
      if (shopId.isEmpty) continue;
      productsByShop.putIfAbsent(shopId, () => []).add(_product(row));
    }

    return shopRows.map((row) {
      final id = _string(row['id']);
      return BarbershopModel(
        id: id,
        name: _string(row['name'], fallback: 'Barbearia'),
        address: _string(row['address'], fallback: 'Endereco nao informado'),
        rating: _double(row['rating']),
        reviewCount: _int(row['review_count']),
        imageUrl: _string(row['image_url']),
        coverEmoji: _string(row['cover_emoji'], fallback: 'scissors'),
        description: _nullableString(row['description']),
        phone: _nullableString(row['phone']),
        isOpen: _bool(row['is_open'], fallback: true),
        services: servicesByShop[id] ?? [],
        barbers: barbersByShop[id] ?? [],
        products: productsByShop[id] ?? [],
      );
    }).toList();
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

  ServiceModel _service(Map<String, dynamic> row) {
    return ServiceModel(
      id: _string(row['id']),
      name: _string(row['name'], fallback: 'Servico'),
      description: _string(row['description']),
      price: _double(row['price']),
      durationMinutes: _int(row['duration_minutes'], fallback: 30),
      iconName: _string(row['icon_name'], fallback: 'cut'),
      isActive: _bool(row['is_active'], fallback: true),
    );
  }

  BarberModel _barber(Map<String, dynamic> row) {
    final name = _string(row['name'], fallback: 'Barbeiro');
    return BarberModel(
      id: _string(row['id']),
      name: name,
      specialty: _string(row['specialty']),
      rating: _double(row['rating']),
      reviewCount: _int(row['review_count']),
      avatarInitials: _string(
        row['avatar_initials'],
        fallback: _initials(name),
      ),
      phone: _string(row['phone']),
      isActive: _bool(row['is_active'], fallback: true),
    );
  }

  ProductModel _product(Map<String, dynamic> row) {
    final categoryName = _string(row['category'], fallback: 'pomade');
    final category = ProductCategory.values.firstWhere(
      (item) => item.name == categoryName,
      orElse: () => ProductCategory.pomade,
    );

    return ProductModel(
      id: _string(row['id']),
      barbershopId: _string(row['barbershop_id']),
      name: _string(row['name'], fallback: 'Produto'),
      description: _string(row['description']),
      price: _double(row['price']),
      originalPrice:
          row['original_price'] == null ? null : _double(row['original_price']),
      category: category,
      imageEmoji: _string(row['image_emoji'], fallback: category.name),
      brand: _string(row['brand']),
      isAvailable: _bool(row['is_available'], fallback: true),
      isFeatured: _bool(row['is_featured']),
      stockQty: _int(row['stock'] ?? row['stock_qty'], fallback: 99),
    );
  }

  String _string(Object? value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString();
    return text.isEmpty ? fallback : text;
  }

  String? _nullableString(Object? value) {
    final text = _string(value);
    return text.isEmpty ? null : text;
  }

  double _double(Object? value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  int _int(Object? value, {int fallback = 0}) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  bool _bool(Object? value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    if (text == 'true') return true;
    if (text == 'false') return false;
    return fallback;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
