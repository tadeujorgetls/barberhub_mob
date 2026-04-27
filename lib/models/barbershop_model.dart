import 'service_model.dart';
import 'barber_model.dart';
import 'product_model.dart';

export 'product_model.dart';

class BarbershopLocation {
  final double latitude;
  final double longitude;
  final String neighborhood;
  final String embedUrl;
  final String mapUrl;

  const BarbershopLocation({
    required this.latitude,
    required this.longitude,
    required this.neighborhood,
    required this.embedUrl,
    required this.mapUrl,
  });

  String geoUri(String label) =>
      'geo:$latitude,$longitude?q=${Uri.encodeComponent(label)}';
}

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
  final List<ProductModel> products;
  final String? phone;
  final String? description;
  final BarbershopLocation? location;
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
    this.products = const [],
    this.phone,
    this.description,
    this.location,
    this.isOpen = true,
  });

  bool get hasLocation => location != null;

  String get formattedRating => rating.toStringAsFixed(1);

  BarbershopModel copyWith({
    double? rating,
    int? reviewCount,
    BarbershopLocation? location,
  }) {
    return BarbershopModel(
      id: id,
      name: name,
      address: address,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageUrl: imageUrl,
      coverEmoji: coverEmoji,
      services: services,
      barbers: barbers,
      products: products,
      phone: phone,
      description: description,
      location: location ?? this.location,
      isOpen: isOpen,
    );
  }

  List<ProductModel> get availableProducts =>
      products.where((p) => p.isAvailable).toList();

  List<ProductModel> get featuredProducts =>
      products.where((p) => p.isFeatured && p.isAvailable).toList();

  List<ProductModel> productsByCategory(ProductCategory cat) =>
      products.where((p) => p.category == cat && p.isAvailable).toList();
}
