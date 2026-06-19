-- ADIM 13/13 — Sosyal feed RLS + profil medya storage

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
