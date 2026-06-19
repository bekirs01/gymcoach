create extension if not exists "pgcrypto";

insert into storage.buckets (id, name, public)
values ('chat-media', 'chat-media', false)
on conflict (id) do update set public = false;

alter table public.profiles
  add column if not exists display_name text,
  add column if not exists username text,
  add column if not exists avatar_url text,
  add column if not exists public_bio text,
  add column if not exists is_public_profile boolean;

update public.profiles
set is_public_profile = true
where is_public_profile is null;

alter table public.profiles
  alter column is_public_profile set default true;

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

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'conversations' and column_name = 'owner_id'
  ) then
    alter table public.conversations
      add column owner_id uuid references auth.users(id) on delete cascade;
  end if;
end $$;

create unique index if not exists conversations_owner_seeded_contact_unique_idx
  on public.conversations (owner_id, seeded_contact_id)
  where is_seeded = true and seeded_contact_id is not null and owner_id is not null;

create unique index if not exists conversations_seeded_contact_unique_idx
  on public.conversations (seeded_contact_id)
  where is_seeded = true and seeded_contact_id is not null;

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

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'edited_at'
  ) then
    alter table public.messages add column edited_at timestamptz;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'deleted_at'
  ) then
    alter table public.messages add column deleted_at timestamptz;
  end if;
end $$;

alter table public.messages drop constraint if exists messages_sender_type_check;
alter table public.messages
  add constraint messages_sender_type_check
  check (sender_type in ('user', 'seeded_contact'));

alter table public.messages drop constraint if exists messages_message_type_check;
alter table public.messages
  add constraint messages_message_type_check
  check (message_type in ('text', 'image', 'voice', 'mixed'));

create table if not exists public.message_attachments (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.messages(id) on delete cascade,
  conversation_id uuid not null references public.conversations(id) on delete cascade,
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

create index if not exists message_attachments_message_id_idx
  on public.message_attachments (message_id);

create index if not exists message_attachments_conversation_id_idx
  on public.message_attachments (conversation_id);

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
  )
  or exists (
    select 1
    from public.conversations c
    where c.id = target_conversation_id
      and c.is_seeded = true
      and c.owner_id = auth.uid()
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

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (
    id,
    display_name,
    username,
    public_bio,
    is_public_profile
  )
  values (
    new.id::text,
    'Бекир Сучукаран',
    'bekir_guest',
    'Building consistency one session at a time.',
    true
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();

grant execute on function public.is_seeded_chat_owner(uuid) to authenticated;
grant execute on function public.is_chat_participant(uuid) to authenticated;

alter table public.profiles enable row level security;
alter table public.chat_contacts enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_participants enable row level security;
alter table public.messages enable row level security;
alter table public.message_attachments enable row level security;

drop policy if exists "profiles: select public" on public.profiles;
create policy "profiles: select public" on public.profiles
  for select to authenticated
  using (coalesce(is_public_profile, true) = true);

drop policy if exists "profiles: select own" on public.profiles;
create policy "profiles: select own" on public.profiles
  for select to authenticated
  using (id = auth.uid()::text);

drop policy if exists "profiles: insert own" on public.profiles;
create policy "profiles: insert own" on public.profiles
  for insert to authenticated
  with check (id = auth.uid()::text);

drop policy if exists "profiles: update own" on public.profiles;
create policy "profiles: update own" on public.profiles
  for update to authenticated
  using (id = auth.uid()::text)
  with check (id = auth.uid()::text);

drop policy if exists "chat_contacts: owner select" on public.chat_contacts;
create policy "chat_contacts: owner select" on public.chat_contacts
  for select to authenticated
  using (owner_id = auth.uid());

drop policy if exists "chat_contacts: owner insert" on public.chat_contacts;
create policy "chat_contacts: owner insert" on public.chat_contacts
  for insert to authenticated
  with check (owner_id = auth.uid());

drop policy if exists "chat_contacts: owner update" on public.chat_contacts;
create policy "chat_contacts: owner update" on public.chat_contacts
  for update to authenticated
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

drop policy if exists "chat_contacts: owner delete" on public.chat_contacts;
create policy "chat_contacts: owner delete" on public.chat_contacts
  for delete to authenticated
  using (owner_id = auth.uid());

drop policy if exists "conversations: participants select" on public.conversations;
create policy "conversations: participants select" on public.conversations
  for select to authenticated
  using (public.is_chat_participant(id));

drop policy if exists "conversations: seeded owner select" on public.conversations;
create policy "conversations: seeded owner select" on public.conversations
  for select to authenticated
  using (is_seeded = true and public.is_seeded_chat_owner(id));

drop policy if exists "conversations: participants insert" on public.conversations;
create policy "conversations: participants insert" on public.conversations
  for insert to authenticated
  with check (true);

drop policy if exists "conversations: seeded owner insert" on public.conversations;
create policy "conversations: seeded owner insert" on public.conversations
  for insert to authenticated
  with check (
    is_seeded = true
    and seeded_contact_id is not null
    and exists (
      select 1
      from public.chat_contacts cc
      where cc.id = seeded_contact_id
        and cc.owner_id = auth.uid()
    )
  );

drop policy if exists "conversations: participants update" on public.conversations;
create policy "conversations: participants update" on public.conversations
  for update to authenticated
  using (public.is_chat_participant(id))
  with check (public.is_chat_participant(id));

drop policy if exists "conversations: seeded owner update" on public.conversations;
create policy "conversations: seeded owner update" on public.conversations
  for update to authenticated
  using (is_seeded = true and public.is_seeded_chat_owner(id))
  with check (is_seeded = true and public.is_seeded_chat_owner(id));

drop policy if exists "conversation_participants: participants select" on public.conversation_participants;
create policy "conversation_participants: participants select" on public.conversation_participants
  for select to authenticated
  using (public.is_chat_participant(conversation_id));

drop policy if exists "conversation_participants: self insert" on public.conversation_participants;
create policy "conversation_participants: self insert" on public.conversation_participants
  for insert to authenticated
  with check (user_id::text = auth.uid()::text);

drop policy if exists "conversation_participants: self update" on public.conversation_participants;
create policy "conversation_participants: self update" on public.conversation_participants
  for update to authenticated
  using (user_id::text = auth.uid()::text)
  with check (user_id::text = auth.uid()::text);

drop policy if exists "messages: participants select" on public.messages;
create policy "messages: participants select" on public.messages
  for select to authenticated
  using (public.is_chat_participant(conversation_id));

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

drop policy if exists "messages: participants insert own" on public.messages;
create policy "messages: participants insert own" on public.messages
  for insert to authenticated
  with check (
    public.is_chat_participant(conversation_id)
    and sender_type = 'user'
    and sender_id::text = auth.uid()::text
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

drop policy if exists "message_attachments: participants select" on public.message_attachments;
create policy "message_attachments: participants select" on public.message_attachments
  for select to authenticated
  using (public.is_chat_participant(conversation_id));

drop policy if exists "message_attachments: seeded owner select" on public.message_attachments;
create policy "message_attachments: seeded owner select" on public.message_attachments
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

drop policy if exists "message_attachments: participants insert own" on public.message_attachments;
create policy "message_attachments: participants insert own" on public.message_attachments
  for insert to authenticated
  with check (
    public.is_chat_participant(conversation_id)
    and uploader_id::text = auth.uid()::text
  );

drop policy if exists "message_attachments: seeded owner insert" on public.message_attachments;
create policy "message_attachments: seeded owner insert" on public.message_attachments
  for insert to authenticated
  with check (
    uploader_id::text = auth.uid()::text
    and exists (
      select 1
      from public.conversations c
      where c.id = conversation_id
        and c.is_seeded = true
        and public.is_seeded_chat_owner(c.id)
    )
  );

drop policy if exists "message_attachments: uploader delete" on public.message_attachments;
create policy "message_attachments: uploader delete" on public.message_attachments
  for delete to authenticated
  using (uploader_id::text = auth.uid()::text);

drop policy if exists "chat-media: guest participant read" on storage.objects;
create policy "chat-media: guest participant read" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'chat-media'
    and (storage.foldername(name))[1] = 'guest'
    and (storage.foldername(name))[2] = auth.uid()::text
    and public.is_chat_participant((storage.foldername(name))[3]::uuid)
  );

drop policy if exists "chat-media: guest participant upload" on storage.objects;
create policy "chat-media: guest participant upload" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'chat-media'
    and (storage.foldername(name))[1] = 'guest'
    and (storage.foldername(name))[2] = auth.uid()::text
    and public.is_chat_participant((storage.foldername(name))[3]::uuid)
  );

drop policy if exists "chat-media: guest uploader delete" on storage.objects;
create policy "chat-media: guest uploader delete" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'chat-media'
    and (storage.foldername(name))[1] = 'guest'
    and (storage.foldername(name))[2] = auth.uid()::text
    and public.is_chat_participant((storage.foldername(name))[3]::uuid)
  );

