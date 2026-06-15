alter table public.services enable row level security;

drop policy if exists "Barbershop owners can insert own services" on public.services;
create policy "Barbershop owners can insert own services"
on public.services
for insert
to authenticated
with check (
  exists (
    select 1
    from public.profiles profile
    where profile.id = auth.uid()
      and (
        profile.role = 'admin'
        or (
          profile.role = 'barberShop'
          and profile.linked_id = public.services.barbershop_id::text
        )
      )
  )
);

drop policy if exists "Barbershop owners can update own services" on public.services;
create policy "Barbershop owners can update own services"
on public.services
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
          and profile.linked_id = public.services.barbershop_id::text
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
          and profile.linked_id = public.services.barbershop_id::text
        )
      )
  )
);
