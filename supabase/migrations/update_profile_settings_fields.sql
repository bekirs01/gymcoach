alter table public.profiles
  add column if not exists preferred_language text not null default 'en',
  add column if not exists preferred_units text not null default 'metric',
  add column if not exists training_reminders_enabled boolean not null default true,
  add column if not exists training_reminder_time text not null default '19:00',
  add column if not exists training_reminder_days text not null default 'every_day';

update public.profiles
set training_reminders_enabled = notifications_enabled
where training_reminders_enabled is distinct from notifications_enabled;

update public.profiles
set preferred_language = 'en'
where preferred_language is null or preferred_language = '';

update public.profiles
set preferred_units = 'metric'
where preferred_units is null or preferred_units = '';

update public.profiles
set training_reminder_time = '19:00'
where training_reminder_time is null or training_reminder_time = '';

update public.profiles
set training_reminder_days = 'every_day'
where training_reminder_days is null or training_reminder_days = '';
