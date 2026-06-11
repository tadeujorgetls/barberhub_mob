import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:barber_hub/models/appointment_model.dart';
import 'package:barber_hub/models/barber_model.dart';
import 'package:barber_hub/models/service_model.dart';
import 'package:barber_hub/mock/mock_data.dart';
import 'package:barber_hub/data/supabase_appointment_datasource.dart';
import 'package:barber_hub/data/supabase_catalog_datasource.dart';

// ────────────────────────────────────────────────────────────────────────────
// App Data Provider (Migração de AppDataProvider)
// ────────────────────────────────────────────────────────────────────────────

/// Notifier para gerenciar dados globais da aplicação (catálogo, barbearias, etc)
class AppDataNotifier extends StateNotifier<AppDataState> {
  final _appointmentDatasource = SupabaseAppointmentDatasource();

  AppDataNotifier()
      : super(AppDataState(
          barbershops: MockData.barbershops(),
          services: MockData.services(),
          barbers: MockData.barbers(),
          appointments: [],
          reviews: [],
          selectedBarbershop: null,
          isLoading: false,
        )) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    state = state.copyWith(
      appointments: MockData.seedAppointments(state.barbershops),
    );
    state = state.copyWith(
      reviews: MockData.seedReviews(state.appointments),
    );
    await _loadCatalogFromSupabase();
  }

  Future<void> _loadCatalogFromSupabase() async {
    final datasource = SupabaseCatalogDatasource();
    if (!datasource.isConfigured) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final remoteShops = await datasource.loadBarbershops();
      if (remoteShops.isNotEmpty) {
        final appointments =
            await _appointmentDatasource.loadAppointments(remoteShops);
        state = state.copyWith(
          barbershops: remoteShops,
          services: remoteShops.expand((shop) => shop.services).toList(),
          barbers: remoteShops.expand((shop) => shop.barbers).toList(),
          appointments: appointments,
          reviews: MockData.seedReviews(appointments),
          selectedBarbershop: state.selectedBarbershop != null
              ? remoteShops
                  .where(
                      (shop) => shop.id == state.selectedBarbershop!.id)
                  .firstOrNull
              : null,
        );
      }
    } catch (error) {
      debugPrint('[AppDataNotifier] Falha ao carregar catalogo Supabase: $error');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectBarbershop(BarbershopModel? shop) {
    state = state.copyWith(selectedBarbershop: shop);
  }

  List<ReviewModel> reviewsForShop(String shopId) {
    final reviews = state.reviews
        .where((r) => r.barbershopId == shopId)
        .toList();
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }

  List<ReviewModel> reviewsForBarber(String barberId) {
    final reviews = state.reviews
        .where((r) => r.barberId == barberId)
        .toList();
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }
}

class AppDataState {
  final List<BarbershopModel> barbershops;
  final List<ServiceModel> services;
  final List<BarberModel> barbers;
  final List<AppointmentModel> appointments;
  final List<ReviewModel> reviews;
  final BarbershopModel? selectedBarbershop;
  final bool isLoading;

  AppDataState({
    required this.barbershops,
    required this.services,
    required this.barbers,
    required this.appointments,
    required this.reviews,
    required this.selectedBarbershop,
    required this.isLoading,
  });

  AppDataState copyWith({
    List<BarbershopModel>? barbershops,
    List<ServiceModel>? services,
    List<BarberModel>? barbers,
    List<AppointmentModel>? appointments,
    List<ReviewModel>? reviews,
    BarbershopModel? selectedBarbershop,
    bool? isLoading,
  }) {
    return AppDataState(
      barbershops: barbershops ?? this.barbershops,
      services: services ?? this.services,
      barbers: barbers ?? this.barbers,
      appointments: appointments ?? this.appointments,
      reviews: reviews ?? this.reviews,
      selectedBarbershop: selectedBarbershop ?? this.selectedBarbershop,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final appDataProvider =
    StateNotifierProvider<AppDataNotifier, AppDataState>((ref) {
  return AppDataNotifier();
});

// ────────────────────────────────────────────────────────────────────────────
// Cart Provider (Migração de CartProvider)
// ────────────────────────────────────────────────────────────────────────────

/// Notifier para gerenciar carrinho de compras
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState(items: [], total: 0.0));

  void addItem(ProductModel product, int quantity) {
    final existingIndex =
        state.items.indexWhere((item) => item.product.id == product.id);

    List<CartItem> newItems;
    if (existingIndex >= 0) {
      newItems = List.from(state.items);
      newItems[existingIndex] = CartItem(
        product: product,
        quantity: newItems[existingIndex].quantity + quantity,
      );
    } else {
      newItems = [...state.items, CartItem(product: product, quantity: quantity)];
    }

    _updateCart(newItems);
  }

  void removeItem(String productId) {
    final newItems =
        state.items.where((item) => item.product.id != productId).toList();
    _updateCart(newItems);
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final newItems = state.items.map((item) {
      if (item.product.id == productId) {
        return CartItem(product: item.product, quantity: quantity);
      }
      return item;
    }).toList();

    _updateCart(newItems);
  }

  void clear() {
    state = const CartState(items: [], total: 0.0);
  }

  void _updateCart(List<CartItem> items) {
    final total = items.fold<double>(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
    state = CartState(items: items, total: total);
  }
}

class CartItem {
  final ProductModel product;
  final int quantity;

  CartItem({required this.product, required this.quantity});
}

class CartState {
  final List<CartItem> items;
  final double total;

  const CartState({required this.items, required this.total});

  int get itemCount => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// ────────────────────────────────────────────────────────────────────────────
// Onboarding Provider (Migração de OnboardingProvider)
// ────────────────────────────────────────────────────────────────────────────

/// Notifier para gerenciar estado do onboarding
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState(hasCompletedOnboarding: false));

  void completeOnboarding() {
    state = const OnboardingState(hasCompletedOnboarding: true);
  }

  void resetOnboarding() {
    state = const OnboardingState(hasCompletedOnboarding: false);
  }
}

class OnboardingState {
  final bool hasCompletedOnboarding;

  const OnboardingState({required this.hasCompletedOnboarding});
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});
