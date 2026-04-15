import '../models/service_model.dart';
import '../models/barber_model.dart';
import '../models/appointment_model.dart';
import '../models/user_model.dart';

class MockData {
  // ── Users (client / barber / admin) ─────────────────────────────────────────
  static final List<Map<String, dynamic>> users = [
    {
      'id': 'u1',
      'name': 'Carlos Oliveira',
      'email': 'carlos@barberhub.com',
      'password': '123456',
      'role': UserRole.client,
    },
    {
      'id': 'u2',
      'name': 'Rafael Mendes',
      'email': 'rafael@barberhub.com',
      'password': '123456',
      'role': UserRole.barber,
      'barberId': 'b1',
    },
    {
      'id': 'u3',
      'name': 'Admin Hub',
      'email': 'admin@barberhub.com',
      'password': '123456',
      'role': UserRole.admin,
    },
  ];

  // ── Barbershops ──────────────────────────────────────────────────────────────
  static List<BarbershopModel> barbershops() {
    return [
      // ── 1. Barbearia Clássica ────────────────────────────────────────────────
      BarbershopModel(
        id: 'bs1',
        name: 'Barbearia Clássica',
        address: 'Rua das Flores, 123 – Centro',
        rating: 4.9,
        reviewCount: 348,
        coverEmoji: '✂️',
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
            iconName: 'cut',
          ),
          ServiceModel(
            id: 'bs1_s2',
            name: 'Barba Completa',
            description:
                'Modelagem e aparação da barba com navalha e toalha quente. Inclui hidratação pós-barba.',
            price: 35.00,
            durationMinutes: 25,
            iconName: 'face',
          ),
          ServiceModel(
            id: 'bs1_s3',
            name: 'Corte + Barba',
            description:
                'Combo completo: corte de cabelo e barba na mesma sessão.',
            price: 70.00,
            durationMinutes: 50,
            iconName: 'combo',
          ),
          ServiceModel(
            id: 'bs1_s4',
            name: 'Sobrancelha',
            description:
                'Design e alinhamento das sobrancelhas com linha e pinça.',
            price: 20.00,
            durationMinutes: 15,
            iconName: 'brow',
          ),
        ],
        barbers: [
          BarberModel(
            id: 'b1',
            name: 'Rafael Mendes',
            specialty: 'Cortes Clássicos & Fade',
            rating: 4.9,
            reviewCount: 238,
            avatarInitials: 'RM',
            phone: '(11) 99999-1111',
          ),
          BarberModel(
            id: 'b2',
            name: 'Diego Costa',
            specialty: 'Barba & Navalha',
            rating: 4.8,
            reviewCount: 175,
            avatarInitials: 'DC',
            phone: '(11) 99999-2222',
          ),
        ],
      ),

      // ── 2. Studio Urbano ─────────────────────────────────────────────────────
      BarbershopModel(
        id: 'bs2',
        name: 'Studio Urbano',
        address: 'Av. Paulista, 900 – Bela Vista',
        rating: 4.7,
        reviewCount: 212,
        coverEmoji: '🪒',
        description:
            'Estilo contemporâneo com técnicas modernas. Especialistas em degradê e coloração masculina.',
        phone: '(11) 2345-6789',
        services: [
          ServiceModel(
            id: 'bs2_s1',
            name: 'Degradê Americano',
            description:
                'Fade perfeito com máquina e acabamento impecável. O corte mais pedido do momento.',
            price: 55.00,
            durationMinutes: 35,
            iconName: 'cut',
          ),
          ServiceModel(
            id: 'bs2_s2',
            name: 'Platinado / Coloração',
            description:
                'Descoloração, mechas ou coloração completa com produtos profissionais.',
            price: 120.00,
            durationMinutes: 90,
            iconName: 'color',
          ),
          ServiceModel(
            id: 'bs2_s3',
            name: 'Hidratação Capilar',
            description:
                'Tratamento intensivo com máscara nutritiva, vitaminas e óleos essenciais.',
            price: 55.00,
            durationMinutes: 40,
            iconName: 'spa',
          ),
          ServiceModel(
            id: 'bs2_s4',
            name: 'Corte Navalhado',
            description:
                'Acabamento com navalha para um visual afiado e bem definido.',
            price: 65.00,
            durationMinutes: 45,
            iconName: 'cut',
          ),
        ],
        barbers: [
          BarberModel(
            id: 'b3',
            name: 'Thiago Alves',
            specialty: 'Coloração & Química',
            rating: 4.7,
            reviewCount: 112,
            avatarInitials: 'TA',
            phone: '(11) 99999-3333',
          ),
          BarberModel(
            id: 'b4',
            name: 'Lucas Ferreira',
            specialty: 'Cortes Modernos',
            rating: 4.6,
            reviewCount: 89,
            avatarInitials: 'LF',
            phone: '(11) 99999-4444',
          ),
        ],
      ),

