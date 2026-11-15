-- Phong Thien 3D — unified pet-dove profile across devices (v2.90.8)
-- Anita runs this ONCE in the Supabase SQL Editor (sent to her 2026-11-15).
-- The dove record is keyed by a SHA-256 hash of her personal code; the
-- client reads the row by exact code-hash and writes only via the RPC,
-- mirroring the pt3d_set_layout pattern.
create table if not exists public.pt3d_doves (
  code text primary key,
  a int not null default 0,
  hat int not null default 0,
  updated_at timestamptz not null default now()
);
alter table public.pt3d_doves enable row level security;
drop policy if exists "dove read" on public.pt3d_doves;
create policy "dove read" on public.pt3d_doves for select to anon using (true);
create or replace function public.pt3d_set_dove(p_code text, p_a int, p_hat int)
returns void language plpgsql security definer set search_path = public as $$
begin
  insert into public.pt3d_doves (code, a, hat, updated_at)
  values (p_code, greatest(p_a, 0), greatest(p_hat, 0), now())
  on conflict (code) do update set a = excluded.a, hat = excluded.hat, updated_at = now();
end; $$;
grant execute on function public.pt3d_set_dove(text, int, int) to anon;
