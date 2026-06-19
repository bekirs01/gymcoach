-- ADIM 7/13 — Territory fonksiyonları (1/3)

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
      user_id, territory_id, session_id, event_type, area_m2, metadata
    )
    VALUES (
      p_user_id, v_territory_id, p_session_id, 'capture_completed', v_area,
      jsonb_build_object('name', trim(p_name))
    );
  END IF;

  INSERT INTO public.territory_events (
    user_id, territory_id, session_id, event_type, area_m2, metadata
  )
  VALUES (
    p_user_id, v_territory_id, p_session_id, 'territory_created', v_area,
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

  INSERT INTO public.territory_events (user_id, session_id, event_type, metadata)
  VALUES (p_user_id, v_session_id, 'capture_started', '{}'::jsonb);

  RETURN v_session_id;
END;
$$;
