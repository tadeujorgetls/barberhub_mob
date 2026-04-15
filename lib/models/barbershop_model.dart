import 'service_model.dart';
import 'barber_model.dart';

class BarbershopModel {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int reviewCount;
  final String imageUrl; // usado como placeholder / network image
  final String coverEmoji; // fallback visual quando não há imagem real
  final List<ServiceModel> services;
  final List<BarberModel> barbers;
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
    this.phone,
    this.description,
    this.isOpen = true,
  });

  String get formattedRating => rating.toStringAsFixed(1);
}
