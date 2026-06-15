alter table public.products enable row level security;

drop policy if exists "Products are readable" on public.products;
create policy "Products are readable"
on public.products
for select
to authenticated, anon
using (coalesce(is_available, true));
