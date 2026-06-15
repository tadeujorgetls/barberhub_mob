create extension if not exists pgcrypto;

create table if not exists public.blocked_dates (
  id uuid primary key default gen_random_uuid(),
  barbershop_id text not null,
  type text not null default 'specificDate',
  date date,
  reason text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint blocked_dates_type_check
    check (type in ('specificDate', 'allSundays', 'allSaturdays')),
  constraint blocked_dates_specific_date_check
    check (type <> 'specificDate' or date is not null)
);

alter table public.blocked_dates
  add column if not exists barbershop_id text,
  add column if not exists type text not null default 'specificDate',
  add column if not exists date date,
  add column if not exists reason text not null default '',
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

create index if not exists blocked_dates_barbershop_idx
  on public.blocked_dates (barbershop_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_blocked_dates_updated_at on public.blocked_dates;
create trigger set_blocked_dates_updated_at
before update on public.blocked_dates
for each row execute function public.set_updated_at();

alter table public.blocked_dates enable row level security;

drop policy if exists "Blocked dates are readable" on public.blocked_dates;
create policy "Blocked dates are readable"
  on public.blocked_dates for select
  using (true);

drop policy if exists "Authenticated users can manage blocked dates" on public.blocked_dates;
create policy "Authenticated users can manage blocked dates"
  on public.blocked_dates for all
  using (auth.uid() is not null)
  with check (auth.uid() is not null);
