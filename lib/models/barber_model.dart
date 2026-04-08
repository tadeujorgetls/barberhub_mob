class BarberModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviewCount;
  final String avatarInitials;

  const BarberModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.avatarInitials,
  });
}
