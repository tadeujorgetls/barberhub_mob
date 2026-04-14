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

  // ── Services ─────────────────────────────────────────────────────────────────
  static List<ServiceModel> services() => [
        ServiceModel(
          id: 's1',
          name: 'Corte Clássico',
          description:
              'Corte tradicional com tesoura e máquina. Inclui lavagem, corte personalizado e finalização com produtos premium. Ideal para quem busca um visual elegante e atemporal.',
          price: 45.00,
          durationMinutes: 30,
          iconName: 'cut',
        ),
        ServiceModel(
          id: 's2',
          name: 'Barba Completa',
          description:
              'Modelagem e aparação da barba com navalha e toalha quente. Inclui hidratação pós-barba e finalização com balm.',
          price: 35.00,
          durationMinutes: 25,
          iconName: 'face',
        ),
        ServiceModel(
          id: 's3',
          name: 'Corte + Barba',
          description:
              'Combo completo: corte de cabelo e barba na mesma sessão. Lavagem, corte, modelagem de barba e finalização.',
          price: 70.00,
          durationMinutes: 50,
          iconName: 'combo',
        ),
        ServiceModel(
          id: 's4',
          name: 'Platinado / Coloração',
          description:
              'Descoloração, mechas ou coloração completa com produtos profissionais de alta qualidade.',
          price: 120.00,
          durationMinutes: 90,
          iconName: 'color',
        ),
        ServiceModel(
          id: 's5',
          name: 'Hidratação Capilar',
          description:
              'Tratamento intensivo com máscara nutritiva, vitaminas e óleos essenciais.',
          price: 55.00,
          durationMinutes: 40,
          iconName: 'spa',
        ),
        ServiceModel(
          id: 's6',
          name: 'Sobrancelha',
          description:
              'Design e alinhamento das sobrancelhas com linha e pinça.',
          price: 20.00,
          durationMinutes: 15,
          iconName: 'brow',
        ),
      ];

  // ── Barbers ──────────────────────────────────────────────────────────────────
  static List<BarberModel> barbers() => [
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
      ];

  // ── Seed Appointments ─────────────────────────────────────────────────────────
  static List<AppointmentModel> seedAppointments(
    List<ServiceModel> svc,
    List<BarberModel> barbers,
  ) {
    final now = DateTime.now();
    return [
      AppointmentModel(
        id: 'a1',
        clientId: 'u1',
        clientName: 'Carlos Oliveira',
        service: svc[0],
        barber: barbers[0],
        date: now.add(const Duration(days: 1)),
        timeSlot: '10:00',
        status: AppointmentStatus.scheduled,
      ),
      AppointmentModel(
        id: 'a2',
        clientId: 'u1',
        clientName: 'Carlos Oliveira',
        service: svc[2],
        barber: barbers[1],
        date: now.add(const Duration(days: 5)),
        timeSlot: '14:30',
        status: AppointmentStatus.scheduled,
      ),
      AppointmentModel(
        id: 'a3',
        clientId: 'u1',
        clientName: 'Carlos Oliveira',
        service: svc[1],
        barber: barbers[0],
        date: now.subtract(const Duration(days: 7)),
        timeSlot: '09:00',
        status: AppointmentStatus.completed,
      ),
      AppointmentModel(
        id: 'a4',
        clientId: 'ext1',
        clientName: 'Marcos Lima',
        service: svc[0],
        barber: barbers[0],
        date: now,
        timeSlot: '08:00',
        status: AppointmentStatus.scheduled,
      ),
      AppointmentModel(
        id: 'a5',
        clientId: 'ext2',
        clientName: 'Pedro Santos',
        service: svc[3],
        barber: barbers[2],
        date: now,
        timeSlot: '11:00',
        status: AppointmentStatus.scheduled,
      ),
      AppointmentModel(
        id: 'a6',
        clientId: 'ext3',
        clientName: 'João Ferreira',
        service: svc[1],
        barber: barbers[1],
        date: now.subtract(const Duration(days: 2)),
        timeSlot: '15:00',
        status: AppointmentStatus.completed,
      ),
      AppointmentModel(
        id: 'a7',
        clientId: 'ext4',
        clientName: 'André Costa',
        service: svc[4],
        barber: barbers[0],
        date: now.add(const Duration(days: 2)),
        timeSlot: '16:00',
        status: AppointmentStatus.scheduled,
      ),
    ];
  }

  // Time slots
  static const List<String> timeSlots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
  ];
}
