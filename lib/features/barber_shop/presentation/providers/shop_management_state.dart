import 'package:barber_hub/features/barber_shop/domain/entities/shop_settings_entity.dart';
import 'package:barber_hub/features/barber_shop/domain/entities/blocked_date_entity.dart';
import 'package:barber_hub/features/client/data/models/barber_model.dart';
import 'package:barber_hub/features/client/data/models/product_model.dart';

/// Estado completo da gestão de barbearia.
/// Um único notifier carrega todos os dados do painel do proprietário.
class ShopManagementState {
  final bool isLoading;
  final String? error;
  final ShopSettingsEntity? settings;
  final List<BarberModel> barbers;
  final List<ProductModel> products;
  final List<BlockedDateEntity> blockedDates;
  final bool isSaving;

  const ShopManagementState({
    this.isLoading = false,
    this.error,
    this.settings,
    this.barbers = const [],
    this.products = const [],
    this.blockedDates = const [],
    this.isSaving = false,
  });

  bool get hasData => settings != null;

  ShopManagementState copyWith({
    bool? isLoading,
    String? error,
    ShopSettingsEntity? settings,
    List<BarberModel>? barbers,
    List<ProductModel>? products,
    List<BlockedDateEntity>? blockedDates,
    bool? isSaving,
    bool clearError = false,
  }) =>
      ShopManagementState(
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        settings: settings ?? this.settings,
        barbers: barbers ?? this.barbers,
        products: products ?? this.products,
        blockedDates: blockedDates ?? this.blockedDates,
        isSaving: isSaving ?? this.isSaving,
      );
}
