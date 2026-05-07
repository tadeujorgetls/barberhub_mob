import 'package:barber_hub/core/constants/user_role.dart';
import 'package:barber_hub/features/client/data/models/service_model.dart';
import 'package:barber_hub/features/client/data/models/barber_model.dart';
import 'package:barber_hub/features/client/data/models/appointment_model.dart';

class MockData {
  // ── Users ─────────────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> users = [
    // Clientes
    {
      'id': 'u1',
      'name': 'Carlos Oliveira',
      'email': 'carlos@barberhub.com',
      'password': '123456',
      'role': UserRole.client,
    },
    // Barbeiros funcionários (legado)
    {
      'id': 'u2',
      'name': 'Rafael Mendes',
      'email': 'rafael@barberhub.com',
      'password': '123456',
      'role': UserRole.barber,
      'linkedId': 'b1',
    },
    // Admin (legado)
    {
      'id': 'u3',
      'name': 'Admin Hub',
      'email': 'admin@barberhub.com',
      'password': '123456',
      'role': UserRole.admin,
    },
    // ── Proprietários de Barbearia (novo perfil) ───────────────────────────
    {
      'id': 'bs_owner_1',
      'name': 'Barbearia Clássica',
      'email': 'classica@barberhub.com',
      'password': '123456',
      'role': UserRole.barberShop,
      'linkedId': 'bs1',
    },
    {
      'id': 'bs_owner_2',
      'name': 'Studio Urbano',
      'email': 'studio@barberhub.com',
      'password': '123456',
      'role': UserRole.barberShop,
      'linkedId': 'bs2',
    },
    {
      'id': 'bs_owner_3',
      'name': 'Dom Navalha',
      'email': 'dom@barberhub.com',
      'password': '123456',
      'role': UserRole.barberShop,
      'linkedId': 'bs3',
    },
  ];

  // ── Barbershops ───────────────────────────────────────────────────────────
  static List<BarbershopModel> barbershops() {
    return [
      BarbershopModel(
        id: 'bs1',
        name: 'Barbearia Clássica',
        address: 'Rua das Flores, 123 – Centro',
        rating: 4.9,
        reviewCount: 348,
        coverEmoji: 'scissors',
        description:
            'Tradição e elegância desde 2010. Ambiente sofisticado com atendimento personalizado para homens que valorizam estilo.',
        phone: '(11) 3456-7890',
        services: [
          ServiceModel(
              id: 'bs1_s1',
              name: 'Corte Clássico',
              description:
                  'Corte tradicional com tesoura e máquina. Inclui lavagem, corte personalizado e finalização com produtos premium.',
              price: 45.00,
              durationMinutes: 30,
              iconName: 'cut'),
          ServiceModel(
              id: 'bs1_s2',
              name: 'Barba Completa',
              description:
                  'Modelagem e aparação da barba com navalha e toalha quente. Inclui hidratação pós-barba.',
              price: 35.00,
              durationMinutes: 25,
              iconName: 'face'),
          ServiceModel(
              id: 'bs1_s3',
              name: 'Corte + Barba',
              description:
                  'Combo completo: corte de cabelo e barba na mesma sessão.',
              price: 70.00,
              durationMinutes: 50,
              iconName: 'combo'),
          ServiceModel(
              id: 'bs1_s4',
              name: 'Sobrancelha',
              description:
                  'Design e alinhamento das sobrancelhas com linha e pinça.',
              price: 20.00,
              durationMinutes: 15,
              iconName: 'brow'),
        ],
        barbers: [
          BarberModel(
              id: 'b1',
              name: 'Rafael Mendes',
              specialty: 'Cortes Clássicos & Fade',
              rating: 4.9,
              reviewCount: 238,
              avatarInitials: 'RM',
              phone: '(11) 99999-1111'),
          BarberModel(
              id: 'b2',
              name: 'Diego Costa',
              specialty: 'Barba & Navalha',
              rating: 4.8,
              reviewCount: 175,
              avatarInitials: 'DC',
              phone: '(11) 99999-2222'),
        ],
        products: [
          const ProductModel(
              id: 'bs1_p1',
              barbershopId: 'bs1',
              name: 'Pomada Modeladora Classic',
              description:
                  'Pomada de fixação forte com brilho médio. Ideal para cortes clássicos.',
              price: 42.90,
              originalPrice: 54.90,
              category: ProductCategory.pomade,
              imageEmoji: 'pomade',
              brand: 'BarberPro',
              isFeatured: true,
              stockQty: 15),
          const ProductModel(
              id: 'bs1_p2',
              barbershopId: 'bs1',
              name: 'Óleo para Barba Premium',
              description:
                  'Blend de óleos naturais para hidratar e amaciar a barba.',
              price: 38.50,
              category: ProductCategory.beard,
              imageEmoji: 'beard',
              brand: 'BarberPro',
              isFeatured: true,
              stockQty: 22),
          const ProductModel(
              id: 'bs1_p3',
              barbershopId: 'bs1',
              name: 'Shampoo Antiqueda',
              description:
                  'Shampoo com cafeína e biotina para fortalecer os fios.',
              price: 29.90,
              category: ProductCategory.shampoo,
              imageEmoji: 'shampoo',
              brand: 'HairCare',
              stockQty: 30),
          const ProductModel(
              id: 'bs1_p4',
              barbershopId: 'bs1',
              name: 'Kit Barba Completo',
              description:
                  'Kit com óleo de barba, balm pós-barba e pente de madeira.',
              price: 89.90,
              originalPrice: 109.90,
              category: ProductCategory.kit,
              imageEmoji: 'kit',
              brand: 'BarberPro',
              isFeatured: true,
              stockQty: 8),
        ],
      ),
      BarbershopModel(
        id: 'bs2',
        name: 'Studio Urbano',
        address: 'Av. Paulista, 900 – Bela Vista',
        rating: 4.7,
        reviewCount: 212,
        coverEmoji: 'zap',
        description:
            'Estilo contemporâneo com técnicas modernas. Especialistas em degradê e coloração masculina.',
        phone: '(11) 2345-6789',
        services: [
          ServiceModel(
              id: 'bs2_s1',
              name: 'Degradê Americano',
              description: 'Fade perfeito com máquina e acabamento impecável.',
              price: 55.00,
              durationMinutes: 35,
              iconName: 'cut'),
          ServiceModel(
              id: 'bs2_s2',
              name: 'Platinado / Coloração',
              description:
                  'Descoloração, mechas ou coloração completa com produtos profissionais.',
              price: 120.00,
              durationMinutes: 90,
              iconName: 'color'),
          ServiceModel(
              id: 'bs2_s3',
              name: 'Hidratação Capilar',
              description:
                  'Tratamento intensivo com máscara nutritiva, vitaminas e óleos essenciais.',
              price: 55.00,
              durationMinutes: 40,
              iconName: 'spa'),
        ],
        barbers: [
          BarberModel(
              id: 'b3',
              name: 'Thiago Alves',
              specialty: 'Coloração & Química',
              rating: 4.7,
              reviewCount: 112,
              avatarInitials: 'TA',
              phone: '(11) 99999-3333'),
          BarberModel(
              id: 'b4',
              name: 'Lucas Ferreira',
              specialty: 'Cortes Modernos',
              rating: 4.6,
              reviewCount: 89,
              avatarInitials: 'LF',
              phone: '(11) 99999-4444'),
        ],
        products: [
          const ProductModel(
              id: 'bs2_p1',
              barbershopId: 'bs2',
              name: 'Tônico Capilar Urbano',
              description:
                  'Tônico com niacinamida e zinco que controla a oleosidade.',
              price: 55.00,
              category: ProductCategory.shampoo,
              imageEmoji: 'shampoo',
              brand: 'UrbanStyle',
              isFeatured: true,
              stockQty: 12),
          const ProductModel(
              id: 'bs2_p2',
              barbershopId: 'bs2',
              name: 'Pomada Matte Efeito Opaco',
              description: 'Pomada de alta fixação com efeito matte.',
              price: 48.00,
              originalPrice: 58.00,
              category: ProductCategory.pomade,
              imageEmoji: 'pomade',
              brand: 'UrbanStyle',
              isFeatured: true,
              stockQty: 20),
        ],
      ),
      BarbershopModel(
        id: 'bs3',
        name: 'Dom Navalha',
        address: 'Rua Augusta, 450 – Consolação',
        rating: 4.8,
        reviewCount: 289,
        coverEmoji: 'crown',
        description:
            'A arte da navalha elevada ao máximo. Experiência única com produtos importados e atendimento VIP.',
        phone: '(11) 3333-9999',
        services: [
          ServiceModel(
              id: 'bs3_s1',
              name: 'Barba VIP',
              description:
                  'Ritual completo de barba: toalha quente, óleo de barba importado, navalha e finalização.',
              price: 80.00,
              durationMinutes: 45,
              iconName: 'face'),
          ServiceModel(
              id: 'bs3_s2',
              name: 'Corte Premium',
              description:
                  'Corte personalizado com consultoria de estilo inclusa.',
              price: 75.00,
              durationMinutes: 50,
              iconName: 'cut'),
          ServiceModel(
              id: 'bs3_s3',
              name: 'Pacote Rei',
              description:
                  'Corte + Barba VIP + Hidratação. O combo mais completo da casa.',
              price: 150.00,
              durationMinutes: 110,
              iconName: 'combo'),
        ],
        barbers: [
          BarberModel(
              id: 'b5',
              name: 'Marcelo Viana',
              specialty: 'Navalha & Rituais de Barba',
              rating: 4.9,
              reviewCount: 204,
              avatarInitials: 'MV',
              phone: '(11) 99888-5555'),
          BarberModel(
              id: 'b6',
              name: 'Fábio Reis',
              specialty: 'Cortes Premium',
              rating: 4.7,
              reviewCount: 145,
              avatarInitials: 'FR',
              phone: '(11) 99888-6666'),
        ],
        products: [
          const ProductModel(
              id: 'bs3_p1',
              barbershopId: 'bs3',
              name: 'Navalha Artesanal Dom',
              description: 'Navalha de aço inoxidável forjado à mão.',
              price: 189.90,
              category: ProductCategory.tool,
              imageEmoji: 'tool',
              brand: 'Dom Artesanal',
              isFeatured: true,
              stockQty: 5),
          const ProductModel(
              id: 'bs3_p2',
              barbershopId: 'bs3',
              name: 'Óleo de Barba Importado',
              description:
                  'Blend exclusivo com 12 óleos essenciais importados.',
              price: 95.00,
              originalPrice: 120.00,
              category: ProductCategory.beard,
              imageEmoji: 'beard',
              brand: 'Dom Signature',
              isFeatured: true,
              stockQty: 14),
          const ProductModel(
              id: 'bs3_p5',
              barbershopId: 'bs3',
              name: 'Kit Dom VIP',
              description:
                  'Kit exclusivo Dom Navalha: óleo de barba, creme de barbear, balm pós-barba e pedra de alúmen.',
              price: 249.90,
              originalPrice: 307.80,
              category: ProductCategory.kit,
              imageEmoji: 'kit',
              brand: 'Dom Signature',
              isFeatured: true,
              stockQty: 4),
        ],
      ),
    ];
  }

  static List<ServiceModel> services() => barbershops().first.services;
  static List<BarberModel> barbers() => barbershops().first.barbers;

  static List<AppointmentModel> seedAppointments(List<BarbershopModel> shops) {
    final now = DateTime.now();
    final bs1 = shops[0];
    final bs2 = shops[1];
    final bs3 = shops[2];
    return [
      AppointmentModel(
          id: 'a1',
          clientId: 'u1',
          clientName: 'Carlos Oliveira',
          service: bs1.services[0],
          barber: bs1.barbers[0],
          barbershop: bs1,
          date: now.add(const Duration(days: 1)),
          timeSlot: '10:00'),
      AppointmentModel(
          id: 'a2',
          clientId: 'u1',
          clientName: 'Carlos Oliveira',
          service: bs2.services[0],
          barber: bs2.barbers[1],
          barbershop: bs2,
          date: now.add(const Duration(days: 5)),
          timeSlot: '14:30'),
      AppointmentModel(
          id: 'a3',
          clientId: 'u1',
          clientName: 'Carlos Oliveira',
          service: bs1.services[1],
          barber: bs1.barbers[0],
          barbershop: bs1,
          date: now.subtract(const Duration(days: 7)),
          timeSlot: '09:00',
          status: AppointmentStatus.completed),
      AppointmentModel(
          id: 'a4',
          clientId: 'ext1',
          clientName: 'Marcos Lima',
          service: bs1.services[0],
          barber: bs1.barbers[0],
          barbershop: bs1,
          date: now,
          timeSlot: '08:00'),
      AppointmentModel(
          id: 'a5',
          clientId: 'ext2',
          clientName: 'Pedro Santos',
          service: bs3.services[0],
          barber: bs3.barbers[0],
          barbershop: bs3,
          date: now,
          timeSlot: '11:00'),
      AppointmentModel(
          id: 'a6',
          clientId: 'ext3',
          clientName: 'João Ferreira',
          service: bs2.services[0],
          barber: bs2.barbers[0],
          barbershop: bs2,
          date: now.subtract(const Duration(days: 2)),
          timeSlot: '15:00',
          status: AppointmentStatus.completed),
      AppointmentModel(
          id: 'a7',
          clientId: 'ext4',
          clientName: 'André Costa',
          service: bs1.services[2],
          barber: bs1.barbers[1],
          barbershop: bs1,
          date: now.add(const Duration(days: 2)),
          timeSlot: '16:00'),
    ];
  }

  static const List<String> timeSlots = [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
  ];

  static List<ReviewModel> seedReviews(List<AppointmentModel> appointments) {
    final now = DateTime.now();
    final reviews = <ReviewModel>[];

    ReviewModel make(
        {required String id,
        required AppointmentModel appt,
        required int rating,
        String? comment,
        int daysAgo = 1}) {
      final r = ReviewModel(
          id: id,
          appointmentId: appt.id,
          clientId: appt.clientId,
          clientName: appt.clientName,
          barbershopId: appt.barbershop.id,
          barbershopName: appt.barbershop.name,
          barberId: appt.barber.id,
          barberName: appt.barber.name,
          serviceName: appt.service.name,
          rating: rating,
          comment: comment,
          createdAt: now.subtract(Duration(days: daysAgo)));
      appt.review = r;
      return r;
    }

    final completed =
        appointments.where((a) => a.status == AppointmentStatus.completed);
    for (final appt in completed) {
      switch (appt.id) {
        case 'a3':
          reviews.add(make(
              id: 'r1',
              appt: appt,
              rating: 5,
              comment:
                  'Rafael é incrível! Corte perfeito, ambiente ótimo e atendimento nota 10.',
              daysAgo: 7));
          break;
        case 'a6':
          reviews.add(make(
              id: 'r2',
              appt: appt,
              rating: 4,
              comment: 'Bom atendimento e ambiente agradável.',
              daysAgo: 2));
          break;
      }
    }
    return reviews;
  }
}
