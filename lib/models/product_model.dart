/// Categorias de produto disponíveis
enum ProductCategory {
  pomade,       // Pomadas e finalizadores
  shampoo,      // Shampoos e condicionadores
  beard,        // Produtos para barba
  skincare,     // Cuidados com a pele
  tool,         // Ferramentas e acessórios
  kit,          // Kits combinados
}

extension ProductCategoryExt on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.pomade:    return 'Pomadas';
      case ProductCategory.shampoo:   return 'Shampoos';
      case ProductCategory.beard:     return 'Barba';
      case ProductCategory.skincare:  return 'Skincare';
      case ProductCategory.tool:      return 'Ferramentas';
      case ProductCategory.kit:       return 'Kits';
    }
  }

  String get emoji {
    switch (this) {
      case ProductCategory.pomade:    return '💈';
      case ProductCategory.shampoo:   return '🧴';
      case ProductCategory.beard:     return '🧔';
      case ProductCategory.skincare:  return '✨';
      case ProductCategory.tool:      return '✂️';
      case ProductCategory.kit:       return '🎁';
    }
  }
}

class ProductModel {
  final String id;
  final String barbershopId;
  final String name;
  final String description;
  final double price;
  final double? originalPrice; // preço antes do desconto
  final ProductCategory category;
  final String imageEmoji;     // emoji usado como placeholder de imagem
  final String brand;
  final bool isAvailable;
  final bool isFeatured;       // destaque na listagem
  final int stockQty;

  const ProductModel({
    required this.id,
    required this.barbershopId,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    this.imageEmoji = '📦',
    this.brand = '',
    this.isAvailable = true,
    this.isFeatured = false,
    this.stockQty = 99,
  });

  // ── Getters úteis ─────────────────────────────────────────────────────────
  String get formattedPrice =>
      'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}';

  String? get formattedOriginalPrice => originalPrice == null
      ? null
      : 'R\$ ${originalPrice!.toStringAsFixed(2).replaceAll('.', ',')}';

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  bool get inStock => isAvailable && stockQty > 0;

  ProductModel copyWith({
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    ProductCategory? category,
    String? imageEmoji,
    String? brand,
    bool? isAvailable,
    bool? isFeatured,
    int? stockQty,
  }) {
    return ProductModel(
      id: id,
      barbershopId: barbershopId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      category: category ?? this.category,
      imageEmoji: imageEmoji ?? this.imageEmoji,
      brand: brand ?? this.brand,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      stockQty: stockQty ?? this.stockQty,
    );
  }
}
