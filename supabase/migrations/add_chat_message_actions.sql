do $$
begin
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

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'reply_to_message_id'
  ) then
    alter table public.messages
      add column reply_to_message_id uuid references public.messages(id) on delete set null;
  end if;
end $$;

create index if not exists messages_reply_to_message_id_idx
  on public.messages (reply_to_message_id);

create table if not exists public.message_deletions (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.messages(id) on delete cascade,
  user_id text not null,
  deleted_for_me_at timestamptz not null default now(),
  unique (message_id, user_id)
);

create index if not exists message_deletions_user_id_idx
  on public.message_deletions (user_id);

alter table public.message_deletions enable row level security;

drop policy if exists "message_deletions: self select" on public.message_deletions;
create policy "message_deletions: self select" on public.message_deletions
  for select to authenticated
  using (user_id = auth.uid()::text);

drop policy if exists "message_deletions: self insert" on public.message_deletions;
create policy "message_deletions: self insert" on public.message_deletions
  for insert to authenticated
  with check (user_id = auth.uid()::text);

drop policy if exists "messages: sender update" on public.messages;
create policy "messages: sender update" on public.messages
  for update to authenticated
  using (
    sender_id::text = auth.uid()::text
    and sender_type = 'user'
    and public.is_chat_participant(conversation_id)
  )
  with check (
    sender_id::text = auth.uid()::text
    and sender_type = 'user'
    and public.is_chat_participant(conversation_id)
  );

drop policy if exists "messages: seeded owner update" on public.messages;
create policy "messages: seeded owner update" on public.messages
  for update to authenticated
  using (
    sender_type = 'user'
    and sender_id::text = auth.uid()::text
    and exists (
      select 1
      from public.conversations c
      where c.id = conversation_id
        and c.is_seeded = true
        and public.is_seeded_chat_owner(c.id)
    )
  )
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
