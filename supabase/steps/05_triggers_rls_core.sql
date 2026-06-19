-- ADIM 5/13 — Trigger + ana tablolar için RLS

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

alter table public.profiles enable row level security;
alter table public.exercises enable row level security;
alter table public.workout_plans enable row level security;
alter table public.workout_plan_exercises enable row level security;
alter table public.workout_completions enable row level security;
alter table public.workout_completion_exercises enable row level security;
alter table public.camera_tracking_sessions enable row level security;
alter table public.workout_templates enable row level security;
alter table public.workout_template_exercises enable row level security;

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

create policy "workout_templates: device access" on public.workout_templates
  for all to anon, authenticated using (true) with check (true);

create policy "workout_template_exercises: device access" on public.workout_template_exercises
  for all to anon, authenticated using (true) with check (true);
