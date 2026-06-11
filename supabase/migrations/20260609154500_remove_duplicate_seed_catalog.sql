delete from public.services
where barbershop_id in (
  '00000000-0000-0000-0000-000000000b01',
  '00000000-0000-0000-0000-000000000b02',
  '00000000-0000-0000-0000-000000000b03'
)
and exists (
  select 1
  from public.barbershops existing
  where existing.id <> services.barbershop_id
    and lower(existing.name) in (
      'barbearia clássica',
      'barbearia classica',
      'studio urbano',
      'dom navalha'
    )
);

delete from public.barbers
where barbershop_id in (
  '00000000-0000-0000-0000-000000000b01',
  '00000000-0000-0000-0000-000000000b02',
  '00000000-0000-0000-0000-000000000b03'
)
and exists (
  select 1
  from public.barbershops existing
  where existing.id <> barbers.barbershop_id
    and lower(existing.name) in (
      'barbearia clássica',
      'barbearia classica',
      'studio urbano',
      'dom navalha'
    )
);

delete from public.products
where barbershop_id in (
  '00000000-0000-0000-0000-000000000b01',
  '00000000-0000-0000-0000-000000000b02',
  '00000000-0000-0000-0000-000000000b03'
)
and exists (
  select 1
  from public.barbershops existing
  where existing.id <> products.barbershop_id
    and lower(existing.name) in (
      'barbearia clássica',
      'barbearia classica',
      'studio urbano',
      'dom navalha'
    )
);

delete from public.barbershops seeded
where seeded.id in (
  '00000000-0000-0000-0000-000000000b01',
  '00000000-0000-0000-0000-000000000b02',
  '00000000-0000-0000-0000-000000000b03'
)
and exists (
  select 1
  from public.barbershops existing
  where existing.id <> seeded.id
    and lower(existing.name) = lower(seeded.name)
);
