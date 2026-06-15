insert into public.barbershops
  (id, name, address, description, phone, rating, review_count, cover_emoji, is_open, created_at, updated_at)
values
  (
    '00000000-0000-0000-0000-000000000b04',
    'Navalha Prime',
    'Av. T-9, 1140 - Setor Bueno',
    'Barbearia premium com foco em cortes modernos, barba completa e atendimento com hora marcada.',
    '(62) 99210-4404',
    4.8,
    36,
    'crown',
    true,
    now(),
    now()
  ),
  (
    '00000000-0000-0000-0000-000000000b05',
    'Studio Fio & Navalha',
    'Rua 15, 620 - Setor Marista',
    'Studio urbano para cortes, degradês e manutenção de barba com atendimento personalizado.',
    '(62) 99125-5505',
    4.7,
    28,
    'scissors',
    true,
    now(),
    now()
  )
on conflict (id) do update set
  name = excluded.name,
  address = excluded.address,
  description = excluded.description,
  phone = excluded.phone,
  rating = excluded.rating,
  review_count = excluded.review_count,
  cover_emoji = excluded.cover_emoji,
  is_open = excluded.is_open,
  updated_at = now();

insert into public.barbers
  (id, barbershop_id, name, specialty, rating, review_count, avatar_initials, phone, is_active, created_at, updated_at)
values
  (
    '20000000-0000-0000-0000-000000000005',
    '00000000-0000-0000-0000-000000000b04',
    'Lucas Almeida',
    'Degradê e cortes modernos',
    4.8,
    19,
    'LA',
    '(62) 98810-1001',
    true,
    now(),
    now()
  ),
  (
    '20000000-0000-0000-0000-000000000006',
    '00000000-0000-0000-0000-000000000b04',
    'Henrique Torres',
    'Barba e navalha',
    4.7,
    17,
    'HT',
    '(62) 98810-1002',
    true,
    now(),
    now()
  ),
  (
    '20000000-0000-0000-0000-000000000007',
    '00000000-0000-0000-0000-000000000b05',
    'Bruno Castro',
    'Cortes clássicos',
    4.8,
    21,
    'BC',
    '(62) 98810-1003',
    true,
    now(),
    now()
  ),
  (
    '20000000-0000-0000-0000-000000000008',
    '00000000-0000-0000-0000-000000000b05',
    'Mateus Rocha',
    'Degradê e acabamento',
    4.6,
    14,
    'MR',
    '(62) 98810-1004',
    true,
    now(),
    now()
  )
on conflict (id) do update set
  barbershop_id = excluded.barbershop_id,
  name = excluded.name,
  specialty = excluded.specialty,
  rating = excluded.rating,
  review_count = excluded.review_count,
  avatar_initials = excluded.avatar_initials,
  phone = excluded.phone,
  is_active = excluded.is_active,
  updated_at = now();

insert into public.services
  (id, barbershop_id, name, description, price, duration_minutes, icon_name, is_active, created_at, updated_at)
values
  (
    '10000000-0000-0000-0000-000000000009',
    '00000000-0000-0000-0000-000000000b04',
    'Corte Degradê',
    'Degradê com acabamento na navalha e finalização.',
    50,
    35,
    'cut',
    true,
    now(),
    now()
  ),
  (
    '10000000-0000-0000-0000-000000000010',
    '00000000-0000-0000-0000-000000000b04',
    'Barba Premium',
    'Modelagem de barba com toalha quente e navalha.',
    40,
    30,
    'face',
    true,
    now(),
    now()
  ),
  (
    '10000000-0000-0000-0000-000000000011',
    '00000000-0000-0000-0000-000000000b05',
    'Corte Clássico',
    'Corte tradicional com máquina, tesoura e acabamento.',
    45,
    30,
    'cut',
    true,
    now(),
    now()
  ),
  (
    '10000000-0000-0000-0000-000000000012',
    '00000000-0000-0000-0000-000000000b05',
    'Corte + Barba',
    'Combo completo de corte e barba com finalização.',
    75,
    55,
    'combo',
    true,
    now(),
    now()
  )
on conflict (id) do update set
  barbershop_id = excluded.barbershop_id,
  name = excluded.name,
  description = excluded.description,
  price = excluded.price,
  duration_minutes = excluded.duration_minutes,
  icon_name = excluded.icon_name,
  is_active = excluded.is_active,
  updated_at = now();