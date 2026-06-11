create extension if not exists pgcrypto;

create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  client_id text not null default '',
  client_name text not null default '',
  barbershop_id uuid references public.barbershops(id) on delete cascade,
  service_id uuid references public.services(id) on delete restrict,
  barber_id uuid references public.barbers(id) on delete restrict,
  date date,
  time_slot text not null default '',
  status text not null default 'scheduled',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint appointments_status_check
    check (status in ('scheduled', 'completed', 'cancelled'))
);

do $$
declare
  policy_record record;
begin
  for policy_record in
    select policyname
    from pg_policies
    where schemaname = 'public'
      and tablename = 'appointments'
  loop
    execute format(
      'drop policy if exists %I on public.appointments',
      policy_record.policyname
    );
  end loop;
end;
$$;

alter table public.appointments
  drop constraint if exists appointments_client_id_fkey;

alter table public.appointments
  add column if not exists client_id text not null default '',
  add column if not exists client_name text not null default '',
  add column if not exists barbershop_id uuid references public.barbershops(id) on delete cascade,
  add column if not exists service_id uuid references public.services(id) on delete restrict,
  add column if not exists barber_id uuid references public.barbers(id) on delete restrict,
  add column if not exists date date,
  add column if not exists time_slot text not null default '',
  add column if not exists status text not null default 'scheduled',
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

alter table public.appointments
  alter column client_id type text using client_id::text;

update public.appointments
set client_id = ''
where client_id is null;

alter table public.appointments
  alter column client_id set not null,
  alter column client_id set default '',
  alter column client_name set not null,
  alter column client_name set default '',
  alter column time_slot set not null,
  alter column time_slot set default '',
  alter column status set not null,
  alter column status set default 'scheduled',
  alter column created_at set not null,
  alter column created_at set default now(),
  alter column updated_at set not null,
  alter column updated_at set default now();

create unique index if not exists appointments_unique_scheduled_slot
  on public.appointments (barber_id, date, time_slot)
  where status = 'scheduled';

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_appointments_updated_at on public.appointments;
create trigger set_appointments_updated_at
before update on public.appointments
for each row execute function public.set_updated_at();

alter table public.appointments enable row level security;

create policy "Appointments are readable"
  on public.appointments for select
  using (true);

create policy "Clients can create own appointments"
  on public.appointments for insert
  with check (auth.uid()::text = client_id);

create policy "Clients can update own appointments"
  on public.appointments for update
  using (auth.uid()::text = client_id)
  with check (auth.uid()::text = client_id);