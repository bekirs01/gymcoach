create extension if not exists "pgcrypto";

insert into storage.buckets (id, name, public)
values ('chat-media', 'chat-media', false)
on conflict (id) do update set public = false;

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_message_text text,
  last_message_at timestamptz
);

create table if not exists public.conversation_participants (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  user_id text not null references public.profiles (id) on delete cascade,
  joined_at timestamptz not null default now(),
  last_read_at timestamptz,
  unique (conversation_id, user_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  sender_id text not null,
  body text not null default '',
  message_type text not null default 'text',
  media_preview_url text,
  client_temp_id text,
  created_at timestamptz not null default now()
);

alter table public.messages drop constraint if exists messages_message_type_check;
alter table public.messages
  add constraint messages_message_type_check
  check (message_type in ('text', 'image', 'voice', 'mixed'));

do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'message_type'
  ) then
    alter table public.messages add column message_type text not null default 'text';
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'media_preview_url'
  ) then
    alter table public.messages add column media_preview_url text;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'client_temp_id'
  ) then
    alter table public.messages add column client_temp_id text;
  end if;
end $$;

create table if not exists public.message_attachments (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.messages (id) on delete cascade,
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  uploader_id text not null,
  storage_bucket text not null default 'chat-media',
  storage_path text not null,
  mime_type text not null,
  size_bytes bigint not null default 0,
  width integer,
  height integer,
  duration_ms integer,
  waveform jsonb,
  original_file_name text,
  created_at timestamptz not null default now()
);

do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'message_attachments' and column_name = 'duration_ms'
  ) then
    alter table public.message_attachments add column duration_ms integer;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'message_attachments' and column_name = 'waveform'
  ) then
    alter table public.message_attachments add column waveform jsonb;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'message_attachments' and column_name = 'original_file_name'
  ) then
    alter table public.message_attachments add column original_file_name text;
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public'
      and table_name = 'conversation_participants'
      and column_name = 'last_read_at'
  ) then
    alter table public.conversation_participants add column last_read_at timestamptz;
  end if;
end $$;

create index if not exists message_attachments_message_id_idx
  on public.message_attachments (message_id);

create index if not exists message_attachments_conversation_id_idx
  on public.message_attachments (conversation_id);

create index if not exists message_attachments_uploader_id_idx
  on public.message_attachments (uploader_id);

create index if not exists messages_conversation_created_at_idx
  on public.messages (conversation_id, created_at);

drop function if exists public.is_chat_participant(uuid) cascade;
drop function if exists public.create_direct_conversation(uuid) cascade;
drop function if exists public.create_direct_conversation(text) cascade;

do $$
declare
  col_type text;
begin
  drop policy if exists "conversations: participants select" on public.conversations;
  drop policy if exists "conversations: participants insert" on public.conversations;
  drop policy if exists "conversations: participants update" on public.conversations;

  drop policy if exists "conversation_participants: participants select" on public.conversation_participants;
  drop policy if exists "conversation_participants: self insert" on public.conversation_participants;
  drop policy if exists "conversation_participants: self update" on public.conversation_participants;

  drop policy if exists "messages: participants select" on public.messages;
  drop policy if exists "messages: participants insert own" on public.messages;
  drop policy if exists "messages: sender insert" on public.messages;
  drop policy if exists "messages: sender update" on public.messages;
  drop policy if exists "messages: sender delete" on public.messages;

  drop policy if exists "message_attachments: participants select" on public.message_attachments;
  drop policy if exists "message_attachments: participants insert own" on public.message_attachments;
  drop policy if exists "message_attachments: uploader update" on public.message_attachments;
  drop policy if exists "message_attachments: uploader delete" on public.message_attachments;

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

  if to_regclass('public.message_attachments') is not null then
    select c.data_type
      into col_type
    from information_schema.columns c
    where c.table_schema = 'public'
      and c.table_name = 'message_attachments'
      and c.column_name = 'uploader_id';

    if col_type = 'uuid' then
      alter table public.message_attachments
        alter column uploader_id type text using uploader_id::text;
    end if;
  end if;
end $$;

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
  );
$$;

