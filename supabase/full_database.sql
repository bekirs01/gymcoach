-- =============================================================================
-- GymCoach — FULL DATABASE SETUP (single file)
-- =============================================================================
-- Supabase Dashboard → SQL Editor → paste entire file → Run
--
-- Includes:
--   1. Core GymCoach schema (profiles, plans, workouts, camera)
--   2. Territory capture game (PostGIS + RPC functions)
--   3. Demo territory seed data (Istanbul)
--   4. Backend verification tests (optional, rolled back)
--
-- WARNING: Section 1 drops existing GymCoach tables. Backup first if needed.
-- =============================================================================

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
drop table if exists public.territory_events cascade;
drop table if exists public.territory_capture_points cascade;
drop table if exists public.territory_capture_sessions cascade;
drop table if exists public.captured_territories cascade;
drop view if exists public.territory_leaderboard;
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

-- =============================================================================
-- SECTION 2: Territory capture (PostGIS migration)
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

CREATE TABLE IF NOT EXISTS public.territory_capture_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id text NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'recording' CHECK (status IN ('recording', 'completed', 'cancelled', 'failed')),
  started_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz,
  polygon_geojson jsonb,
  path_geojson jsonb,
  distance_m double precision DEFAULT 0,
  area_m2 double precision DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.territory_capture_points (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES public.territory_capture_sessions(id) ON DELETE CASCADE,
  user_id text NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  latitude double precision NOT NULL,
  longitude double precision NOT NULL,
  accuracy_m double precision,
  speed_mps double precision,
  heading double precision,
  recorded_at timestamptz NOT NULL DEFAULT now(),
  geom geometry(Point, 4326) GENERATED ALWAYS AS (
    ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
  ) STORED
);

CREATE INDEX IF NOT EXISTS idx_territory_capture_points_session_id
  ON public.territory_capture_points(session_id);

CREATE INDEX IF NOT EXISTS idx_territory_capture_points_geom
  ON public.territory_capture_points USING gist(geom);

CREATE TABLE IF NOT EXISTS public.captured_territories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id text NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  source_session_id uuid REFERENCES public.territory_capture_sessions(id) ON DELETE SET NULL,
  name text NOT NULL,
  geom geometry(MultiPolygon, 4326) NOT NULL,
  area_m2 double precision NOT NULL DEFAULT 0,
  captured_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_captured_territories_owner_user_id
  ON public.captured_territories(owner_user_id);

CREATE INDEX IF NOT EXISTS idx_captured_territories_geom
  ON public.captured_territories USING gist(geom);

CREATE TABLE IF NOT EXISTS public.territory_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id text NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  territory_id uuid REFERENCES public.captured_territories(id) ON DELETE SET NULL,
  session_id uuid REFERENCES public.territory_capture_sessions(id) ON DELETE SET NULL,
  event_type text NOT NULL CHECK (event_type IN (
    'capture_started',
    'capture_completed',
    'capture_cancelled',
    'territory_created',
    'territory_cut'
  )),
  area_m2 double precision DEFAULT 0,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE OR REPLACE FUNCTION public.set_captured_territory_area()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.area_m2 := ST_Area(NEW.geom::geography);
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_set_captured_territory_area ON public.captured_territories;

CREATE TRIGGER trg_set_captured_territory_area
BEFORE INSERT OR UPDATE OF geom
ON public.captured_territories
FOR EACH ROW
EXECUTE FUNCTION public.set_captured_territory_area();

DROP TRIGGER IF EXISTS territory_capture_sessions_updated_at ON public.territory_capture_sessions;

