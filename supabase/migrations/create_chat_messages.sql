create extension if not exists "pgcrypto";

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_message_id uuid,
  last_message_text text,
  last_message_at timestamptz
);

create table if not exists public.conversation_participants (
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  joined_at timestamptz not null default now(),
  last_read_at timestamptz,
  primary key (conversation_id, user_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references auth.users(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now(),
  edited_at timestamptz,
  deleted_at timestamptz
);

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
    where table_schema = 'public' and table_name = 'messages' and column_name = 'client_temp_id'
  ) then
    alter table public.messages add column client_temp_id text;
  end if;
end $$;

create index if not exists messages_conversation_created_idx
  on public.messages (conversation_id, created_at);

create index if not exists conversation_participants_user_idx
  on public.conversation_participants (user_id);

create index if not exists conversations_last_message_at_idx
  on public.conversations (last_message_at desc nulls last);

drop function if exists public.is_chat_participant(uuid) cascade;
drop function if exists public.create_direct_conversation(uuid) cascade;
drop function if exists public.create_direct_conversation(text) cascade;

create or replace function public.is_chat_participant(p_conversation_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.conversation_participants cp
    where cp.conversation_id = p_conversation_id
      and cp.user_id = auth.uid()
  );
$$;

create or replace function public.handle_new_chat_message()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.conversations
  set
    last_message_id = new.id,
    last_message_text = new.body,
    last_message_at = new.created_at,
    updated_at = now()
  where id = new.conversation_id;

  return new;
end;
$$;

drop trigger if exists messages_after_insert on public.messages;
create trigger messages_after_insert
  after insert on public.messages
  for each row
  execute function public.handle_new_chat_message();

create or replace function public.create_direct_conversation(other_user_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  current_user_id uuid := auth.uid();
  existing_conversation_id uuid;
  new_conversation_id uuid;
begin
  if current_user_id is null then
    raise exception 'Not authenticated';
  end if;

  if other_user_id is null or other_user_id = current_user_id then
    raise exception 'Invalid participant';
  end if;

  select cp1.conversation_id
    into existing_conversation_id
  from public.conversation_participants cp1
  inner join public.conversation_participants cp2
    on cp2.conversation_id = cp1.conversation_id
  where cp1.user_id = current_user_id
    and cp2.user_id = other_user_id
  limit 1;

  if existing_conversation_id is not null then
    return existing_conversation_id;
  end if;

  new_conversation_id := gen_random_uuid();

  insert into public.conversations (id)
  values (new_conversation_id);

  insert into public.conversation_participants (conversation_id, user_id)
  values
    (new_conversation_id, current_user_id),
    (new_conversation_id, other_user_id);

  return new_conversation_id;
end;
$$;

alter table public.conversations enable row level security;
alter table public.conversation_participants enable row level security;
alter table public.messages enable row level security;

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
  with check (user_id = auth.uid());

drop policy if exists "conversation_participants: self update" on public.conversation_participants;
create policy "conversation_participants: self update" on public.conversation_participants
  for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists "messages: participants select" on public.messages;
create policy "messages: participants select" on public.messages
  for select to authenticated
  using (
    public.is_chat_participant(conversation_id)
    and deleted_at is null
  );

drop policy if exists "messages: sender insert" on public.messages;
create policy "messages: sender insert" on public.messages
  for insert to authenticated
  with check (
    sender_id = auth.uid()
    and public.is_chat_participant(conversation_id)
  );

drop policy if exists "messages: sender update" on public.messages;
create policy "messages: sender update" on public.messages
  for update to authenticated
  using (sender_id = auth.uid())
  with check (sender_id = auth.uid());

drop policy if exists "messages: sender delete" on public.messages;
create policy "messages: sender delete" on public.messages
  for delete to authenticated
  using (sender_id = auth.uid());

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
