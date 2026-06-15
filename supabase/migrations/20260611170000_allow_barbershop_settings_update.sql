alter table public.barbershops
  add column if not exists phone text,
  add column if not exists updated_at timestamptz not null default now();

alter table public.barbershops enable row level security;

drop policy if exists "Barbershop owners can update own settings" on public.barbershops;
create policy "Barbershop owners can update own settings"
on public.barbershops
for update
to authenticated
using (
  exists (
    select 1
    from public.profiles profile
    where profile.id = auth.uid()
      and (
        profile.role = 'admin'
        or (
          profile.role = 'barberShop'
          and profile.linked_id = public.barbershops.id::text
        )
      )
  )
)
with check (
  exists (
    select 1
    from public.profiles profile
    where profile.id = auth.uid()
      and (
        profile.role = 'admin'
        or (
          profile.role = 'barberShop'
          and profile.linked_id = public.barbershops.id::text
        )
      )
  )
);
