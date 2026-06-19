-- ADIM 10/13 — Territory RLS + izinler

ALTER TABLE public.territory_capture_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.territory_capture_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.captured_territories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.territory_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "territory_capture_sessions: device access"
ON public.territory_capture_sessions
FOR ALL TO anon, authenticated
USING (true) WITH CHECK (true);

CREATE POLICY "territory_capture_points: device access"
ON public.territory_capture_points
FOR ALL TO anon, authenticated
USING (true) WITH CHECK (true);

CREATE POLICY "captured_territories: read"
ON public.captured_territories
FOR SELECT TO anon, authenticated
USING (true);

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
