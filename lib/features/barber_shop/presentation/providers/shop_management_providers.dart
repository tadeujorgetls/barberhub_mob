library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_hub/features/barber_shop/data/datasources/shop_management_datasource.dart';
import 'package:barber_hub/features/barber_shop/data/repositories/shop_management_repository_impl.dart';
import 'package:barber_hub/features/barber_shop/domain/repositories/i_shop_management_repository.dart';
import 'package:barber_hub/features/barber_shop/domain/usecases/shop_management_usecases.dart';
import 'shop_management_notifier.dart';
import 'shop_management_state.dart';

export 'shop_management_state.dart';
export 'shop_management_notifier.dart';

// ── Infra ──────────────────────────────────────────────────────────────────
final _shopDatasourceProvider = Provider((_) => ShopManagementDatasource());

final shopManagementRepositoryProvider = Provider<IShopManagementRepository>(
  (ref) => ShopManagementRepositoryImpl(ref.read(_shopDatasourceProvider)),
);

// ── Use Cases ──────────────────────────────────────────────────────────────
final _ucGetSettings    = Provider((ref) => GetSettingsUseCase(ref.read(shopManagementRepositoryProvider)));
final _ucSaveSettings   = Provider((ref) => SaveSettingsUseCase(ref.read(shopManagementRepositoryProvider)));
final _ucGetBarbers     = Provider((ref) => GetBarbersUseCase(ref.read(shopManagementRepositoryProvider)));
final _ucAddBarber      = Provider((ref) => AddBarberUseCase(ref.read(shopManagementRepositoryProvider)));
final _ucUpdateBarber   = Provider((ref) => UpdateBarberUseCase(ref.read(shopManagementRepositoryProvider)));
final _ucGetProducts    = Provider((ref) => GetProductsUseCase(ref.read(shopManagementRepositoryProvider)));
final _ucAddProduct     = Provider((ref) => AddProductUseCase(ref.read(shopManagementRepositoryProvider)));
final _ucUpdateProduct  = Provider((ref) => UpdateProductUseCase(ref.read(shopManagementRepositoryProvider)));
final _ucDeleteProduct  = Provider((ref) => DeleteProductUseCase(ref.read(shopManagementRepositoryProvider)));
final _ucGetBlocked     = Provider((ref) => GetBlockedDatesUseCase(ref.read(shopManagementRepositoryProvider)));
final _ucAddBlocked     = Provider((ref) => AddBlockedDateUseCase(ref.read(shopManagementRepositoryProvider)));
final _ucRemoveBlocked  = Provider((ref) => RemoveBlockedDateUseCase(ref.read(shopManagementRepositoryProvider)));

// ── Notifier principal ────────────────────────────────────────────────────
final shopManagementProvider =
    StateNotifierProvider<ShopManagementNotifier, ShopManagementState>((ref) {
  return ShopManagementNotifier(
    ref: ref,
    getSettings: ref.read(_ucGetSettings),
    saveSettings: ref.read(_ucSaveSettings),
    getBarbers: ref.read(_ucGetBarbers),
    addBarber: ref.read(_ucAddBarber),
    updateBarber: ref.read(_ucUpdateBarber),
    getProducts: ref.read(_ucGetProducts),
    addProduct: ref.read(_ucAddProduct),
    updateProduct: ref.read(_ucUpdateProduct),
    deleteProduct: ref.read(_ucDeleteProduct),
    getBlockedDates: ref.read(_ucGetBlocked),
    addBlockedDate: ref.read(_ucAddBlocked),
    removeBlockedDate: ref.read(_ucRemoveBlocked),
  );
});
