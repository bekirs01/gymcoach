-- Territory capture backend tests
-- Run in Supabase SQL Editor after applying 20260527000000_territory_capture.sql

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
