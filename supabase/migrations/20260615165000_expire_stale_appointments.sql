alter table public.appointments
  drop constraint if exists appointments_status_check;

alter table public.appointments
  add constraint appointments_status_check
  check (status in ('scheduled', 'completed', 'cancelled', 'no_show', 'expired'));

create or replace function public.expire_stale_appointments()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  affected_rows integer;
begin
  update public.appointments appointment
  set status = 'expired', updated_at = now()
  from public.services service
  where appointment.service_id = service.id
    and appointment.status = 'scheduled'
    and (
      appointment.date
      + appointment.time_slot::time
      + make_interval(mins => coalesce(service.duration_minutes, 0))
      + interval '24 hours'
    ) < now();

  get diagnostics affected_rows = row_count;
  return affected_rows;
end;
$$;

select public.expire_stale_appointments();