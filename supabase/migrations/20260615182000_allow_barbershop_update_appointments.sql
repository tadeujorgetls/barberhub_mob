drop policy if exists "Barbershops can update own appointments" on public.appointments;

create policy "Barbershops can update own appointments"
  on public.appointments
  for update
  using (
    exists (
      select 1
      from public.profiles profile
      where profile.id = auth.uid()
        and profile.role = 'barberShop'
        and profile.linked_id::text = appointments.barbershop_id::text
    )
  )
  with check (
    exists (
      select 1
      from public.profiles profile
      where profile.id = auth.uid()
        and profile.role = 'barberShop'
        and profile.linked_id::text = appointments.barbershop_id::text
    )
  );
