-- ADIM 3/13 — Antrenman planları + şablonlar

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
  default_sets smallint not null default 3,
  default_reps smallint not null default 10,
  primary key (plan_id, sort_order)
);

create table public.workout_templates (
  id text primary key,
  user_id text not null references public.profiles (id) on delete cascade,
  name text not null,
  duration_minutes integer not null check (duration_minutes > 0),
  difficulty text not null check (difficulty in ('beginner', 'intermediate', 'advanced')),
  created_at timestamptz not null default now()
);

create table public.workout_template_exercises (
  template_id text not null references public.workout_templates (id) on delete cascade,
  sort_order integer not null check (sort_order >= 0),
  exercise_name text not null,
  default_sets smallint not null default 3,
  default_reps smallint not null default 10,
  primary key (template_id, sort_order)
);
