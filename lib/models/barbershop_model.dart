import 'service_model.dart';
import 'barber_model.dart';
import 'product_model.dart';

export 'product_model.dart';

class BarbershopModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String coverEmoji;
  final List<ServiceModel> services;
  final List<BarberModel> barbers;
  final List<ProductModel> products; // ← novo
  final String? phone;
  final String? description;
  bool isOpen;

  BarbershopModel({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewCount,
    this.imageUrl = '',
    this.coverEmoji = '✂️',
    required this.services,
    required this.barbers,
    this.products = const [],  // ← novo, padrão vazio
    this.phone,
    this.description,
    this.isOpen = true,
  });

  String get formattedRating => rating.toStringAsFixed(1);

  // ── Helpers de produtos ────────────────────────────────────────────────────
  List<ProductModel> get availableProducts =>
      products.where((p) => p.isAvailable).toList();

  List<ProductModel> get featuredProducts =>
      products.where((p) => p.isFeatured && p.isAvailable).toList();

  List<ProductModel> productsByCategory(ProductCategory cat) =>
      products.where((p) => p.category == cat && p.isAvailable).toList();
}
