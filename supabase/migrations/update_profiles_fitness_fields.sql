alter table public.profiles
  add column if not exists username text not null default '',
  add column if not exists public_bio text not null default '',
  add column if not exists target_weight_kg numeric(5, 1),
  add column if not exists training_focus text not null default '',
  add column if not exists experience_level text not null default '',
  add column if not exists activity_level text not null default '',
  add column if not exists weekly_workout_target integer,
  add column if not exists is_public_profile boolean,
  add column if not exists location_text text not null default '';

update public.profiles
set public_bio = bio
where public_bio = '' and bio is not null and bio <> '';

update public.profiles
set is_public_profile = is_public
where is_public_profile is null and is_public is not null;

update public.profiles
set is_public_profile = true
where is_public_profile is null;

alter table public.profiles
  alter column is_public_profile set default true,
  alter column is_public_profile set not null;

alter table public.profiles
  drop constraint if exists profiles_weight_kg_range,
  drop constraint if exists profiles_target_weight_kg_range,
  drop constraint if exists profiles_height_cm_range,
  drop constraint if exists profiles_weekly_workout_target_range,
  drop constraint if exists profiles_experience_level_values,
  drop constraint if exists profiles_activity_level_values;

alter table public.profiles
  add constraint profiles_weight_kg_range
    check (weight_kg is null or (weight_kg >= 30 and weight_kg <= 250)),
  add constraint profiles_target_weight_kg_range
    check (target_weight_kg is null or (target_weight_kg >= 30 and target_weight_kg <= 250)),
  add constraint profiles_height_cm_range
    check (height_cm is null or (height_cm >= 100 and height_cm <= 250)),
  add constraint profiles_weekly_workout_target_range
    check (weekly_workout_target is null or (weekly_workout_target >= 1 and weekly_workout_target <= 7)),
  add constraint profiles_experience_level_values
    check (experience_level = '' or experience_level in ('beginner', 'intermediate', 'advanced')),
  add constraint profiles_activity_level_values
    check (activity_level = '' or activity_level in ('low', 'moderate', 'high', 'athlete'));

create or replace function public.update_updated_at_column()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_updated_at on public.profiles;
create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.update_updated_at_column();

alter table public.profiles enable row level security;

drop policy if exists "profiles: device access" on public.profiles;
drop policy if exists "profiles: select public" on public.profiles;
drop policy if exists "profiles: select own" on public.profiles;
drop policy if exists "profiles: insert own" on public.profiles;
drop policy if exists "profiles: update own" on public.profiles;
drop policy if exists "profiles: write device" on public.profiles;

create policy "profiles: select public" on public.profiles
  for select to anon, authenticated
  using (coalesce(is_public_profile, is_public, true) = true);

create policy "profiles: select own" on public.profiles
  for select to anon, authenticated
  using (id = auth.uid()::text);

create policy "profiles: insert own" on public.profiles
  for insert to anon, authenticated
  with check (id = auth.uid()::text or id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');

create policy "profiles: update own" on public.profiles
  for update to anon, authenticated
  using (id = auth.uid()::text or id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
  with check (id = auth.uid()::text or id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');
