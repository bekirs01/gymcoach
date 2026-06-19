-- ADIM 8/13 — Territory fonksiyonları (2/3)

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
    session_id, user_id, latitude, longitude, accuracy_m, speed_mps, heading
  )
  VALUES (
    p_session_id, p_user_id, p_latitude, p_longitude,
    p_accuracy_m, p_speed_mps, p_heading
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
    p_user_id, p_name, p_polygon_geojson, p_session_id
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

  INSERT INTO public.territory_events (user_id, session_id, event_type, metadata)
  VALUES (p_user_id, p_session_id, 'capture_cancelled', '{}'::jsonb);
END;
$$;
