-- ADIM 2/13 — Profiller + egzersiz kataloğu
-- Önce ADIM 1 başarılı olmalı

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