drop policy if exists "chat-media: conversations participant read" on storage.objects;
create policy "chat-media: conversations participant read" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'chat-media'
    and (storage.foldername(name))[1] = 'conversations'
    and (storage.foldername(name))[3] = auth.uid()::text
    and public.is_chat_participant((storage.foldername(name))[2]::uuid)
  );

drop policy if exists "chat-media: conversations participant upload" on storage.objects;
create policy "chat-media: conversations participant upload" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'chat-media'
    and (storage.foldername(name))[1] = 'conversations'
    and (storage.foldername(name))[3] = auth.uid()::text
    and public.is_chat_participant((storage.foldername(name))[2]::uuid)
  );

drop policy if exists "chat-media: conversations uploader delete" on storage.objects;
create policy "chat-media: conversations uploader delete" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'chat-media'
    and (storage.foldername(name))[1] = 'conversations'
    and (storage.foldername(name))[3] = auth.uid()::text
    and public.is_chat_participant((storage.foldername(name))[2]::uuid)
  );

drop policy if exists "chat-media: seeded participant read" on storage.objects;
create policy "chat-media: seeded participant read" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'chat-media'
    and (storage.foldername(name))[1] = 'seeded'
    and (storage.foldername(name))[2] = auth.uid()::text
    and public.is_chat_participant((storage.foldername(name))[3]::uuid)
  );

drop policy if exists "chat-media: seeded participant upload" on storage.objects;
create policy "chat-media: seeded participant upload" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'chat-media'
    and (storage.foldername(name))[1] = 'seeded'
    and (storage.foldername(name))[2] = auth.uid()::text
    and public.is_chat_participant((storage.foldername(name))[3]::uuid)
  );

drop policy if exists "chat-media: seeded uploader delete" on storage.objects;
create policy "chat-media: seeded uploader delete" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'chat-media'
    and (storage.foldername(name))[1] = 'seeded'
    and (storage.foldername(name))[2] = auth.uid()::text
    and public.is_chat_participant((storage.foldername(name))[3]::uuid)
  );

drop policy if exists "chat-media: participant read" on storage.objects;
create policy "chat-media: participant read" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'chat-media'
    and public.is_chat_participant((storage.foldername(name))[1]::uuid)
    and (storage.foldername(name))[2] = auth.uid()::text
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