create or replace function public.create_direct_conversation(other_user_id text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  conv_id uuid;
  me text := auth.uid()::text;
begin
  if me is null or other_user_id is null or me = other_user_id then
    raise exception 'invalid conversation participants';
  end if;

  select cp1.conversation_id
  into conv_id
  from public.conversation_participants cp1
  inner join public.conversation_participants cp2
    on cp2.conversation_id = cp1.conversation_id
  where cp1.user_id::text = me
    and cp2.user_id::text = other_user_id
  limit 1;

  if conv_id is not null then
    return conv_id;
  end if;

  insert into public.conversations (last_message_text, last_message_at)
  values ('', now())
  returning id into conv_id;

  insert into public.conversation_participants (conversation_id, user_id)
  values
    (conv_id, me),
    (conv_id, other_user_id);

  return conv_id;
end;
$$;

grant execute on function public.is_chat_participant(uuid) to authenticated;
grant execute on function public.create_direct_conversation(text) to authenticated;

alter table public.conversations enable row level security;
alter table public.conversation_participants enable row level security;
alter table public.messages enable row level security;
alter table public.message_attachments enable row level security;

drop policy if exists "conversations: participants select" on public.conversations;
create policy "conversations: participants select" on public.conversations
  for select to authenticated
  using (public.is_chat_participant(id));

drop policy if exists "conversations: participants insert" on public.conversations;
create policy "conversations: participants insert" on public.conversations
  for insert to authenticated
  with check (true);

drop policy if exists "conversations: participants update" on public.conversations;
create policy "conversations: participants update" on public.conversations
  for update to authenticated
  using (public.is_chat_participant(id))
  with check (public.is_chat_participant(id));

drop policy if exists "conversation_participants: participants select" on public.conversation_participants;
create policy "conversation_participants: participants select" on public.conversation_participants
  for select to authenticated
  using (public.is_chat_participant(conversation_id));

drop policy if exists "conversation_participants: self insert" on public.conversation_participants;
create policy "conversation_participants: self insert" on public.conversation_participants
  for insert to authenticated
  with check (user_id::text = auth.uid()::text);

drop policy if exists "messages: participants select" on public.messages;
create policy "messages: participants select" on public.messages
  for select to authenticated
  using (public.is_chat_participant(conversation_id));

drop policy if exists "messages: participants insert own" on public.messages;
create policy "messages: participants insert own" on public.messages
  for insert to authenticated
  with check (
    public.is_chat_participant(conversation_id)
    and sender_id::text = auth.uid()::text
  );

drop policy if exists "message_attachments: participants select" on public.message_attachments;
create policy "message_attachments: participants select" on public.message_attachments
  for select to authenticated
  using (public.is_chat_participant(conversation_id));

drop policy if exists "message_attachments: participants insert own" on public.message_attachments;
create policy "message_attachments: participants insert own" on public.message_attachments
  for insert to authenticated
  with check (
    public.is_chat_participant(conversation_id)
    and uploader_id::text = auth.uid()::text
  );

drop policy if exists "message_attachments: uploader update" on public.message_attachments;
create policy "message_attachments: uploader update" on public.message_attachments
  for update to authenticated
  using (uploader_id::text = auth.uid()::text)
  with check (uploader_id::text = auth.uid()::text);

drop policy if exists "message_attachments: uploader delete" on public.message_attachments;
create policy "message_attachments: uploader delete" on public.message_attachments
  for delete to authenticated
  using (uploader_id::text = auth.uid()::text);

drop policy if exists "chat-media: participant read" on storage.objects;
create policy "chat-media: participant read" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'chat-media'
    and public.is_chat_participant((storage.foldername(name))[1]::uuid)
  );

drop policy if exists "chat-media: participant upload own folder" on storage.objects;
create policy "chat-media: participant upload own folder" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'chat-media'
    and (storage.foldername(name))[2] = auth.uid()::text
    and public.is_chat_participant((storage.foldername(name))[1]::uuid)
  );

drop policy if exists "chat-media: uploader delete" on storage.objects;
create policy "chat-media: uploader delete" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'chat-media'
    and (storage.foldername(name))[2] = auth.uid()::text
    and public.is_chat_participant((storage.foldername(name))[1]::uuid)
  );

do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'messages'
  ) then
    alter publication supabase_realtime add table public.messages;
  end if;
end $$;
