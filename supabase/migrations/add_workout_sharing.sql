alter table public.feed_posts
  add column if not exists post_type text not null default 'normal'
    check (post_type in ('normal', 'workout_share')),
  add column if not exists shared_workout_snapshot jsonb,
  add column if not exists shared_workout_id text,
  add column if not exists copied_from_post_id text;

create table if not exists public.workout_copies (
  id text primary key,
  user_id text not null references public.profiles(id) on delete cascade,
  feed_post_id text not null references public.feed_posts(id) on delete cascade,
  original_workout_id text,
  copied_workout_id text not null,
  created_at timestamptz not null default now(),
  unique (user_id, feed_post_id)
);

create index if not exists workout_copies_user_idx
  on public.workout_copies (user_id, created_at desc);

alter table public.workout_copies enable row level security;

drop policy if exists "workout_copies: device access" on public.workout_copies;
create policy "workout_copies: device access" on public.workout_copies
  for all to anon, authenticated using (true) with check (true);
