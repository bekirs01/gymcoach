alter table public.workout_plans
  add column if not exists image_url text,
  add column if not exists image_asset text;

create or replace function public.resolve_workout_image_asset(
  plan_name text,
  focus_text text default null
)
returns text
language plpgsql
immutable
as $$
declare
  normalized text;
begin
  normalized := lower(coalesce(focus_text, '') || ' ' || coalesce(plan_name, ''));

  if normalized ~ '(chest|push day|push-day|bench|pec)' then
    return 'assets/images/workouts/chest.jpg';
  elsif normalized ~ '(back|pull day|pull-day|lat|row|deadlift)' then
    return 'assets/images/workouts/back.jpg';
  elsif normalized ~ '(leg|squat|lunge|glute|hamstring|quad|calf)' then
    return 'assets/images/workouts/legs.jpg';
  elsif normalized ~ '(shoulder|delt|overhead press)' then
    return 'assets/images/workouts/shoulders.jpg';
  elsif normalized ~ '(bicep|tricep|curl|arm density|arms)' then
    return 'assets/images/workouts/biceps.jpg';
  elsif normalized ~ '(core|abs|plank|crunch)' then
    return 'assets/images/workouts/core.jpg';
  elsif normalized ~ '(cardio|run|bike|burpee|hiit|rope|tempo)' then
    return 'assets/images/workouts/cardio.jpg';
  elsif normalized ~ '(full body|full-body|total body)' then
    return 'assets/images/workouts/full_body.jpg';
  end if;

  return 'assets/images/workouts/default_workout.jpg';
end;
$$;

update public.workout_plans wp
set image_asset = public.resolve_workout_image_asset(wp.name, wp.name)
where coalesce(trim(wp.image_url), '') = ''
  and coalesce(trim(wp.image_asset), '') = '';

update public.workout_plans wp
set image_asset = public.resolve_workout_image_asset(
  wp.name,
  (
    select wpe.exercise_name
    from public.workout_plan_exercises wpe
    where wpe.plan_id = wp.id
    order by wpe.sort_order
    limit 1
  )
)
where coalesce(trim(wp.image_url), '') = ''
  and coalesce(trim(wp.image_asset), '') = '';
