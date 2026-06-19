create table if not exists public.stories (
  id uuid primary key default gen_random_uuid(),
  user_id text not null references public.profiles(id) on delete cascade,
  media_path text not null,
  media_url text,
  media_type text not null default 'image',
  caption text,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '24 hours'),
  deleted_at timestamptz
);

create index if not exists stories_user_created_idx
  on public.stories (user_id, created_at desc);

create index if not exists stories_active_idx
  on public.stories (expires_at desc)
  where deleted_at is null;

alter table public.stories enable row level security;

drop policy if exists "stories: read active" on public.stories;
create policy "stories: read active" on public.stories
  for select to anon, authenticated
  using (deleted_at is null and expires_at > now());

drop policy if exists "stories: insert own" on public.stories;
create policy "stories: insert own" on public.stories
  for insert to anon, authenticated
  with check (user_id is not null);

drop policy if exists "stories: update own" on public.stories;
create policy "stories: update own" on public.stories
  for update to anon, authenticated
  using (true)
  with check (true);

drop policy if exists "stories: delete own" on public.stories;
create policy "stories: delete own" on public.stories
  for delete to anon, authenticated
  using (true);

insert into storage.buckets (id, name, public)
values ('story-media', 'story-media', true)
on conflict (id) do update set public = true;

drop policy if exists "story-media: public read" on storage.objects;
create policy "story-media: public read" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'story-media');

drop policy if exists "story-media: public write" on storage.objects;
create policy "story-media: public write" on storage.objects
  for insert to anon, authenticated
  with check (bucket_id = 'story-media');

drop policy if exists "story-media: public update" on storage.objects;
create policy "story-media: public update" on storage.objects
  for update to anon, authenticated
  using (bucket_id = 'story-media')
  with check (bucket_id = 'story-media');

drop policy if exists "story-media: public delete" on storage.objects;
create policy "story-media: public delete" on storage.objects
  for delete to anon, authenticated
  using (bucket_id = 'story-media');
