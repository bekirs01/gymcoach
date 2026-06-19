alter table public.feed_posts
  add column if not exists deleted_at timestamptz;

alter table public.feed_posts
  add column if not exists post_type text not null default 'normal';

create index if not exists feed_posts_active_created_idx
  on public.feed_posts (created_at desc)
  where deleted_at is null;

update public.feed_post_media as media
set media_url = 'https://images.unsplash.com/photo-1599058917765-a780eda07a3e?w=900&q=80'
from public.feed_posts as post
where media.post_id = post.id
  and post.deleted_at is null
  and lower(post.caption) like '%battle ropes%'
  and (
    media.media_url is null
    or trim(media.media_url) = ''
    or media.media_url like '%supabase.co/storage%'
  );

update public.feed_post_media as media
set media_url = 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=900&q=80'
from public.feed_posts as post
where media.post_id = post.id
  and post.deleted_at is null
  and lower(post.caption) like '%mirror check%'
  and (
    media.media_url is null
    or trim(media.media_url) = ''
    or media.media_url like '%supabase.co/storage%'
  );

update public.feed_posts as post
set deleted_at = now()
where post.deleted_at is null
  and coalesce(trim(post.caption), '') = ''
  and coalesce(post.post_type, 'normal') <> 'workout_share'
  and not exists (
    select 1
    from public.feed_post_media as media
    where media.post_id = post.id
      and media.media_url is not null
      and trim(media.media_url) <> ''
  );

update public.feed_posts as post
set deleted_at = now()
where post.deleted_at is null
  and exists (
    select 1
    from public.feed_post_media as media
    where media.post_id = post.id
      and (
        media.media_url is null
        or trim(media.media_url) = ''
      )
  )
  and not exists (
    select 1
    from public.feed_post_media as media
    where media.post_id = post.id
      and media.media_url is not null
      and trim(media.media_url) <> ''
  );

delete from public.feed_post_media as media
where media.media_url is null
   or trim(media.media_url) = '';
