create extension if not exists "pgcrypto";

alter table public.feed_posts
  add column if not exists post_type text not null default 'normal',
  add column if not exists shared_workout_snapshot jsonb,
  add column if not exists shared_workout_id text,
  add column if not exists copied_from_post_id text;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'feed_posts_post_type_check'
  ) then
    alter table public.feed_posts
      add constraint feed_posts_post_type_check
      check (post_type in ('normal', 'workout_share'));
  end if;
end $$;

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

create table if not exists public.chat_contacts (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  seed_user_id text not null,
  display_name text not null,
  username text,
  avatar_url text,
  is_seeded boolean not null default true,
  initial_messages_seeded boolean not null default false,
  created_at timestamptz not null default now(),
  unique (owner_id, seed_user_id)
);

create index if not exists chat_contacts_owner_id_idx
  on public.chat_contacts (owner_id);

do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'conversations' and column_name = 'is_seeded'
  ) then
    alter table public.conversations add column is_seeded boolean not null default false;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'conversations' and column_name = 'seeded_contact_id'
  ) then
    alter table public.conversations
      add column seeded_contact_id uuid references public.chat_contacts(id) on delete cascade;
  end if;
end $$;

do $$
declare
  col_type text;
begin
  if to_regclass('public.conversation_participants') is not null then
    select c.data_type
      into col_type
    from information_schema.columns c
    where c.table_schema = 'public'
      and c.table_name = 'conversation_participants'
      and c.column_name = 'user_id';

    if col_type = 'uuid' then
      alter table public.conversation_participants
        drop constraint if exists conversation_participants_user_id_fkey;
      alter table public.conversation_participants
        alter column user_id type text using user_id::text;
    end if;
  end if;

  if to_regclass('public.messages') is not null then
    select c.data_type
      into col_type
    from information_schema.columns c
    where c.table_schema = 'public'
      and c.table_name = 'messages'
      and c.column_name = 'sender_id';

    if col_type = 'uuid' then
      alter table public.messages
        drop constraint if exists messages_sender_id_fkey;
      alter table public.messages
        alter column sender_id type text using sender_id::text;
    end if;
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'sender_type'
  ) then
    alter table public.messages add column sender_type text not null default 'user';
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'seeded_sender_id'
  ) then
    alter table public.messages
      add column seeded_sender_id uuid references public.chat_contacts(id) on delete set null;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'message_type'
  ) then
    alter table public.messages add column message_type text not null default 'text';
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'client_temp_id'
  ) then
    alter table public.messages add column client_temp_id text;
  end if;
end $$;

alter table public.messages drop constraint if exists messages_sender_type_check;
alter table public.messages
  add constraint messages_sender_type_check
  check (sender_type in ('user', 'seeded_contact'));

create or replace function public.is_seeded_chat_owner(target_conversation_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.conversations c
    inner join public.chat_contacts cc on cc.id = c.seeded_contact_id
    where c.id = target_conversation_id
      and c.is_seeded = true
      and cc.owner_id = auth.uid()
  );
$$;

create or replace function public.is_chat_participant(target_conversation_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.conversation_participants cp
    where cp.conversation_id = target_conversation_id
      and cp.user_id::text = auth.uid()::text
  )
  or public.is_seeded_chat_owner(target_conversation_id);
$$;

create or replace function public.get_or_create_seeded_conversation(
  p_seed_user_id text,
  p_display_name text,
  p_username text default null,
  p_avatar_url text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  contact_id uuid;
  conversation_id uuid;
  is_new boolean := false;
begin
  if current_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if p_seed_user_id is null or length(trim(p_seed_user_id)) = 0 then
    raise exception 'Invalid seed user';
  end if;

  insert into public.profiles (id, display_name)
  values (current_user_id::text, 'Athlete')
  on conflict (id) do nothing;

  insert into public.chat_contacts (
    owner_id,
    seed_user_id,
    display_name,
    username,
    avatar_url,
    is_seeded
  )
  values (
    current_user_id,
    p_seed_user_id,
    p_display_name,
    p_username,
    p_avatar_url,
    true
  )
  on conflict (owner_id, seed_user_id) do update
    set
      display_name = excluded.display_name,
      username = coalesce(excluded.username, public.chat_contacts.username),
      avatar_url = coalesce(excluded.avatar_url, public.chat_contacts.avatar_url)
  returning id into contact_id;

  select c.id
    into conversation_id
  from public.conversations c
  where c.is_seeded = true
    and c.seeded_contact_id = contact_id
  limit 1;

  if conversation_id is null then
    is_new := true;
    insert into public.conversations (
      is_seeded,
      seeded_contact_id,
      last_message_text,
      last_message_at
    )
    values (
      true,
      contact_id,
      '',
      now()
    )
    returning id into conversation_id;

    insert into public.conversation_participants (conversation_id, user_id)
    values (conversation_id, current_user_id::text)
    on conflict do nothing;
  end if;

  if is_new then
    perform public.seed_seeded_conversation_messages(conversation_id, contact_id, p_seed_user_id);
  end if;

  return conversation_id;
end;
$$;

grant execute on function public.is_seeded_chat_owner(uuid) to authenticated;
grant execute on function public.is_chat_participant(uuid) to authenticated;
grant execute on function public.get_or_create_seeded_conversation(text, text, text, text) to authenticated;

alter table public.chat_contacts enable row level security;

drop policy if exists "chat_contacts: owner select" on public.chat_contacts;
create policy "chat_contacts: owner select" on public.chat_contacts
  for select to authenticated
  using (owner_id = auth.uid());

drop policy if exists "chat_contacts: owner insert" on public.chat_contacts;
create policy "chat_contacts: owner insert" on public.chat_contacts
  for insert to authenticated
  with check (owner_id = auth.uid());

drop policy if exists "conversations: seeded owner select" on public.conversations;
create policy "conversations: seeded owner select" on public.conversations
  for select to authenticated
  using (
    is_seeded = true
    and public.is_seeded_chat_owner(id)
  );

drop policy if exists "messages: seeded owner select" on public.messages;
create policy "messages: seeded owner select" on public.messages
  for select to authenticated
  using (
    exists (
      select 1
      from public.conversations c
      where c.id = conversation_id
        and c.is_seeded = true
        and public.is_seeded_chat_owner(c.id)
    )
  );

drop policy if exists "messages: seeded owner insert" on public.messages;
create policy "messages: seeded owner insert" on public.messages
  for insert to authenticated
  with check (
    sender_type = 'user'
    and sender_id::text = auth.uid()::text
    and exists (
      select 1
      from public.conversations c
      where c.id = conversation_id
        and c.is_seeded = true
        and public.is_seeded_chat_owner(c.id)
    )
  );
