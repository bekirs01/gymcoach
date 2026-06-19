-- ADIM 4/13 — Tamamlanan antrenmanlar + kamera takibi

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