      // ── 3. Dom Navalha ───────────────────────────────────────────────────────
      BarbershopModel(
        id: 'bs3',
        name: 'Dom Navalha',
        address: 'Rua Augusta, 450 – Consolação',
        rating: 4.8,
        reviewCount: 289,
        coverEmoji: '👑',
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
            iconName: 'face',
          ),
          ServiceModel(
            id: 'bs3_s2',
            name: 'Corte Premium',
            description:
                'Corte personalizado com consultoria de estilo inclusa.',
            price: 75.00,
            durationMinutes: 50,
            iconName: 'cut',
          ),
          ServiceModel(
            id: 'bs3_s3',
            name: 'Pacote Rei',
            description:
                'Corte + Barba VIP + Hidratação. O combo mais completo da casa.',
            price: 150.00,
            durationMinutes: 110,
            iconName: 'combo',
          ),
          ServiceModel(
            id: 'bs3_s4',
            name: 'Relaxamento Facial',
            description:
                'Limpeza de pele e máscara facial hidratante pós-navalha.',
            price: 60.00,
            durationMinutes: 30,
            iconName: 'spa',
          ),
        ],
        barbers: [
          BarberModel(
            id: 'b5',
            name: 'Marcelo Viana',
            specialty: 'Navalha & Rituais de Barba',
            rating: 4.9,
            reviewCount: 204,
            avatarInitials: 'MV',
            phone: '(11) 99888-5555',
          ),
          BarberModel(
            id: 'b6',
            name: 'Fábio Reis',
            specialty: 'Cortes Premium',
            rating: 4.7,
            reviewCount: 145,
            avatarInitials: 'FR',
            phone: '(11) 99888-6666',
          ),
        ],
      ),

      // ── 4. Barber Lab ────────────────────────────────────────────────────────
      BarbershopModel(
        id: 'bs4',
        name: 'Barber Lab',
        address: 'Rua Oscar Freire, 310 – Jardins',
        rating: 4.6,
        reviewCount: 156,
        coverEmoji: '🧪',
        description:
            'Laboratório de estilos modernos. Especializados em transições de cor, texturas e cortes exclusivos.',
        phone: '(11) 4567-1234',
        services: [
          ServiceModel(
            id: 'bs4_s1',
            name: 'Mechas Modernas',
            description:
                'Mechas finas ou grossas com técnica de babylights para visual natural.',
            price: 140.00,
            durationMinutes: 100,
            iconName: 'color',
          ),
          ServiceModel(
            id: 'bs4_s2',
            name: 'Tonalização',
            description:
                'Cobertura de grisalhos ou mudança de tom com produtos semi-permanentes.',
            price: 85.00,
            durationMinutes: 60,
            iconName: 'color',
          ),
          ServiceModel(
            id: 'bs4_s3',
            name: 'Corte Texturizado',
            description:
                'Corte com navalha para criar volume e textura natural.',
            price: 60.00,
            durationMinutes: 40,
            iconName: 'cut',
          ),
          ServiceModel(
            id: 'bs4_s4',
            name: 'Hidratação Profunda',
            description:
                'Tratamento intensivo com queratina e vitaminas para cabelos danificados.',
            price: 90.00,
            durationMinutes: 60,
            iconName: 'spa',
          ),
        ],
        barbers: [
          BarberModel(
            id: 'b7',
            name: 'Caio Drummond',
            specialty: 'Coloração & Mechas',
            rating: 4.8,
            reviewCount: 98,
            avatarInitials: 'CD',
            phone: '(11) 97777-7777',
          ),
          BarberModel(
            id: 'b8',
            name: 'Natã Lima',
            specialty: 'Tratamentos Capilares',
            rating: 4.5,
            reviewCount: 73,
            avatarInitials: 'NL',
            phone: '(11) 97777-8888',
          ),
        ],
      ),

      // ── 5. Corte & Arte ──────────────────────────────────────────────────────
      BarbershopModel(
        id: 'bs5',
        name: 'Corte & Arte',
        address: 'Av. Rebouças, 1500 – Pinheiros',
        rating: 4.5,
        reviewCount: 134,
        coverEmoji: '🎨',
        description:
            'Barbearia familiar com ambiente aconchegante. Atendimento para toda a família, do pai ao filho.',
        phone: '(11) 5678-4321',
        services: [
          ServiceModel(
            id: 'bs5_s1',
            name: 'Corte Infantil',
            description:
                'Corte especial para crianças até 12 anos com paciência e carinho.',
            price: 30.00,
            durationMinutes: 25,
            iconName: 'cut',
          ),
          ServiceModel(
            id: 'bs5_s2',
            name: 'Corte Masculino',
            description:
                'Corte tradicional masculino com acabamento na máquina.',
            price: 40.00,
            durationMinutes: 30,
            iconName: 'cut',
          ),
          ServiceModel(
            id: 'bs5_s3',
            name: 'Barba Simples',
            description:
                'Aparação e alinhamento da barba com máquina e tesoura.',
            price: 25.00,
            durationMinutes: 20,
            iconName: 'face',
          ),
          ServiceModel(
            id: 'bs5_s4',
            name: 'Combo Família',
            description:
                'Corte masculino + corte infantil. Ideal para pai e filho.',
            price: 60.00,
            durationMinutes: 55,
            iconName: 'combo',
          ),
        ],
        barbers: [
          BarberModel(
            id: 'b9',
            name: 'Eduardo Souza',
            specialty: 'Cortes Clássicos & Infantis',
            rating: 4.6,
            reviewCount: 117,
            avatarInitials: 'ES',
            phone: '(11) 96666-9999',
          ),
          BarberModel(
            id: 'b10',
            name: 'Rodrigo Melo',
            specialty: 'Barba & Acabamento',
            rating: 4.4,
            reviewCount: 81,
            avatarInitials: 'RM',
            phone: '(11) 96666-0000',
          ),
        ],
      ),
    ];
  }

  // ── Legacy helpers (mantidos para compatibilidade) ───────────────────────────
  /// Retorna serviços da primeira barbearia (compatibilidade com admin)
  static List<ServiceModel> services() => barbershops().first.services;

  /// Retorna barbeiros da primeira barbearia (compatibilidade com admin)
  static List<BarberModel> barbers() => barbershops().first.barbers;

  // ── Seed Appointments ────────────────────────────────────────────────────────
  static List<AppointmentModel> seedAppointments(
    List<BarbershopModel> shops,
  ) {
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
        timeSlot: '10:00',
        status: AppointmentStatus.scheduled,
      ),
      AppointmentModel(
        id: 'a2',
        clientId: 'u1',
        clientName: 'Carlos Oliveira',
        service: bs2.services[0],
        barber: bs2.barbers[1],
        barbershop: bs2,
        date: now.add(const Duration(days: 5)),
        timeSlot: '14:30',
        status: AppointmentStatus.scheduled,
      ),
      AppointmentModel(
        id: 'a3',
        clientId: 'u1',
        clientName: 'Carlos Oliveira',
        service: bs1.services[1],
        barber: bs1.barbers[0],
        barbershop: bs1,
        date: now.subtract(const Duration(days: 7)),
        timeSlot: '09:00',
        status: AppointmentStatus.completed,
      ),
      AppointmentModel(
        id: 'a4',
        clientId: 'ext1',
        clientName: 'Marcos Lima',
        service: bs1.services[0],
        barber: bs1.barbers[0],
        barbershop: bs1,
        date: now,
        timeSlot: '08:00',
        status: AppointmentStatus.scheduled,
      ),
      AppointmentModel(
        id: 'a5',
        clientId: 'ext2',
        clientName: 'Pedro Santos',
        service: bs3.services[0],
        barber: bs3.barbers[0],
        barbershop: bs3,
        date: now,
        timeSlot: '11:00',
        status: AppointmentStatus.scheduled,
      ),
      AppointmentModel(
        id: 'a6',
        clientId: 'ext3',
        clientName: 'João Ferreira',
        service: bs2.services[0],
        barber: bs2.barbers[0],
        barbershop: bs2,
        date: now.subtract(const Duration(days: 2)),
        timeSlot: '15:00',
        status: AppointmentStatus.completed,
      ),
      AppointmentModel(
        id: 'a7',
        clientId: 'ext4',
        clientName: 'André Costa',
        service: bs1.services[2],
        barber: bs1.barbers[1],
        barbershop: bs1,
        date: now.add(const Duration(days: 2)),
        timeSlot: '16:00',
        status: AppointmentStatus.scheduled,
      ),
    ];
  }

  // Time slots
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
}
