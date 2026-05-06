import 'package:barber_hub/features/barber_shop/domain/entities/shop_settings_entity.dart';
import 'package:barber_hub/features/barber_shop/domain/entities/blocked_date_entity.dart';
import 'package:barber_hub/features/client/data/models/barber_model.dart';
import 'package:barber_hub/features/client/data/models/product_model.dart';

/// Contrato do repositório de gestão de barbearia.
/// Projetado para substituição por implementação com API real
/// sem alterar a camada de domínio.
abstract interface class IShopManagementRepository {
  // ── Configurações ─────────────────────────────────────────────────────────
  Future<ShopSettingsEntity?> getSettings(String shopId);
  Future<void> saveSettings(ShopSettingsEntity settings);

  // ── Barbeiros ─────────────────────────────────────────────────────────────
  Future<List<BarberModel>> getBarbers(String shopId);
  Future<void> addBarber(String shopId, BarberModel barber);
  Future<void> updateBarber(String shopId, BarberModel barber);

  // ── Produtos ──────────────────────────────────────────────────────────────
  Future<List<ProductModel>> getProducts(String shopId);
  Future<void> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String shopId, String productId);

  // ── Bloqueios de data ─────────────────────────────────────────────────────
  Future<List<BlockedDateEntity>> getBlockedDates(String shopId);
  Future<void> addBlockedDate(BlockedDateEntity block);
  Future<void> removeBlockedDate(String shopId, String blockId);
}
