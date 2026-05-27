-- =============================================================================
-- GymCoach — полная схема базы данных (один файл)
-- =============================================================================
-- Куда: Supabase Dashboard → SQL Editor → вставить целиком → Run
-- Когда: новый проект Supabase или полный сброс схемы
-- Auth / Sign In не нужен — приложение использует ID устройства
-- =============================================================================

create extension if not exists "pgcrypto";

-- cleanup (безопасно на пустой базе)
drop trigger if exists on_auth_user_created on auth.users;
drop trigger if exists profiles_updated_at on public.profiles;
drop trigger if exists workout_plans_updated_at on public.workout_plans;

drop policy if exists "profiles: read own" on public.profiles;
drop policy if exists "profiles: insert own" on public.profiles;
drop policy if exists "profiles: update own" on public.profiles;
drop policy if exists "exercises: read all" on public.exercises;
drop policy if exists "workout_plans: own rows" on public.workout_plans;
drop policy if exists "workout_plan_exercises: via plan" on public.workout_plan_exercises;
drop policy if exists "workout_completions: own rows" on public.workout_completions;
drop policy if exists "workout_completion_exercises: via completion" on public.workout_completion_exercises;
drop policy if exists "camera_tracking_sessions: own rows" on public.camera_tracking_sessions;
drop policy if exists "profiles: device access" on public.profiles;
drop policy if exists "workout_plans: device access" on public.workout_plans;
drop policy if exists "workout_plan_exercises: device access" on public.workout_plan_exercises;
drop policy if exists "workout_completions: device access" on public.workout_completions;
drop policy if exists "workout_completion_exercises: device access" on public.workout_completion_exercises;
drop policy if exists "camera_tracking_sessions: device access" on public.camera_tracking_sessions;

drop table if exists public.camera_tracking_sessions cascade;
drop table if exists public.workout_completion_exercises cascade;
drop table if exists public.workout_completions cascade;
drop table if exists public.workout_plan_exercises cascade;
drop table if exists public.workout_plans cascade;
drop table if exists public.profiles cascade;
drop table if exists public.exercises cascade;

-- profiles (id = device uuid из приложения)
create table public.profiles (
  id text primary key,
  display_name text not null default '',
  weight_kg numeric(5, 2) not null default 70,
  height_cm numeric(5, 2) not null default 170,
  fitness_goal text not null default '',
  membership_level text not null default '',
  notifications_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- каталог упражнений (read-only)
create table public.exercises (
  id text primary key,
  canonical_name text not null unique,
  category_key text not null default 'strength',
  supports_camera_tracking boolean not null default false,
  created_at timestamptz not null default now()
);

insert into public.exercises (id, canonical_name, category_key, supports_camera_tracking) values
  ('push_ups', 'Push-ups', 'strength', true),
  ('squats', 'Squats', 'strength', true),
  ('plank', 'Plank', 'strength', true),
  ('lunges', 'Lunges', 'strength', true),
  ('jumping_jacks', 'Jumping Jacks', 'cardio', true),
  ('pull_ups', 'Pull-ups', 'strength', true),
  ('shoulder_press', 'Shoulder Press', 'strength', true),
  ('running', 'Running', 'cardio', false);

-- планы тренировок
create table public.workout_plans (
  id text primary key,
  user_id text not null references public.profiles (id) on delete cascade,
  name text not null,
  scheduled_date date not null,
  scheduled_hour smallint not null check (scheduled_hour between 0 and 23),
  scheduled_minute smallint not null check (scheduled_minute between 0 and 59),
  duration_minutes integer not null check (duration_minutes > 0),
  difficulty text not null check (difficulty in ('beginner', 'intermediate', 'advanced')),
  status text not null check (status in ('planned', 'completed', 'missed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index workout_plans_user_date_idx on public.workout_plans (user_id, scheduled_date);

create table public.workout_plan_exercises (
  plan_id text not null references public.workout_plans (id) on delete cascade,
  sort_order integer not null check (sort_order >= 0),
  exercise_name text not null,
  primary key (plan_id, sort_order)
);

-- завершённые тренировки
create table public.workout_completions (
  id text primary key,
  user_id text not null references public.profiles (id) on delete cascade,
  title text not null,
  workout_type text not null default '',
  completed_at timestamptz not null default now(),
  duration_minutes integer not null check (duration_minutes >= 0),
  calories integer not null default 0 check (calories >= 0),
  exercise_names text[] not null default '{}',
  calories_are_estimated boolean not null default true,
  created_at timestamptz not null default now()
);

create index workout_completions_user_completed_idx
  on public.workout_completions (user_id, completed_at desc);

create table public.workout_completion_exercises (
  id text primary key,
  completion_id text not null references public.workout_completions (id) on delete cascade,
  exercise_id text,
  exercise_name text not null,
  sets_completed integer not null default 0 check (sets_completed >= 0),
  reps_completed integer not null default 0 check (reps_completed >= 0),
  estimated_calories integer not null default 0 check (estimated_calories >= 0),
  category_key text not null default 'strength',
  completed_at timestamptz not null default now()
);

create index workout_completion_exercises_completion_idx
  on public.workout_completion_exercises (completion_id);

-- телеметрия камеры (опционально)
create table public.camera_tracking_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id text not null references public.profiles (id) on delete cascade,
  completion_exercise_id text references public.workout_completion_exercises (id) on delete set null,
  exercise_id text not null,
  valid_reps integer not null default 0 check (valid_reps >= 0),
  invalid_attempts integer not null default 0 check (invalid_attempts >= 0),
  hold_seconds integer not null default 0 check (hold_seconds >= 0),
  tracking_mode text not null check (tracking_mode in ('repBased', 'holdBased', 'unsupported')),
  used_camera boolean not null default true,
  recorded_at timestamptz not null default now()
);

-- updated_at
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger workout_plans_updated_at
  before update on public.workout_plans
  for each row execute function public.set_updated_at();

-- RLS (anon key, без auth)
alter table public.profiles enable row level security;
alter table public.exercises enable row level security;
alter table public.workout_plans enable row level security;
alter table public.workout_plan_exercises enable row level security;
alter table public.workout_completions enable row level security;
alter table public.workout_completion_exercises enable row level security;
alter table public.camera_tracking_sessions enable row level security;

create policy "profiles: device access" on public.profiles
  for all to anon, authenticated using (true) with check (true);

create policy "exercises: read all" on public.exercises
  for select to anon, authenticated using (true);

create policy "workout_plans: device access" on public.workout_plans
  for all to anon, authenticated using (true) with check (true);

create policy "workout_plan_exercises: device access" on public.workout_plan_exercises
  for all to anon, authenticated using (true) with check (true);

create policy "workout_completions: device access" on public.workout_completions
  for all to anon, authenticated using (true) with check (true);

create policy "workout_completion_exercises: device access" on public.workout_completion_exercises
  for all to anon, authenticated using (true) with check (true);

create policy "camera_tracking_sessions: device access" on public.camera_tracking_sessions
  for all to anon, authenticated using (true) with check (true);
