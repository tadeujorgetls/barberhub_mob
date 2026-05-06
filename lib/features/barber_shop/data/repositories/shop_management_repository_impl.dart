import 'package:barber_hub/features/barber_shop/data/datasources/shop_management_datasource.dart';
import 'package:barber_hub/features/barber_shop/domain/entities/blocked_date_entity.dart';
import 'package:barber_hub/features/barber_shop/domain/entities/shop_settings_entity.dart';
import 'package:barber_hub/features/barber_shop/domain/entities/working_hours_entity.dart';
import 'package:barber_hub/features/barber_shop/domain/repositories/i_shop_management_repository.dart';
import 'package:barber_hub/features/client/data/models/barber_model.dart';
import 'package:barber_hub/features/client/data/models/product_model.dart';
import 'package:barber_hub/shared/mock/mock_data.dart';

class ShopManagementRepositoryImpl implements IShopManagementRepository {
  final ShopManagementDatasource _ds;
  ShopManagementRepositoryImpl(this._ds);

  // ── Settings ──────────────────────────────────────────────────────────────

  @override
  Future<ShopSettingsEntity?> getSettings(String shopId) async {
    final cached = await _ds.loadSettings(shopId);
    if (cached != null) return cached;
    // Bootstrap a partir do mock se não houver dado salvo
    final shop = MockData.barbershops().where((s) => s.id == shopId).firstOrNull;
    if (shop == null) return null;
    return ShopSettingsEntity(
      shopId: shopId,
      name: shop.name,
      address: shop.address,
      phone: shop.phone ?? '',
      workingHours: WorkingHoursEntity.defaultSchedule(),
    );
  }

  @override
  Future<void> saveSettings(ShopSettingsEntity settings) =>
      _ds.saveSettings(settings);

  // ── Barbers ───────────────────────────────────────────────────────────────

  @override
  Future<List<BarberModel>> getBarbers(String shopId) async {
    final cached = await _ds.loadBarbers(shopId);
    if (cached != null) {
      return cached.map((m) => BarberModel(
        id: m['id'] as String,
        name: m['name'] as String,
        specialty: m['specialty'] as String,
        rating: (m['rating'] as num).toDouble(),
        reviewCount: m['reviewCount'] as int? ?? 0,
        avatarInitials: m['avatarInitials'] as String,
        phone: m['phone'] as String? ?? '',
        isActive: m['isActive'] as bool? ?? true,
      )).toList();
    }
    final shop = MockData.barbershops().where((s) => s.id == shopId).firstOrNull;
    return shop?.barbers ?? [];
  }

  @override
  Future<void> addBarber(String shopId, BarberModel barber) async {
    final list = await getBarbers(shopId);
    list.add(barber);
    await _ds.saveBarbers(shopId, list);
  }

  @override
  Future<void> updateBarber(String shopId, BarberModel barber) async {
    final list = await getBarbers(shopId);
    final idx = list.indexWhere((b) => b.id == barber.id);
    if (idx != -1) list[idx] = barber;
    await _ds.saveBarbers(shopId, list);
  }

  // ── Products ──────────────────────────────────────────────────────────────

  @override
  Future<List<ProductModel>> getProducts(String shopId) async {
    final cached = await _ds.loadProducts(shopId);
    if (cached != null) {
      return cached.map((m) {
        final catStr = m['category'] as String? ?? 'pomade';
        final cat = ProductCategory.values.firstWhere(
          (c) => c.name == catStr, orElse: () => ProductCategory.pomade);
        return ProductModel(
          id: m['id'] as String,
          barbershopId: m['barbershopId'] as String,
          name: m['name'] as String,
          description: m['description'] as String,
          price: (m['price'] as num).toDouble(),
          originalPrice: m['originalPrice'] != null ? (m['originalPrice'] as num).toDouble() : null,
          category: cat,
          imageEmoji: m['imageEmoji'] as String? ?? '📦',
          brand: m['brand'] as String? ?? '',
          isFeatured: m['isFeatured'] as bool? ?? false,
          stockQty: m['stockQty'] as int? ?? 0,
        );
      }).toList();
    }
    final shop = MockData.barbershops().where((s) => s.id == shopId).firstOrNull;
    return shop?.products ?? [];
  }

  @override
  Future<void> addProduct(ProductModel product) async {
    final list = await getProducts(product.barbershopId);
    list.add(product);
    await _ds.saveProducts(product.barbershopId, list);
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    final list = await getProducts(product.barbershopId);
    final idx = list.indexWhere((p) => p.id == product.id);
    if (idx != -1) list[idx] = product;
    await _ds.saveProducts(product.barbershopId, list);
  }

  @override
  Future<void> deleteProduct(String shopId, String productId) async {
    final list = await getProducts(shopId);
    list.removeWhere((p) => p.id == productId);
    await _ds.saveProducts(shopId, list);
  }

  // ── Blocked Dates ─────────────────────────────────────────────────────────

  @override
  Future<List<BlockedDateEntity>> getBlockedDates(String shopId) =>
      _ds.loadBlockedDates(shopId);

  @override
  Future<void> addBlockedDate(BlockedDateEntity block) async {
    final list = await getBlockedDates(block.shopId);
    list.add(block);
    await _ds.saveBlockedDates(block.shopId, list);
  }

  @override
  Future<void> removeBlockedDate(String shopId, String blockId) async {
    final list = await getBlockedDates(shopId);
    list.removeWhere((b) => b.id == blockId);
    await _ds.saveBlockedDates(shopId, list);
  }
}
