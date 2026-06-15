alter table public.barbers enable row level security;

drop policy if exists "Barbershop owners can insert own barbers" on public.barbers;
create policy "Barbershop owners can insert own barbers"
on public.barbers
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
          and profile.linked_id = public.barbers.barbershop_id::text
        )
      )
  )
);

drop policy if exists "Barbershop owners can update own barbers" on public.barbers;
create policy "Barbershop owners can update own barbers"
on public.barbers
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
          and profile.linked_id = public.barbers.barbershop_id::text
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
          and profile.linked_id = public.barbers.barbershop_id::text
        )
      )
  )
);
