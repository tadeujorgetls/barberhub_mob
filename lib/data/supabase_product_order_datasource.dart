import 'package:barber_hub/core/services/supabase_service.dart';
import 'package:barber_hub/models/barbershop_model.dart';

class ProductOrderItemInput {
  final ProductModel product;
  final int quantity;

  const ProductOrderItemInput({
    required this.product,
    required this.quantity,
  });

  double get subtotal => product.price * quantity;
}

class ProductOrderResult {
  final String orderId;
  final String orderNumber;
  final String barbershopName;
  final int itemCount;
  final double total;

  const ProductOrderResult({
    required this.orderId,
    required this.orderNumber,
    required this.barbershopName,
    required this.itemCount,
    required this.total,
  });
}

class SupabaseProductOrderDatasource {
  bool get isConfigured => SupabaseService.client != null;

  Future<ProductOrderResult> createOrder({
    required BarbershopModel barbershop,
    required List<ProductOrderItemInput> items,
    String paymentMethod = 'pay_on_pickup',
  }) async {
    final client = SupabaseService.client;
    if (client == null) {
      throw StateError('Supabase nao configurado para pedidos.');
    }

    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Entre na sua conta para finalizar o pedido.');
    }

    if (items.isEmpty) {
      throw StateError('Adicione produtos antes de finalizar o pedido.');
    }

    final total = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    final itemCount = items.fold<int>(0, (sum, item) => sum + item.quantity);
    final orderNumber = _orderNumber();

    Map<String, dynamic>? order;
    try {
      order = Map<String, dynamic>.from(await client
          .from('orders')
          .insert({
            'order_number': orderNumber,
            'client_id': user.id,
            'client_name': _clientName(user.email),
            'client_email': user.email ?? '',
            'barbershop_id': barbershop.id,
            'status': 'pending',
            'payment_method': paymentMethod,
            'payment_status': 'pending',
            'total': total,
          })
          .select()
          .single());

      final orderId = _string(order['id']);
      await client.from('order_items').insert(
            items
                .map(
                  (item) => {
                    'order_id': orderId,
                    'product_id': item.product.id,
                    'product_name': item.product.name,
                    'quantity': item.quantity,
                    'unit_price': item.product.price,
                    'subtotal': item.subtotal,
                  },
                )
                .toList(),
          );

      return ProductOrderResult(
        orderId: orderId,
        orderNumber: _string(order['order_number'], fallback: orderNumber),
        barbershopName: barbershop.name,
        itemCount: itemCount,
        total: total,
      );
    } catch (_) {
      final orderId = order == null ? '' : _string(order['id']);
      if (orderId.isNotEmpty) {
        try {
          await client.from('orders').delete().eq('id', orderId);
        } catch (_) {
          // Best effort cleanup; preserve the original checkout error.
        }
      }
      rethrow;
    }
  }

  String _orderNumber() {
    final millis = DateTime.now().millisecondsSinceEpoch.toString();
    return millis.substring(millis.length - 8);
  }

  String _clientName(String? email) {
    final value = email?.split('@').first.trim() ?? '';
    return value.isEmpty ? 'Cliente' : value;
  }

  String _string(Object? value, {String fallback = ''}) {
    if (value == null) return fallback;
    final text = value.toString();
    return text.isEmpty ? fallback : text;
  }
}
