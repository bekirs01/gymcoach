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

drop trigger if exists feed_posts_updated_at on public.feed_posts;
create trigger feed_posts_updated_at
  before update on public.feed_posts
  for each row execute function public.set_updated_at();

alter table public.feed_posts enable row level security;
alter table public.feed_post_media enable row level security;
alter table public.feed_likes enable row level security;
alter table public.feed_comments enable row level security;
alter table public.user_blocks enable row level security;
alter table public.feed_reports enable row level security;

drop policy if exists "feed_posts: device access" on public.feed_posts;
create policy "feed_posts: device access" on public.feed_posts
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "feed_post_media: device access" on public.feed_post_media;
create policy "feed_post_media: device access" on public.feed_post_media
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "feed_likes: device access" on public.feed_likes;
create policy "feed_likes: device access" on public.feed_likes
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "feed_comments: device access" on public.feed_comments;
create policy "feed_comments: device access" on public.feed_comments
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "user_blocks: device access" on public.user_blocks;
create policy "user_blocks: device access" on public.user_blocks
  for all to anon, authenticated using (true) with check (true);

drop policy if exists "feed_reports: device access" on public.feed_reports;
create policy "feed_reports: device access" on public.feed_reports
  for all to anon, authenticated using (true) with check (true);

insert into storage.buckets (id, name, public)
values ('profile-media', 'profile-media', true)
on conflict (id) do update set public = true;

drop policy if exists "profile-media: public read" on storage.objects;
create policy "profile-media: public read" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'profile-media');

drop policy if exists "profile-media: public write" on storage.objects;
create policy "profile-media: public write" on storage.objects
  for insert to anon, authenticated
  with check (bucket_id = 'profile-media');

drop policy if exists "profile-media: public update" on storage.objects;
create policy "profile-media: public update" on storage.objects
  for update to anon, authenticated
  using (bucket_id = 'profile-media')
  with check (bucket_id = 'profile-media');
