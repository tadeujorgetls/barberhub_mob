delete from public.services
where barbershop_id = '00000000-0000-0000-0000-000000000b01';

delete from public.barbers
where barbershop_id = '00000000-0000-0000-0000-000000000b01';

delete from public.products
where barbershop_id = '00000000-0000-0000-0000-000000000b01';

delete from public.barbershops
where id = '00000000-0000-0000-0000-000000000b01'
  and exists (
    select 1
    from public.barbershops existing
    where existing.id <> '00000000-0000-0000-0000-000000000b01'
      and lower(existing.name) in ('barbearia clássica', 'barbearia classica')
  );
