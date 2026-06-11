alter table public.barbershops
add column if not exists name text,
add column if not exists address text,
add column if not exists description text,
add column if not exists phone text,
add column if not exists rating numeric not null default 5,
add column if not exists review_count integer not null default 0,
add column if not exists cover_emoji text not null default 'scissors',
add column if not exists image_url text not null default '',
add column if not exists is_open boolean not null default true,
add column if not exists created_at timestamptz not null default now(),
add column if not exists updated_at timestamptz not null default now();

alter table public.services
add column if not exists barbershop_id uuid references public.barbershops(id) on delete cascade,
add column if not exists name text,
add column if not exists description text,
add column if not exists price numeric not null default 0,
add column if not exists duration_minutes integer not null default 30,
add column if not exists icon_name text not null default 'cut',
add column if not exists is_active boolean not null default true,
add column if not exists created_at timestamptz not null default now(),
add column if not exists updated_at timestamptz not null default now();

alter table public.barbers
add column if not exists barbershop_id uuid references public.barbershops(id) on delete cascade,
add column if not exists name text,
add column if not exists specialty text not null default '',
add column if not exists rating numeric not null default 5,
add column if not exists review_count integer not null default 0,
add column if not exists avatar_initials text not null default '',
add column if not exists phone text not null default '',
add column if not exists is_active boolean not null default true,
add column if not exists created_at timestamptz not null default now(),
add column if not exists updated_at timestamptz not null default now();

alter table public.products
add column if not exists barbershop_id uuid references public.barbershops(id) on delete cascade,
add column if not exists name text,
add column if not exists description text,
add column if not exists price numeric not null default 0,
add column if not exists original_price numeric,
add column if not exists category text not null default 'pomade',
add column if not exists image_emoji text not null default 'pomade',
add column if not exists brand text not null default '',
add column if not exists is_available boolean not null default true,
add column if not exists is_featured boolean not null default false,
add column if not exists stock_qty integer not null default 99,
add column if not exists created_at timestamptz not null default now(),
add column if not exists updated_at timestamptz not null default now();

alter table public.barbershops enable row level security;
alter table public.services enable row level security;
alter table public.barbers enable row level security;
alter table public.products enable row level security;

drop policy if exists "barbershops_read_all" on public.barbershops;
create policy "barbershops_read_all"
on public.barbershops for select
to anon, authenticated
using (true);

drop policy if exists "services_read_all" on public.services;
create policy "services_read_all"
on public.services for select
to anon, authenticated
using (true);

drop policy if exists "barbers_read_all" on public.barbers;
create policy "barbers_read_all"
on public.barbers for select
to anon, authenticated
using (true);

drop policy if exists "products_read_all" on public.products;
create policy "products_read_all"
on public.products for select
to anon, authenticated
using (true);

insert into public.barbershops
  (id, name, address, description, phone, rating, review_count, cover_emoji, is_open)
values
  ('00000000-0000-0000-0000-000000000b01', 'Barbearia Classica', 'Rua das Flores, 123 - Centro', 'Tradicao e elegancia desde 2010. Ambiente sofisticado com atendimento personalizado.', '(11) 3456-7890', 4.9, 348, 'scissors', true),
  ('00000000-0000-0000-0000-000000000b02', 'Studio Urbano', 'Av. Paulista, 900 - Bela Vista', 'Estilo contemporaneo com tecnicas modernas. Especialistas em degrade e coloracao masculina.', '(11) 2345-6789', 4.7, 212, 'zap', true),
  ('00000000-0000-0000-0000-000000000b03', 'Dom Navalha', 'Rua Augusta, 450 - Consolacao', 'A arte da navalha elevada ao maximo. Experiencia unica com produtos importados.', '(11) 3333-9999', 4.8, 289, 'crown', true)
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

insert into public.services
  (id, barbershop_id, name, description, price, duration_minutes, icon_name, is_active)
values
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000b01', 'Corte Classico', 'Corte tradicional com tesoura e maquina. Inclui lavagem e finalizacao.', 45, 30, 'cut', true),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000b01', 'Barba Completa', 'Modelagem e aparacao da barba com navalha e toalha quente.', 35, 25, 'face', true),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000b01', 'Corte + Barba', 'Combo completo: corte de cabelo e barba na mesma sessao.', 70, 50, 'combo', true),
  ('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000b02', 'Degrade Americano', 'Fade perfeito com maquina e acabamento impecavel.', 55, 35, 'cut', true),
  ('10000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000b02', 'Platinado / Coloracao', 'Descoloracao, mechas ou coloracao completa com produtos profissionais.', 120, 90, 'color', true),
  ('10000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000b03', 'Barba VIP', 'Ritual completo de barba: toalha quente, oleo de barba, navalha e finalizacao.', 80, 45, 'face', true),
  ('10000000-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000b03', 'Corte Premium', 'Corte personalizado com consultoria de estilo inclusa.', 75, 50, 'cut', true),
  ('10000000-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000b03', 'Pacote Rei', 'Corte + Barba VIP + Hidratacao. O combo mais completo da casa.', 150, 110, 'combo', true)
on conflict (id) do update set
  barbershop_id = excluded.barbershop_id,
  name = excluded.name,
  description = excluded.description,
  price = excluded.price,
  duration_minutes = excluded.duration_minutes,
  icon_name = excluded.icon_name,
  is_active = excluded.is_active,
  updated_at = now();

insert into public.barbers
  (id, barbershop_id, name, specialty, rating, review_count, avatar_initials, phone, is_active)
values
  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000b01', 'Rafael Mendes', 'Cortes Classicos & Fade', 4.9, 238, 'RM', '(11) 99999-1111', true),
  ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000b01', 'Diego Costa', 'Barba & Navalha', 4.8, 175, 'DC', '(11) 99999-2222', true),
  ('20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000b02', 'Thiago Alves', 'Coloracao & Quimica', 4.7, 112, 'TA', '(11) 99999-3333', true),
  ('20000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000b03', 'Marcelo Viana', 'Navalha & Rituais de Barba', 4.9, 204, 'MV', '(11) 99888-5555', true)
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

insert into public.products
  (id, barbershop_id, name, description, price, original_price, category, image_emoji, brand, is_available, is_featured, stock_qty)
values
  ('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000b01', 'Pomada Modeladora Classic', 'Pomada de fixacao forte com brilho medio.', 42.90, 54.90, 'pomade', 'pomade', 'BarberPro', true, true, 15),
  ('30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000b01', 'Oleo para Barba Premium', 'Blend de oleos naturais para hidratar e amaciar a barba.', 38.50, null, 'beard', 'beard', 'BarberPro', true, true, 22),
  ('30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000b02', 'Pomada Matte Efeito Opaco', 'Pomada de alta fixacao com efeito matte.', 48, 58, 'pomade', 'pomade', 'UrbanStyle', true, true, 20),
  ('30000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000b03', 'Kit Dom VIP', 'Kit exclusivo Dom Navalha com oleo, creme e balm pos-barba.', 249.90, 307.80, 'kit', 'kit', 'Dom Signature', true, true, 4)
on conflict (id) do update set
  barbershop_id = excluded.barbershop_id,
  name = excluded.name,
  description = excluded.description,
  price = excluded.price,
  original_price = excluded.original_price,
  category = excluded.category,
  image_emoji = excluded.image_emoji,
  brand = excluded.brand,
  is_available = excluded.is_available,
  is_featured = excluded.is_featured,
  stock_qty = excluded.stock_qty,
  updated_at = now();
