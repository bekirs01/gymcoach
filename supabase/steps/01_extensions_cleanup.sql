-- ADIM 1/13 — Extension + eski tabloları temizle
-- Supabase SQL Editor → New query → Run

create extension if not exists "pgcrypto";

drop table if exists public.workout_template_exercises cascade;
drop table if exists public.workout_templates cascade;
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

drop trigger if exists on_auth_user_created on auth.users;
