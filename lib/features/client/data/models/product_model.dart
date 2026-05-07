import 'package:flutter/material.dart';
import 'package:barber_hub/core/utils/app_icons.dart';

/// Categorias de produto disponíveis
enum ProductCategory {
  pomade,    // Pomadas e finalizadores
  shampoo,   // Shampoos e condicionadores
  beard,     // Produtos para barba
  skincare,  // Cuidados com a pele
  tool,      // Ferramentas e acessórios
  kit,       // Kits combinados
}

extension ProductCategoryExt on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.pomade:   return 'Pomadas';
      case ProductCategory.shampoo:  return 'Shampoos';
      case ProductCategory.beard:    return 'Barba';
      case ProductCategory.skincare: return 'Skincare';
      case ProductCategory.tool:     return 'Ferramentas';
      case ProductCategory.kit:      return 'Kits';
    }
  }

  /// Chave de ícone — usada para persistência e mapeamento via [ProductCategoryIcons].
  String get iconKey {
    switch (this) {
      case ProductCategory.pomade:   return 'pomade';
      case ProductCategory.shampoo:  return 'shampoo';
      case ProductCategory.beard:    return 'beard';
      case ProductCategory.skincare: return 'skincare';
      case ProductCategory.tool:     return 'tool';
      case ProductCategory.kit:      return 'kit';
    }
  }

  IconData get iconData => ProductCategoryIcons.fromKey(iconKey);
}

class ProductModel {
  final String id;
  final String barbershopId;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final ProductCategory category;

  /// Chave de ícone persistida (ex: 'pomade', 'kit').
  /// Mantido como [imageEmoji] para compatibilidade com JSON existente;
  /// internamente armazena um [iconKey] a partir de Prompt 3.
  final String imageEmoji;

  final String brand;
  final bool isAvailable;
  final bool isFeatured;
  final int stockQty;

  const ProductModel({
    required this.id,
    required this.barbershopId,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.category,
    this.imageEmoji = 'package',
    this.brand = '',
    this.isAvailable = true,
    this.isFeatured = false,
    this.stockQty = 99,
  });

  // ── Ícone renderizado ──────────────────────────────────────────────────────

  /// Retorna o [IconData] Lucide correspondente, com fallback por categoria.
  IconData get iconData {
    final fromKey = ProductCategoryIcons.fromKey(imageEmoji);
    // fromKey retorna fallback (package) apenas quando não reconhece
    // Prefere o ícone da categoria se imageEmoji não é um key válido
    if (imageEmoji.isEmpty || _isLegacyEmoji(imageEmoji)) {
      return category.iconData;
    }
    return fromKey;
  }

  static bool _isLegacyEmoji(String s) {
    // Detecta strings com código emoji (caracteres fora do ASCII)
    return s.runes.any((r) => r > 127);
  }

  // ── Getters úteis ──────────────────────────────────────────────────────────
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
    String? name, String? description, double? price, double? originalPrice,
    ProductCategory? category, String? imageEmoji, String? brand,
    bool? isAvailable, bool? isFeatured, int? stockQty,
  }) {
    return ProductModel(
      id: id, barbershopId: barbershopId,
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
