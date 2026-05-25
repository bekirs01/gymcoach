-- Demo territory data for local/staging previews.
-- Safe to run multiple times.

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
