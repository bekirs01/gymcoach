do $$
begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'status'
  ) then
    alter table public.messages add column status text not null default 'sent';
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'delivered_at'
  ) then
    alter table public.messages add column delivered_at timestamptz;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'read_at'
  ) then
    alter table public.messages add column read_at timestamptz;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'deleted_for_everyone'
  ) then
    alter table public.messages add column deleted_for_everyone boolean not null default false;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'media_bucket'
  ) then
    alter table public.messages add column media_bucket text;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'media_path'
  ) then
    alter table public.messages add column media_path text;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'media_url'
  ) then
    alter table public.messages add column media_url text;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'audio_duration_ms'
  ) then
    alter table public.messages add column audio_duration_ms integer;
  end if;

  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'messages' and column_name = 'audio_waveform'
  ) then
    alter table public.messages add column audio_waveform jsonb;
  end if;
end $$;

alter table public.messages drop constraint if exists messages_status_check;
alter table public.messages
  add constraint messages_status_check
  check (status in ('sending', 'sent', 'delivered', 'read', 'failed'));

drop policy if exists "chat-media: chat folder read" on storage.objects;
create policy "chat-media: chat folder read" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'chat-media'
    and (storage.foldername(name))[1] = 'chat'
    and (storage.foldername(name))[2] = auth.uid()::text
    and public.is_chat_participant((storage.foldername(name))[3]::uuid)
  );

drop policy if exists "chat-media: chat folder upload" on storage.objects;
create policy "chat-media: chat folder upload" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'chat-media'
    and (storage.foldername(name))[1] = 'chat'
    and (storage.foldername(name))[2] = auth.uid()::text
    and public.is_chat_participant((storage.foldername(name))[3]::uuid)
  );

drop policy if exists "chat-media: chat folder delete" on storage.objects;
create policy "chat-media: chat folder delete" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'chat-media'
    and (storage.foldername(name))[1] = 'chat'
    and (storage.foldername(name))[2] = auth.uid()::text
    and public.is_chat_participant((storage.foldername(name))[3]::uuid)
  );
