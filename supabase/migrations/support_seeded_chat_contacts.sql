create extension if not exists "pgcrypto";

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

create or replace function public.seed_seeded_conversation_messages(
  p_conversation_id uuid,
  p_contact_id uuid,
  p_seed_user_id text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  already_seeded boolean;
begin
  select cc.initial_messages_seeded
    into already_seeded
  from public.chat_contacts cc
  where cc.id = p_contact_id;

  if coalesce(already_seeded, false) then
    return;
  end if;

  if exists (
    select 1
    from public.messages m
    where m.conversation_id = p_conversation_id
    limit 1
  ) then
    update public.chat_contacts
    set initial_messages_seeded = true
    where id = p_contact_id;
    return;
  end if;

  if p_seed_user_id = 'seed_sofia' then
    insert into public.messages (conversation_id, sender_id, sender_type, seeded_sender_id, body, message_type, created_at)
    values
      (p_conversation_id, 'seed_sofia', 'seeded_contact', p_contact_id, 'Hey, did you train today?', 'text', now() - interval '18 minutes'),
      (p_conversation_id, auth.uid()::text, 'user', null, 'Yes, just finished shoulders.', 'text', now() - interval '16 minutes'),
      (p_conversation_id, 'seed_sofia', 'seeded_contact', p_contact_id, 'Nice, I''m going to the gym later.', 'text', now() - interval '14 minutes'),
      (p_conversation_id, auth.uid()::text, 'user', null, 'Send your workout after.', 'text', now() - interval '12 minutes'),
      (p_conversation_id, 'seed_sofia', 'seeded_contact', p_contact_id, 'Sure 😄', 'text', now() - interval '2 minutes');
  elsif p_seed_user_id = 'seed_maria' then
    insert into public.messages (conversation_id, sender_id, sender_type, seeded_sender_id, body, message_type, created_at)
    values
      (p_conversation_id, 'seed_maria', 'seeded_contact', p_contact_id, 'How was your leg day?', 'text', now() - interval '45 minutes'),
      (p_conversation_id, auth.uid()::text, 'user', null, 'Hard but good.', 'text', now() - interval '40 minutes'),
      (p_conversation_id, 'seed_maria', 'seeded_contact', p_contact_id, 'Same here, I''m still tired.', 'text', now() - interval '30 minutes'),
      (p_conversation_id, auth.uid()::text, 'user', null, 'Recovery day tomorrow.', 'text', now() - interval '15 minutes');
  elsif p_seed_user_id = 'seed_anastasia' then
    insert into public.messages (conversation_id, sender_id, sender_type, seeded_sender_id, body, message_type, created_at)
    values
      (p_conversation_id, 'seed_anastasia', 'seeded_contact', p_contact_id, 'Did you try the new stretch routine?', 'text', now() - interval '70 minutes'),
      (p_conversation_id, auth.uid()::text, 'user', null, 'Not yet, sending it now.', 'text', now() - interval '60 minutes'),
      (p_conversation_id, 'seed_anastasia', 'seeded_contact', p_contact_id, 'Sent a workout plan', 'text', now() - interval '55 minutes');
  elsif p_seed_user_id = 'seed_ekaterina' then
    insert into public.messages (conversation_id, sender_id, sender_type, seeded_sender_id, body, message_type, created_at)
    values
      (p_conversation_id, 'seed_ekaterina', 'seeded_contact', p_contact_id, 'Any tips for pacing on long runs?', 'text', now() - interval '3 hours 20 minutes'),
      (p_conversation_id, auth.uid()::text, 'user', null, 'Start slow, finish strong.', 'text', now() - interval '3 hours 10 minutes'),
      (p_conversation_id, 'seed_ekaterina', 'seeded_contact', p_contact_id, 'Thanks for the tips!', 'text', now() - interval '3 hours');
  elsif p_seed_user_id = 'seed_alexey' then
    insert into public.messages (conversation_id, sender_id, sender_type, seeded_sender_id, body, message_type, created_at)
    values
      (p_conversation_id, 'seed_alexey', 'seeded_contact', p_contact_id, 'Squats felt heavy today.', 'text', now() - interval '1 day 30 minutes'),
      (p_conversation_id, auth.uid()::text, 'user', null, 'Same, deload week maybe?', 'text', now() - interval '1 day 20 minutes'),
      (p_conversation_id, 'seed_alexey', 'seeded_contact', p_contact_id, 'Leg day was intense', 'text', now() - interval '1 day');
  end if;

  update public.chat_contacts
  set initial_messages_seeded = true
  where id = p_contact_id;
end;
$$;

grant execute on function public.is_seeded_chat_owner(uuid) to authenticated;
grant execute on function public.get_or_create_seeded_conversation(text, text, text, text) to authenticated;
grant execute on function public.seed_seeded_conversation_messages(uuid, uuid, text) to authenticated;

alter table public.chat_contacts enable row level security;

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

drop policy if exists "conversations: seeded owner select" on public.conversations;
create policy "conversations: seeded owner select" on public.conversations
  for select to authenticated
  using (
    is_seeded = true
    and public.is_seeded_chat_owner(id)
  );

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

drop policy if exists "conversations: seeded owner update" on public.conversations;
create policy "conversations: seeded owner update" on public.conversations
  for update to authenticated
  using (is_seeded = true and public.is_seeded_chat_owner(id))
  with check (is_seeded = true and public.is_seeded_chat_owner(id));

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
