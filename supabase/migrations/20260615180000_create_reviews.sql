create extension if not exists pgcrypto;

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  appointment_id uuid not null references public.appointments(id) on delete cascade,
  client_id uuid not null references auth.users(id) on delete cascade,
  client_name text not null default '',
  barbershop_id text not null,
  barbershop_name text not null default '',
  barber_id text not null,
  barber_name text not null default '',
  service_name text not null default '',
  rating int not null check (rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now(),
  constraint reviews_appointment_unique unique (appointment_id)
);


alter table public.reviews
  add column if not exists appointment_id uuid references public.appointments(id) on delete cascade,
  add column if not exists client_id uuid references auth.users(id) on delete cascade,
  add column if not exists client_name text not null default '',
  add column if not exists barbershop_id text not null default '',
  add column if not exists barbershop_name text not null default '',
  add column if not exists barber_id text not null default '',
  add column if not exists barber_name text not null default '',
  add column if not exists service_name text not null default '',
  add column if not exists rating int,
  add column if not exists comment text,
  add column if not exists created_at timestamptz not null default now();

alter table public.reviews
  alter column client_name set default '',
  alter column barbershop_id set default '',
  alter column barbershop_name set default '',
  alter column barber_id set default '',
  alter column barber_name set default '',
  alter column service_name set default '',
  alter column created_at set default now();
create index if not exists reviews_barbershop_id_idx
  on public.reviews (barbershop_id);

create index if not exists reviews_barber_id_idx
  on public.reviews (barber_id);

create index if not exists reviews_client_id_idx
  on public.reviews (client_id);

alter table public.reviews enable row level security;

drop policy if exists "Reviews are readable" on public.reviews;
create policy "Reviews are readable"
  on public.reviews for select
  using (true);

drop policy if exists "Clients can review completed appointments" on public.reviews;
create policy "Clients can review completed appointments"
  on public.reviews for insert
  with check (
    auth.uid() = client_id
    and exists (
      select 1
      from public.appointments appointment
      where appointment.id = appointment_id
        and appointment.client_id = auth.uid()::text
        and appointment.status = 'completed'
    )
  );

create or replace view public.barbershop_review_stats as
select
  barbershop_id,
  round(avg(rating)::numeric, 1) as rating,
  count(*)::int as review_count
from public.reviews
group by barbershop_id;
