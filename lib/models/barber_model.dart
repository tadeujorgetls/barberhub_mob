class BarberModel {
  final String id;
  String name;
  String specialty;
  double rating;
  int reviewCount;
  String avatarInitials;
  String phone;
  bool isActive;

  BarberModel({
    required this.id,
    required this.name,
    required this.specialty,
    this.rating = 5.0,
    this.reviewCount = 0,
    required this.avatarInitials,
    this.phone = '',
    this.isActive = true,
  });

  BarberModel copyWith({
    String? name,
    String? specialty,
    double? rating,
    int? reviewCount,
    String? avatarInitials,
    String? phone,
    bool? isActive,
  }) {
    return BarberModel(
      id: id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
    );
  }
}
