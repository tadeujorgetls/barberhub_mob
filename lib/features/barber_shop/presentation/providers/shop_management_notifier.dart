import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barber_hub/features/auth/presentation/providers/auth_providers.dart';
import 'package:barber_hub/features/barber_shop/domain/entities/blocked_date_entity.dart';
import 'package:barber_hub/features/barber_shop/domain/entities/shop_settings_entity.dart';
import 'package:barber_hub/features/barber_shop/domain/usecases/shop_management_usecases.dart';
import 'package:barber_hub/features/client/data/models/barber_model.dart';
import 'package:barber_hub/features/client/data/models/product_model.dart';
import 'shop_management_state.dart';

class ShopManagementNotifier extends StateNotifier<ShopManagementState> {
  final Ref _ref;
  final GetSettingsUseCase _getSettings;
  final SaveSettingsUseCase _saveSettings;
  final GetBarbersUseCase _getBarbers;
  final AddBarberUseCase _addBarber;
  final UpdateBarberUseCase _updateBarber;
  final GetProductsUseCase _getProducts;
  final AddProductUseCase _addProduct;
  final UpdateProductUseCase _updateProduct;
  final DeleteProductUseCase _deleteProduct;
  final GetBlockedDatesUseCase _getBlockedDates;
  final AddBlockedDateUseCase _addBlockedDate;
  final RemoveBlockedDateUseCase _removeBlockedDate;

  ShopManagementNotifier({
    required Ref ref,
    required GetSettingsUseCase getSettings,
    required SaveSettingsUseCase saveSettings,
    required GetBarbersUseCase getBarbers,
    required AddBarberUseCase addBarber,
    required UpdateBarberUseCase updateBarber,
    required GetProductsUseCase getProducts,
    required AddProductUseCase addProduct,
    required UpdateProductUseCase updateProduct,
    required DeleteProductUseCase deleteProduct,
    required GetBlockedDatesUseCase getBlockedDates,
    required AddBlockedDateUseCase addBlockedDate,
    required RemoveBlockedDateUseCase removeBlockedDate,
  })  : _ref = ref,
        _getSettings = getSettings,
        _saveSettings = saveSettings,
        _getBarbers = getBarbers,
        _addBarber = addBarber,
        _updateBarber = updateBarber,
        _getProducts = getProducts,
        _addProduct = addProduct,
        _updateProduct = updateProduct,
        _deleteProduct = deleteProduct,
        _getBlockedDates = getBlockedDates,
        _addBlockedDate = addBlockedDate,
        _removeBlockedDate = removeBlockedDate,
        super(const ShopManagementState());

  String? get _shopId {
    final auth = _ref.read(authNotifierProvider);
    return auth is AuthAuthenticated ? auth.user.linkedId : null;
  }

  // Load all

  Future<void> load() async {
    final shopId = _shopId;
    if (shopId == null) {
      state = state.copyWith(error: 'Barbearia nao vinculada.');
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final (settings, barbers, products, blockedDates) = await (
        _getSettings(shopId),
        _getBarbers(shopId),
        _getProducts(shopId),
        _getBlockedDates(shopId),
      ).wait;

      state = state.copyWith(
        isLoading: false,
        settings: settings,
        barbers: barbers,
        products: products,
        blockedDates: blockedDates,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Settings

  Future<void> saveSettings(ShopSettingsEntity settings) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _saveSettings(settings);
      state = state.copyWith(isSaving: false, settings: settings);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }

  // Barbers

  Future<void> addBarber(BarberModel barber) async {
    final shopId = _shopId;
    if (shopId == null) return;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _addBarber(shopId, barber).timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw TimeoutException(
          'Tempo esgotado ao salvar barbeiro. Verifique a conexao e as permissoes do Supabase.',
        ),
      );
      state = state.copyWith(
        isSaving: false,
        barbers: [...state.barbers, barber],
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateBarber(BarberModel barber) async {
    final shopId = _shopId;
    if (shopId == null) return;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _updateBarber(shopId, barber).timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw TimeoutException(
          'Tempo esgotado ao atualizar barbeiro. Verifique a conexao e as permissoes do Supabase.',
        ),
      );
      final updated =
          state.barbers.map((b) => b.id == barber.id ? barber : b).toList();
      state = state.copyWith(isSaving: false, barbers: updated);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }

  // Products

  Future<void> addProduct(ProductModel product) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _addProduct(product).timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw TimeoutException(
          'Tempo esgotado ao salvar produto. Verifique a conexao e as permissoes do Supabase.',
        ),
      );
      state = state
          .copyWith(isSaving: false, products: [...state.products, product]);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _updateProduct(product).timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw TimeoutException(
          'Tempo esgotado ao atualizar produto. Verifique a conexao e as permissoes do Supabase.',
        ),
      );
      final updated =
          state.products.map((p) => p.id == product.id ? product : p).toList();
      state = state.copyWith(isSaving: false, products: updated);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    final shopId = _shopId;
    if (shopId == null) return;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _deleteProduct(shopId, productId).timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw TimeoutException(
          'Tempo esgotado ao remover produto. Verifique a conexao e as permissoes do Supabase.',
        ),
      );
      state = state.copyWith(
        isSaving: false,
        products: state.products.where((p) => p.id != productId).toList(),
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      rethrow;
    }
  }

  // Blocked Dates

  Future<void> addBlockedDate(BlockedDateEntity block) async {
    state = state.copyWith(isSaving: true);
    try {
      await _addBlockedDate(block);
      state = state.copyWith(
          isSaving: false, blockedDates: [...state.blockedDates, block]);
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<void> removeBlockedDate(String blockId) async {
    final shopId = _shopId;
    if (shopId == null) return;
    try {
      await _removeBlockedDate(shopId, blockId);
      state = state.copyWith(
        blockedDates: state.blockedDates.where((b) => b.id != blockId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Verifica se uma data esta bloqueada (usado pelo lado cliente no booking).
  bool isDateBlocked(DateTime date) =>
      state.blockedDates.any((b) => b.blocks(date));
}
