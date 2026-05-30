alter table public.workout_plan_exercises
  add column if not exists default_sets smallint not null default 3,
  add column if not exists default_reps smallint not null default 10;

create table if not exists public.workout_templates (
  id text primary key,
  user_id text not null references public.profiles (id) on delete cascade,
  name text not null,
  duration_minutes integer not null check (duration_minutes > 0),
  difficulty text not null check (difficulty in ('beginner', 'intermediate', 'advanced')),
  created_at timestamptz not null default now()
);

create table if not exists public.workout_template_exercises (
  template_id text not null references public.workout_templates (id) on delete cascade,
  sort_order integer not null check (sort_order >= 0),
  exercise_name text not null,
  default_sets smallint not null default 3,
  default_reps smallint not null default 10,
  primary key (template_id, sort_order)
);

alter table public.workout_templates enable row level security;
alter table public.workout_template_exercises enable row level security;

drop policy if exists "workout_templates: device access" on public.workout_templates;
create policy "workout_templates: device access" on public.workout_templates
  for all using (true) with check (true);

drop policy if exists "workout_template_exercises: device access" on public.workout_template_exercises;
create policy "workout_template_exercises: device access" on public.workout_template_exercises
  for all using (true) with check (true);
