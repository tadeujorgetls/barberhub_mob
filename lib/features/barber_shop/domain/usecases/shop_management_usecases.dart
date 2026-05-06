/// Barrel de casos de uso de gestão de barbearia.
/// Cada UseCase encapsula uma operação de negócio,
/// desacoplando a UI da camada de dados.
library;

import 'package:barber_hub/features/barber_shop/domain/entities/shop_settings_entity.dart';
import 'package:barber_hub/features/barber_shop/domain/entities/blocked_date_entity.dart';
import 'package:barber_hub/features/barber_shop/domain/repositories/i_shop_management_repository.dart';
import 'package:barber_hub/features/client/data/models/barber_model.dart';
import 'package:barber_hub/features/client/data/models/product_model.dart';

// ── Settings ──────────────────────────────────────────────────────────────────

class GetSettingsUseCase {
  final IShopManagementRepository _repo;
  const GetSettingsUseCase(this._repo);
  Future<ShopSettingsEntity?> call(String shopId) => _repo.getSettings(shopId);
}

class SaveSettingsUseCase {
  final IShopManagementRepository _repo;
  const SaveSettingsUseCase(this._repo);
  Future<void> call(ShopSettingsEntity settings) => _repo.saveSettings(settings);
}

// ── Barbers ───────────────────────────────────────────────────────────────────

class GetBarbersUseCase {
  final IShopManagementRepository _repo;
  const GetBarbersUseCase(this._repo);
  Future<List<BarberModel>> call(String shopId) => _repo.getBarbers(shopId);
}

class AddBarberUseCase {
  final IShopManagementRepository _repo;
  const AddBarberUseCase(this._repo);
  Future<void> call(String shopId, BarberModel barber) =>
      _repo.addBarber(shopId, barber);
}

class UpdateBarberUseCase {
  final IShopManagementRepository _repo;
  const UpdateBarberUseCase(this._repo);
  Future<void> call(String shopId, BarberModel barber) =>
      _repo.updateBarber(shopId, barber);
}

// ── Products ──────────────────────────────────────────────────────────────────

class GetProductsUseCase {
  final IShopManagementRepository _repo;
  const GetProductsUseCase(this._repo);
  Future<List<ProductModel>> call(String shopId) => _repo.getProducts(shopId);
}

class AddProductUseCase {
  final IShopManagementRepository _repo;
  const AddProductUseCase(this._repo);
  Future<void> call(ProductModel product) => _repo.addProduct(product);
}

class UpdateProductUseCase {
  final IShopManagementRepository _repo;
  const UpdateProductUseCase(this._repo);
  Future<void> call(ProductModel product) => _repo.updateProduct(product);
}

class DeleteProductUseCase {
  final IShopManagementRepository _repo;
  const DeleteProductUseCase(this._repo);
  Future<void> call(String shopId, String productId) =>
      _repo.deleteProduct(shopId, productId);
}

// ── Blocked Dates ─────────────────────────────────────────────────────────────

class GetBlockedDatesUseCase {
  final IShopManagementRepository _repo;
  const GetBlockedDatesUseCase(this._repo);
  Future<List<BlockedDateEntity>> call(String shopId) =>
      _repo.getBlockedDates(shopId);
}

class AddBlockedDateUseCase {
  final IShopManagementRepository _repo;
  const AddBlockedDateUseCase(this._repo);
  Future<void> call(BlockedDateEntity block) => _repo.addBlockedDate(block);
}

class RemoveBlockedDateUseCase {
  final IShopManagementRepository _repo;
  const RemoveBlockedDateUseCase(this._repo);
  Future<void> call(String shopId, String blockId) =>
      _repo.removeBlockedDate(shopId, blockId);
}
