create extension if not exists pgcrypto;

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  client_id text not null,
  client_name text not null default '',
  client_email text not null default '',
  barbershop_id text not null,
  status text not null default 'pending',
  payment_method text not null default 'pay_on_pickup',
  payment_status text not null default 'pending',
  total numeric(10, 2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint orders_status_check
    check (status in ('pending', 'ready', 'completed', 'cancelled')),
  constraint orders_payment_method_check
    check (payment_method in ('pay_on_pickup', 'pix_on_pickup', 'cash_on_pickup', 'card_on_pickup')),
  constraint orders_payment_status_check
    check (payment_status in ('pending', 'paid', 'cancelled'))
);

create table if not exists public.order_items (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  product_id text not null,
  product_name text not null,
  quantity int not null default 1,
  unit_price numeric(10, 2) not null default 0,
  subtotal numeric(10, 2) not null default 0,
  created_at timestamptz not null default now(),
  constraint order_items_quantity_check check (quantity > 0)
);

create index if not exists orders_client_id_idx on public.orders(client_id);
create index if not exists orders_barbershop_id_idx on public.orders(barbershop_id);
create index if not exists order_items_order_id_idx on public.order_items(order_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_orders_updated_at on public.orders;
create trigger set_orders_updated_at
before update on public.orders
for each row execute function public.set_updated_at();

create or replace function public.decrement_product_stock_for_order_item()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  updated_product_id text;
begin
  update public.products
  set
    stock = greatest(coalesce(stock, stock_qty, 0) - new.quantity, 0),
    stock_qty = greatest(coalesce(stock_qty, stock, 0) - new.quantity, 0),
    updated_at = now()
  where id = new.product_id
    and coalesce(stock, stock_qty, 0) >= new.quantity
  returning id into updated_product_id;

  if updated_product_id is null then
    raise exception 'Produto sem estoque suficiente para o pedido.';
  end if;

  return new;
end;
$$;

drop trigger if exists decrement_product_stock_on_order_item on public.order_items;
create trigger decrement_product_stock_on_order_item
before insert on public.order_items
for each row execute function public.decrement_product_stock_for_order_item();

alter table public.orders enable row level security;
alter table public.order_items enable row level security;

drop policy if exists "Clients can create own orders" on public.orders;
create policy "Clients can create own orders"
on public.orders
for insert
to authenticated
with check (auth.uid()::text = client_id);

drop policy if exists "Clients can read own orders" on public.orders;
create policy "Clients can read own orders"
on public.orders
for select
to authenticated
using (auth.uid()::text = client_id);

drop policy if exists "Barbershop owners can read own orders" on public.orders;
create policy "Barbershop owners can read own orders"
on public.orders
for select
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
          and profile.linked_id = public.orders.barbershop_id
        )
      )
  )
);

drop policy if exists "Barbershop owners can update own orders" on public.orders;
create policy "Barbershop owners can update own orders"
on public.orders
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
          and profile.linked_id = public.orders.barbershop_id
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
          and profile.linked_id = public.orders.barbershop_id
        )
      )
  )
);

drop policy if exists "Clients can delete own pending orders" on public.orders;
create policy "Clients can delete own pending orders"
on public.orders
for delete
to authenticated
using (auth.uid()::text = client_id and status = 'pending');

drop policy if exists "Clients can create own order items" on public.order_items;
create policy "Clients can create own order items"
on public.order_items
for insert
to authenticated
with check (
  exists (
    select 1
    from public.orders orders
    where orders.id = public.order_items.order_id
      and orders.client_id = auth.uid()::text
  )
);

drop policy if exists "Order items are readable through visible orders" on public.order_items;
create policy "Order items are readable through visible orders"
on public.order_items
for select
to authenticated
using (
  exists (
    select 1
    from public.orders orders
    where orders.id = public.order_items.order_id
      and (
        orders.client_id = auth.uid()::text
        or exists (
          select 1
          from public.profiles profile
          where profile.id = auth.uid()
            and (
              profile.role = 'admin'
              or (
                profile.role = 'barberShop'
                and profile.linked_id = orders.barbershop_id
              )
            )
        )
      )
  )
);