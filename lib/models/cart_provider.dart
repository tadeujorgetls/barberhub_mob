import 'package:flutter/foundation.dart';
import 'package:barber_hub/data/supabase_product_order_datasource.dart';
import 'barbershop_model.dart';

/// Representa um item no carrinho: produto + quantidade.
class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  String get formattedSubtotal =>
      'R\$ ${subtotal.toStringAsFixed(2).replaceAll('.', ',')}';
}

/// Provider que gerencia o estado do carrinho em memoria.
/// O carrinho e vinculado a uma unica barbearia por vez.
/// Ao tentar adicionar produto de outra barbearia, o provider
/// expoe um [pendingConflict] para que a UI possa confirmar
/// o descarte do carrinho atual antes de trocar.
class CartProvider extends ChangeNotifier {
  final SupabaseProductOrderDatasource _ordersRemote =
      SupabaseProductOrderDatasource();
  final List<CartItem> _items = [];
  BarbershopModel? _barbershop;

  // Quando o usuario tenta adicionar um produto de outra barbearia,
  // guardamos a intencao aqui para resolver via dialogo na UI.
  _PendingAdd? _pendingConflict;
  _PendingAdd? get pendingConflict => _pendingConflict;

  List<CartItem> get items => List.unmodifiable(_items);
  BarbershopModel? get barbershop => _barbershop;

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get total => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  String get formattedTotal =>
      'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';

  bool contains(String productId) =>
      _items.any((i) => i.product.id == productId);

  int quantityOf(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    return idx == -1 ? 0 : _items[idx].quantity;
  }

  /// Retorna `true` se adicionado com sucesso.
  /// Retorna `false` se houver conflito de barbearia (ver [pendingConflict]).
  bool addItem(ProductModel product, BarbershopModel shop) {
    if (_barbershop != null && _barbershop!.id != shop.id && isNotEmpty) {
      _pendingConflict = _PendingAdd(product: product, shop: shop);
      notifyListeners();
      return false;
    }

    _barbershop = shop;

    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx != -1) {
      _items[idx].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
    return true;
  }

  /// Confirma a troca de barbearia: descarta o carrinho atual e adiciona o produto pendente.
  void confirmConflictSwitch() {
    if (_pendingConflict == null) return;
    final pending = _pendingConflict!;
    _pendingConflict = null;
    clearCart();
    addItem(pending.product, pending.shop);
  }

  /// Cancela a tentativa de troca: descarta o item pendente.
  void cancelConflict() {
    _pendingConflict = null;
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    if (_items.isEmpty) _barbershop = null;
    notifyListeners();
  }

  void incrementItem(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx != -1) {
      _items[idx].quantity++;
      notifyListeners();
    }
  }

  void decrementItem(String productId) {
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx == -1) return;
    if (_items[idx].quantity <= 1) {
      removeItem(productId);
    } else {
      _items[idx].quantity--;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    _barbershop = null;
    _pendingConflict = null;
    notifyListeners();
  }

  Future<CartCheckoutResult> checkout() async {
    if (_items.isEmpty || _barbershop == null) {
      throw StateError('Adicione produtos antes de finalizar o pedido.');
    }

    if (_ordersRemote.isConfigured) {
      final remote = await _ordersRemote.createOrder(
        barbershop: _barbershop!,
        items: _items
            .map(
              (item) => ProductOrderItemInput(
                product: item.product,
                quantity: item.quantity,
              ),
            )
            .toList(),
      );

      final result = CartCheckoutResult(
        barbershopName: remote.barbershopName,
        itemCount: remote.itemCount,
        total: _formatCurrency(remote.total),
        orderId: remote.orderNumber,
      );
      clearCart();
      return result;
    }

    await Future.delayed(const Duration(milliseconds: 700));
    final result = CartCheckoutResult(
      barbershopName: _barbershop!.name,
      itemCount: itemCount,
      total: formattedTotal,
      orderId: DateTime.now().millisecondsSinceEpoch.toString().substring(5),
    );
    clearCart();
    return result;
  }

  String _formatCurrency(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
}

/// Dados do pedido apos checkout.
class CartCheckoutResult {
  final String barbershopName;
  final int itemCount;
  final String total;
  final String orderId;

  const CartCheckoutResult({
    required this.barbershopName,
    required this.itemCount,
    required this.total,
    required this.orderId,
  });
}

/// Intencao pendente de adicao ao carrinho (conflito de barbearia).
class _PendingAdd {
  final ProductModel product;
  final BarbershopModel shop;
  _PendingAdd({required this.product, required this.shop});
}