CREATE TRIGGER territory_capture_sessions_updated_at
BEFORE UPDATE ON public.territory_capture_sessions
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE FUNCTION public.assert_profile_user(p_user_id text)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  IF p_user_id IS NULL OR length(trim(p_user_id)) = 0 THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.profiles
    WHERE id = p_user_id
  ) THEN
    RAISE EXCEPTION 'Invalid user';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION public.capture_territory(
  p_user_id text,
  p_name text,
  p_polygon_geojson jsonb,
  p_session_id uuid DEFAULT NULL
)
RETURNS TABLE (
  territory_id uuid,
  owner_user_id text,
  area_m2 double precision
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_geom geometry(MultiPolygon, 4326);
  v_area double precision;
  v_territory_id uuid;
BEGIN
  PERFORM public.assert_profile_user(p_user_id);

  IF p_name IS NULL OR length(trim(p_name)) < 2 THEN
    RAISE EXCEPTION 'Territory name is required';
  END IF;

  IF p_session_id IS NOT NULL AND NOT EXISTS (
    SELECT 1
    FROM public.territory_capture_sessions
    WHERE id = p_session_id
      AND user_id = p_user_id
      AND status = 'recording'
  ) THEN
    RAISE EXCEPTION 'Invalid capture session';
  END IF;

  v_geom := ST_Multi(
    ST_CollectionExtract(
      ST_MakeValid(
        ST_SetSRID(ST_GeomFromGeoJSON(p_polygon_geojson::text), 4326)
      ),
      3
    )
  );

  IF ST_IsEmpty(v_geom) OR NOT ST_IsValid(v_geom) THEN
    RAISE EXCEPTION 'Invalid polygon';
  END IF;

  v_area := ST_Area(v_geom::geography);

  IF v_area < 25 THEN
    RAISE EXCEPTION 'Captured area is too small';
  END IF;

  IF v_area > 5000000 THEN
    RAISE EXCEPTION 'Captured area is too large';
  END IF;

  PERFORM pg_advisory_xact_lock(9248612);

  UPDATE public.captured_territories
  SET geom = ST_Multi(
    ST_CollectionExtract(
      ST_Difference(geom, v_geom),
      3
    )
  )
  WHERE ST_Intersects(geom, v_geom);

  DELETE FROM public.captured_territories
  WHERE ST_IsEmpty(geom)
     OR ST_Area(geom::geography) < 1;

  INSERT INTO public.captured_territories (
    owner_user_id,
    source_session_id,
    name,
    geom
  )
  VALUES (
    p_user_id,
    p_session_id,
    trim(p_name),
    v_geom
  )
  RETURNING id, captured_territories.area_m2
  INTO v_territory_id, v_area;

  IF p_session_id IS NOT NULL THEN
    UPDATE public.territory_capture_sessions
    SET status = 'completed',
        ended_at = now(),
        polygon_geojson = p_polygon_geojson,
        area_m2 = v_area,
        path_geojson = (
          SELECT jsonb_build_object(
            'type', 'LineString',
            'coordinates', jsonb_agg(
              jsonb_build_array(longitude, latitude)
              ORDER BY recorded_at
            )
          )
          FROM public.territory_capture_points
          WHERE session_id = p_session_id
        ),
        updated_at = now()
    WHERE id = p_session_id
      AND user_id = p_user_id;

    INSERT INTO public.territory_events (
      user_id,
      territory_id,
      session_id,
      event_type,
      area_m2,
      metadata
    )
    VALUES (
      p_user_id,
      v_territory_id,
      p_session_id,
      'capture_completed',
      v_area,
      jsonb_build_object('name', trim(p_name))
    );
  END IF;

  INSERT INTO public.territory_events (
    user_id,
    territory_id,
    session_id,
    event_type,
    area_m2,
    metadata
  )
  VALUES (
    p_user_id,
    v_territory_id,
    p_session_id,
    'territory_created',
    v_area,
    jsonb_build_object('name', trim(p_name))
  );

  RETURN QUERY
  SELECT v_territory_id, p_user_id, v_area;
END;
$$;

CREATE OR REPLACE FUNCTION public.start_territory_capture_session(p_user_id text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_session_id uuid;
BEGIN
  PERFORM public.assert_profile_user(p_user_id);

  INSERT INTO public.territory_capture_sessions (user_id, status)
  VALUES (p_user_id, 'recording')
  RETURNING id INTO v_session_id;

  INSERT INTO public.territory_events (
    user_id,
    session_id,
    event_type,
    metadata
  )
  VALUES (
    p_user_id,
    v_session_id,
    'capture_started',
    '{}'::jsonb
  );

  RETURN v_session_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.save_territory_capture_point(
  p_user_id text,
  p_session_id uuid,
  p_latitude double precision,
  p_longitude double precision,
  p_accuracy_m double precision DEFAULT NULL,
  p_speed_mps double precision DEFAULT NULL,
  p_heading double precision DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_point_id uuid;
BEGIN
  PERFORM public.assert_profile_user(p_user_id);

  IF NOT EXISTS (
    SELECT 1
    FROM public.territory_capture_sessions
    WHERE id = p_session_id
      AND user_id = p_user_id
      AND status = 'recording'
  ) THEN
    RAISE EXCEPTION 'Invalid capture session';
  END IF;

  INSERT INTO public.territory_capture_points (
    session_id,
    user_id,
    latitude,
    longitude,
    accuracy_m,
    speed_mps,
    heading
  )
  VALUES (
    p_session_id,
    p_user_id,
    p_latitude,
    p_longitude,
    p_accuracy_m,
    p_speed_mps,
    p_heading
  )
  RETURNING id INTO v_point_id;

  UPDATE public.territory_capture_sessions
  SET distance_m = COALESCE(distance_m, 0) + COALESCE(
    (
      SELECT ST_Distance(
        ST_SetSRID(ST_MakePoint(p_longitude, p_latitude), 4326)::geography,
        prev.geom::geography
      )
      FROM (
        SELECT geom
        FROM public.territory_capture_points
        WHERE session_id = p_session_id
          AND id <> v_point_id
        ORDER BY recorded_at DESC
        LIMIT 1
      ) AS prev
    ),
    0
  ),
  updated_at = now()
  WHERE id = p_session_id;

  RETURN v_point_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.finish_territory_capture_session(
  p_user_id text,
  p_session_id uuid,
  p_name text,
  p_polygon_geojson jsonb
)
RETURNS TABLE (
  territory_id uuid,
  owner_user_id text,
  area_m2 double precision
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM public.capture_territory(
    p_user_id,
    p_name,
    p_polygon_geojson,
    p_session_id
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.cancel_territory_capture_session(
  p_user_id text,
  p_session_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public.assert_profile_user(p_user_id);

  UPDATE public.territory_capture_sessions
  SET status = 'cancelled',
      ended_at = now(),
      updated_at = now()
  WHERE id = p_session_id
    AND user_id = p_user_id
    AND status = 'recording';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invalid capture session';
  END IF;

  INSERT INTO public.territory_events (
    user_id,
    session_id,
    event_type,
    metadata
  )
  VALUES (
    p_user_id,
    p_session_id,
    'capture_cancelled',
    '{}'::jsonb
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.get_territories(
  p_user_id text,
  p_min_lng double precision DEFAULT NULL,
  p_min_lat double precision DEFAULT NULL,
  p_max_lng double precision DEFAULT NULL,
  p_max_lat double precision DEFAULT NULL
)
RETURNS TABLE (
  id uuid,
  owner_user_id text,
  name text,
  area_m2 double precision,
  geometry jsonb,
  captured_at timestamptz,
  updated_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_bounds geometry;
BEGIN
  PERFORM public.assert_profile_user(p_user_id);

  IF p_min_lng IS NOT NULL
     AND p_min_lat IS NOT NULL
     AND p_max_lng IS NOT NULL
     AND p_max_lat IS NOT NULL THEN
    v_bounds := ST_MakeEnvelope(p_min_lng, p_min_lat, p_max_lng, p_max_lat, 4326);
  END IF;

  RETURN QUERY
  SELECT
    t.id,
    t.owner_user_id,
    t.name,
    t.area_m2,
    ST_AsGeoJSON(t.geom)::jsonb AS geometry,
    t.captured_at,
    t.updated_at
  FROM public.captured_territories t
  WHERE v_bounds IS NULL OR ST_Intersects(t.geom, v_bounds)
  ORDER BY t.updated_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_my_territories(p_user_id text)
RETURNS TABLE (
  id uuid,
  owner_user_id text,
  name text,
  area_m2 double precision,
  geometry jsonb,
  captured_at timestamptz,
  updated_at timestamptz
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public.assert_profile_user(p_user_id);

  RETURN QUERY
  SELECT
    t.id,
    t.owner_user_id,
    t.name,
    t.area_m2,
    ST_AsGeoJSON(t.geom)::jsonb AS geometry,
    t.captured_at,
    t.updated_at
  FROM public.captured_territories t
  WHERE t.owner_user_id = p_user_id
  ORDER BY t.updated_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_territory_detail(
  p_user_id text,
  p_territory_id uuid
)
RETURNS TABLE (
  id uuid,
  owner_user_id text,
  owner_display_name text,
  name text,
  area_m2 double precision,
  geometry jsonb,
  captured_at timestamptz,
  updated_at timestamptz,
  source_session_id uuid
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public.assert_profile_user(p_user_id);

  RETURN QUERY
  SELECT
    t.id,
    t.owner_user_id,
    p.display_name AS owner_display_name,
    t.name,
    t.area_m2,
    ST_AsGeoJSON(t.geom)::jsonb AS geometry,
    t.captured_at,
    t.updated_at,
    t.source_session_id
  FROM public.captured_territories t
  JOIN public.profiles p ON p.id = t.owner_user_id
  WHERE t.id = p_territory_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_territory_leaderboard(p_limit integer DEFAULT 50)
RETURNS TABLE (
  user_id text,
  display_name text,
  total_area_m2 double precision,
  territory_count bigint,
  last_capture_at timestamptz,
  rank bigint
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  WITH ranked AS (
    SELECT
      t.owner_user_id,
      SUM(t.area_m2) AS total_area_m2,
      COUNT(*) AS territory_count,
      MAX(t.updated_at) AS last_capture_at
    FROM public.captured_territories t
    GROUP BY t.owner_user_id
  )
  SELECT
    r.owner_user_id AS user_id,
    COALESCE(p.display_name, '') AS display_name,
    r.total_area_m2,
    r.territory_count,
    r.last_capture_at,
    ROW_NUMBER() OVER (ORDER BY r.total_area_m2 DESC, r.last_capture_at DESC) AS rank
  FROM ranked r
  JOIN public.profiles p ON p.id = r.owner_user_id
  ORDER BY rank
  LIMIT GREATEST(p_limit, 1);
END;
$$;

CREATE OR REPLACE VIEW public.territory_leaderboard AS
SELECT
  owner_user_id,
  SUM(area_m2) AS total_area_m2,
  COUNT(*) AS territory_count,
  MAX(updated_at) AS last_capture_at
FROM public.captured_territories
GROUP BY owner_user_id
ORDER BY total_area_m2 DESC;

ALTER TABLE public.territory_capture_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.territory_capture_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.captured_territories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.territory_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "territory_capture_sessions: device access" ON public.territory_capture_sessions;
CREATE POLICY "territory_capture_sessions: device access"
ON public.territory_capture_sessions
FOR ALL TO anon, authenticated
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "territory_capture_points: device access" ON public.territory_capture_points;
CREATE POLICY "territory_capture_points: device access"
ON public.territory_capture_points
FOR ALL TO anon, authenticated
USING (true)
WITH CHECK (true);

DROP POLICY IF EXISTS "captured_territories: read" ON public.captured_territories;
CREATE POLICY "captured_territories: read"
ON public.captured_territories
FOR SELECT TO anon, authenticated
USING (true);

DROP POLICY IF EXISTS "territory_events: read" ON public.territory_events;
CREATE POLICY "territory_events: read"
ON public.territory_events
FOR SELECT TO anon, authenticated
USING (true);

REVOKE INSERT, UPDATE, DELETE ON public.captured_territories FROM anon, authenticated;
REVOKE INSERT, UPDATE, DELETE ON public.territory_events FROM anon, authenticated;

GRANT EXECUTE ON FUNCTION public.assert_profile_user(text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.capture_territory(text, text, jsonb, uuid) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.start_territory_capture_session(text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.save_territory_capture_point(
  text, uuid, double precision, double precision, double precision, double precision, double precision
) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.finish_territory_capture_session(text, uuid, text, jsonb) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.cancel_territory_capture_session(text, uuid) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_territories(
  text, double precision, double precision, double precision, double precision
) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_my_territories(text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_territory_detail(text, uuid) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_territory_leaderboard(integer) TO anon, authenticated;

GRANT SELECT ON public.territory_leaderboard TO anon, authenticated;

-- =============================================================================
-- SECTION 3: Demo seed data (optional territories near Istanbul)
-- =============================================================================

INSERT INTO public.profiles (id, display_name)
VALUES
  ('territory-demo-user-1', 'Demo Runner One'),
  ('territory-demo-user-2', 'Demo Runner Two')
ON CONFLICT (id) DO UPDATE
SET display_name = EXCLUDED.display_name;

SELECT public.capture_territory(
  'territory-demo-user-1',
  'Demo Park Loop',
  jsonb_build_object(
    'type', 'Polygon',
    'coordinates', jsonb_build_array(jsonb_build_array(
      jsonb_build_array(28.97840, 41.00820),
      jsonb_build_array(28.97920, 41.00820),
      jsonb_build_array(28.97920, 41.00900),
      jsonb_build_array(28.97840, 41.00900),
      jsonb_build_array(28.97840, 41.00820)
    ))
  )
);

SELECT public.capture_territory(
  'territory-demo-user-2',
  'Demo River Edge',
  jsonb_build_object(
    'type', 'Polygon',
    'coordinates', jsonb_build_array(jsonb_build_array(
      jsonb_build_array(28.97900, 41.00850),
      jsonb_build_array(28.97960, 41.00850),
      jsonb_build_array(28.97960, 41.00910),
      jsonb_build_array(28.97900, 41.00910),
      jsonb_build_array(28.97900, 41.00850)
    ))
  )
);

-- =============================================================================
-- SECTION 4: Backend tests (optional — uses ROLLBACK, safe to run)
-- =============================================================================

BEGIN;

INSERT INTO public.profiles (id, display_name)
VALUES
  ('territory-test-user-1', 'Territory User 1'),
  ('territory-test-user-2', 'Territory User 2')
ON CONFLICT (id) DO UPDATE
SET display_name = EXCLUDED.display_name;

DELETE FROM public.territory_events
WHERE user_id IN ('territory-test-user-1', 'territory-test-user-2');

DELETE FROM public.captured_territories
WHERE owner_user_id IN ('territory-test-user-1', 'territory-test-user-2');

DELETE FROM public.territory_capture_points
WHERE user_id IN ('territory-test-user-1', 'territory-test-user-2');

DELETE FROM public.territory_capture_sessions
WHERE user_id IN ('territory-test-user-1', 'territory-test-user-2');

DO $$
DECLARE
  v_polygon jsonb := jsonb_build_object(
    'type', 'Polygon',
    'coordinates', jsonb_build_array(jsonb_build_array(
      jsonb_build_array(28.97840, 41.00820),
      jsonb_build_array(28.97940, 41.00820),
      jsonb_build_array(28.97940, 41.00920),
      jsonb_build_array(28.97840, 41.00920),
      jsonb_build_array(28.97840, 41.00820)
    ))
  );
  v_small_polygon jsonb := jsonb_build_object(
    'type', 'Polygon',
    'coordinates', jsonb_build_array(jsonb_build_array(
      jsonb_build_array(28.97840, 41.00820),
      jsonb_build_array(28.9784001, 41.00820),
      jsonb_build_array(28.9784001, 41.0082001),
      jsonb_build_array(28.97840, 41.0082001),
      jsonb_build_array(28.97840, 41.00820)
    ))
  );
  v_overlap_polygon jsonb := jsonb_build_object(
    'type', 'Polygon',
    'coordinates', jsonb_build_array(jsonb_build_array(
      jsonb_build_array(28.97890, 41.00870),
      jsonb_build_array(28.97910, 41.00870),
      jsonb_build_array(28.97910, 41.00890),
      jsonb_build_array(28.97890, 41.00890),
      jsonb_build_array(28.97890, 41.00870)
    ))
  );
  v_session_id uuid;
  v_territory_id uuid;
  v_area double precision;
  v_user1_area double precision;
  v_user2_area double precision;
  v_leaderboard_total double precision;
  v_rejected boolean;
BEGIN
  v_rejected := false;
  BEGIN
    PERFORM public.start_territory_capture_session('invalid-user-id');
  EXCEPTION
    WHEN OTHERS THEN
      v_rejected := true;
  END;
  IF NOT v_rejected THEN
    RAISE EXCEPTION 'Expected invalid user rejection';
  END IF;

  v_rejected := false;
  BEGIN
    PERFORM public.capture_territory(NULL, 'Test Area', v_polygon);
  EXCEPTION
    WHEN OTHERS THEN
      v_rejected := SQLERRM LIKE '%Not authenticated%';
  END;
  IF NOT v_rejected THEN
    RAISE EXCEPTION 'Expected unauthenticated rejection';
  END IF;

  v_rejected := false;
  BEGIN
    PERFORM public.capture_territory('territory-test-user-1', 'Tiny', v_small_polygon);
  EXCEPTION
    WHEN OTHERS THEN
      v_rejected := SQLERRM LIKE '%too small%';
  END;
  IF NOT v_rejected THEN
    RAISE EXCEPTION 'Expected too small polygon rejection';
  END IF;

  SELECT territory_id, area_m2
  INTO v_territory_id, v_area
  FROM public.capture_territory(
    'territory-test-user-1',
    'User 1 Base Area',
    v_polygon
  );

  IF v_territory_id IS NULL OR v_area <= 0 THEN
    RAISE EXCEPTION 'Territory creation failed';
  END IF;

  SELECT public.start_territory_capture_session('territory-test-user-1')
  INTO v_session_id;

  PERFORM public.save_territory_capture_point(
    'territory-test-user-1',
    v_session_id,
    41.00820,
    28.97840,
    5,
    1.2,
    90
  );

  v_rejected := false;
  BEGIN
    PERFORM public.finish_territory_capture_session(
      'territory-test-user-2',
      v_session_id,
      'Wrong User Area',
      v_overlap_polygon
    );
  EXCEPTION
    WHEN OTHERS THEN
      v_rejected := SQLERRM LIKE '%Invalid capture session%';
  END;
  IF NOT v_rejected THEN
    RAISE EXCEPTION 'Expected invalid session owner rejection';
  END IF;

  SELECT territory_id, area_m2
  INTO v_territory_id, v_area
  FROM public.capture_territory(
    'territory-test-user-2',
    'User 2 Overlap Area',
    v_overlap_polygon
  );

  SELECT COALESCE(SUM(area_m2), 0)
  INTO v_user1_area
  FROM public.captured_territories
  WHERE owner_user_id = 'territory-test-user-1';

  SELECT COALESCE(SUM(area_m2), 0)
  INTO v_user2_area
  FROM public.captured_territories
  WHERE owner_user_id = 'territory-test-user-2';

  IF v_user2_area <= 0 THEN
    RAISE EXCEPTION 'Overlap capture did not create new territory';
  END IF;

  IF v_user1_area >= ST_Area(ST_SetSRID(ST_GeomFromGeoJSON(v_polygon::text), 4326)::geography) THEN
    RAISE EXCEPTION 'Overlap capture did not cut old territory';
  END IF;

  SELECT total_area_m2
  INTO v_leaderboard_total
  FROM public.get_territory_leaderboard(10)
  WHERE user_id = 'territory-test-user-2';

  IF v_leaderboard_total IS NULL OR abs(v_leaderboard_total - v_user2_area) > 0.5 THEN
    RAISE EXCEPTION 'Leaderboard total area mismatch';
  END IF;
END $$;

ROLLBACK;
