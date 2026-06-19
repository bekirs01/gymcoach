-- ADIM 12/13 — Sosyal feed tabloları

alter table public.profiles
  add column if not exists bio text not null default '',
  add column if not exists private_notes text not null default '',
  add column if not exists avatar_url text not null default '',
  add column if not exists cover_url text not null default '',
  add column if not exists is_public boolean not null default true;

create table if not exists public.feed_posts (
  id text primary key,
  user_id text not null references public.profiles(id) on delete cascade,
  caption text not null default '',
  visibility text not null default 'public' check (visibility in ('public', 'private')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists feed_posts_created_idx
  on public.feed_posts (created_at desc);

create table if not exists public.feed_post_media (
  id text primary key,
  post_id text not null references public.feed_posts(id) on delete cascade,
  media_url text not null,
  media_path text not null default '',
  sort_order integer not null check (sort_order >= 0),
  created_at timestamptz not null default now()
);

create index if not exists feed_post_media_post_idx
  on public.feed_post_media (post_id, sort_order);

create table if not exists public.feed_likes (
  post_id text not null references public.feed_posts(id) on delete cascade,
  user_id text not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create table if not exists public.feed_comments (
  id text primary key,
  post_id text not null references public.feed_posts(id) on delete cascade,
  user_id text not null references public.profiles(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now()
);

create index if not exists feed_comments_post_idx
  on public.feed_comments (post_id, created_at asc);

create table if not exists public.user_blocks (
  blocker_user_id text not null references public.profiles(id) on delete cascade,
  blocked_user_id text not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_user_id, blocked_user_id),
  check (blocker_user_id <> blocked_user_id)
);

create table if not exists public.feed_reports (
  id text primary key,
  reporter_user_id text not null references public.profiles(id) on delete cascade,
  post_id text references public.feed_posts(id) on delete cascade,
  reported_user_id text references public.profiles(id) on delete cascade,
  reason text not null default '',
  created_at timestamptz not null default now()
);

create trigger feed_posts_updated_at
  before update on public.feed_posts
  for each row execute function public.set_updated_at();
