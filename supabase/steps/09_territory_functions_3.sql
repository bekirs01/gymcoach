-- ADIM 9/13 — Territory fonksiyonları (3/3) + leaderboard view

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
    t.id, t.owner_user_id, t.name, t.area_m2,
    ST_AsGeoJSON(t.geom)::jsonb AS geometry,
    t.captured_at, t.updated_at
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
    t.id, t.owner_user_id, t.name, t.area_m2,
    ST_AsGeoJSON(t.geom)::jsonb AS geometry,
    t.captured_at, t.updated_at
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
    t.id, t.owner_user_id, p.display_name AS owner_display_name,
    t.name, t.area_m2, ST_AsGeoJSON(t.geom)::jsonb AS geometry,
    t.captured_at, t.updated_at, t.source_session_id
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
