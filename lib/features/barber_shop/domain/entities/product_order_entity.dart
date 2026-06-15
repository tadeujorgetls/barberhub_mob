class ProductOrderEntity {
  final String id;
  final String orderNumber;
  final String clientName;
  final String clientEmail;
  final String barbershopId;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final double total;
  final DateTime createdAt;
  final List<ProductOrderItemEntity> items;

  const ProductOrderEntity({
    required this.id,
    required this.orderNumber,
    required this.clientName,
    required this.clientEmail,
    required this.barbershopId,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.total,
    required this.createdAt,
    required this.items,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  String get formattedTotal =>
      'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';

  String get statusLabel => switch (status) {
        'ready' => 'Pronto',
        'completed' => 'Entregue',
        'cancelled' => 'Cancelado',
        _ => 'Pendente',
      };

  String get paymentLabel => switch (paymentMethod) {
        'pix_on_pickup' => 'Pix na retirada',
        'cash_on_pickup' => 'Dinheiro na retirada',
        'card_on_pickup' => 'Cartao na retirada',
        _ => 'Pagar na retirada',
      };

  bool get canMarkReady => status == 'pending';
  bool get canComplete => status == 'pending' || status == 'ready';
  bool get canCancel => status == 'pending' || status == 'ready';
}

class ProductOrderItemEntity {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  const ProductOrderItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  String get formattedSubtotal =>
      'R\$ ${subtotal.toStringAsFixed(2).replaceAll('.', ',')}';
}
