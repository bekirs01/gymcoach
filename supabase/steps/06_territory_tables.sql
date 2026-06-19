-- ADIM 6/13 — PostGIS + Territory tabloları
-- PostGIS hata verirse: Dashboard → Database → Extensions → postgis → Enable

CREATE EXTENSION IF NOT EXISTS postgis;

CREATE TABLE public.territory_capture_sessions (
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

CREATE TABLE public.territory_capture_points (
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

CREATE INDEX idx_territory_capture_points_session_id
  ON public.territory_capture_points(session_id);

CREATE INDEX idx_territory_capture_points_geom
  ON public.territory_capture_points USING gist(geom);

CREATE TABLE public.captured_territories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id text NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  source_session_id uuid REFERENCES public.territory_capture_sessions(id) ON DELETE SET NULL,
  name text NOT NULL,
  geom geometry(MultiPolygon, 4326) NOT NULL,
  area_m2 double precision NOT NULL DEFAULT 0,
  captured_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_captured_territories_owner_user_id
  ON public.captured_territories(owner_user_id);

CREATE INDEX idx_captured_territories_geom
  ON public.captured_territories USING gist(geom);

CREATE TABLE public.territory_events (
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

CREATE TRIGGER trg_set_captured_territory_area
BEFORE INSERT OR UPDATE OF geom
ON public.captured_territories
FOR EACH ROW
EXECUTE FUNCTION public.set_captured_territory_area();

CREATE TRIGGER territory_capture_sessions_updated_at
BEFORE UPDATE ON public.territory_capture_sessions
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();
