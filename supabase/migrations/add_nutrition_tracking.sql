create table if not exists public.nutrition_meals (
  id uuid primary key default gen_random_uuid(),
  user_id text not null references public.profiles(id) on delete cascade,
  meal_type text not null default 'unknown',
  title text,
  original_text text not null,
  total_calories integer not null default 0,
  total_protein_g numeric(8, 2) not null default 0,
  total_carbs_g numeric(8, 2) not null default 0,
  total_fat_g numeric(8, 2) not null default 0,
  ai_response jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.nutrition_food_items (
  id uuid primary key default gen_random_uuid(),
  meal_id uuid not null references public.nutrition_meals(id) on delete cascade,
  user_id text not null references public.profiles(id) on delete cascade,
  name text not null,
  original_text text,
  amount numeric(10, 2),
  unit text,
  estimated_grams numeric(10, 2),
  calories integer not null default 0,
  protein_g numeric(8, 2) not null default 0,
  carbs_g numeric(8, 2) not null default 0,
  fat_g numeric(8, 2) not null default 0,
  confidence text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.nutrition_chat_messages (
  id uuid primary key default gen_random_uuid(),
  user_id text not null references public.profiles(id) on delete cascade,
  role text not null,
  content text not null,
  payload jsonb,
  created_at timestamptz not null default now()
);

create index if not exists nutrition_meals_user_created_idx
  on public.nutrition_meals (user_id, created_at desc);

create index if not exists nutrition_food_items_meal_idx
  on public.nutrition_food_items (meal_id);

create index if not exists nutrition_chat_messages_user_created_idx
  on public.nutrition_chat_messages (user_id, created_at desc);

alter table public.nutrition_meals enable row level security;
alter table public.nutrition_food_items enable row level security;
alter table public.nutrition_chat_messages enable row level security;

drop policy if exists nutrition_meals_select_own on public.nutrition_meals;
create policy nutrition_meals_select_own on public.nutrition_meals
  for select using (auth.uid()::text = user_id);

drop policy if exists nutrition_meals_insert_own on public.nutrition_meals;
create policy nutrition_meals_insert_own on public.nutrition_meals
  for insert with check (auth.uid()::text = user_id);

drop policy if exists nutrition_meals_update_own on public.nutrition_meals;
create policy nutrition_meals_update_own on public.nutrition_meals
  for update using (auth.uid()::text = user_id);

drop policy if exists nutrition_meals_delete_own on public.nutrition_meals;
create policy nutrition_meals_delete_own on public.nutrition_meals
  for delete using (auth.uid()::text = user_id);

drop policy if exists nutrition_food_items_select_own on public.nutrition_food_items;
create policy nutrition_food_items_select_own on public.nutrition_food_items
  for select using (auth.uid()::text = user_id);

drop policy if exists nutrition_food_items_insert_own on public.nutrition_food_items;
create policy nutrition_food_items_insert_own on public.nutrition_food_items
  for insert with check (auth.uid()::text = user_id);

drop policy if exists nutrition_food_items_update_own on public.nutrition_food_items;
create policy nutrition_food_items_update_own on public.nutrition_food_items
  for update using (auth.uid()::text = user_id);

drop policy if exists nutrition_food_items_delete_own on public.nutrition_food_items;
create policy nutrition_food_items_delete_own on public.nutrition_food_items
  for delete using (auth.uid()::text = user_id);

drop policy if exists nutrition_chat_messages_select_own on public.nutrition_chat_messages;
create policy nutrition_chat_messages_select_own on public.nutrition_chat_messages
  for select using (auth.uid()::text = user_id);

drop policy if exists nutrition_chat_messages_insert_own on public.nutrition_chat_messages;
create policy nutrition_chat_messages_insert_own on public.nutrition_chat_messages
  for insert with check (auth.uid()::text = user_id);

drop policy if exists nutrition_chat_messages_update_own on public.nutrition_chat_messages;
create policy nutrition_chat_messages_update_own on public.nutrition_chat_messages
  for update using (auth.uid()::text = user_id);

drop policy if exists nutrition_chat_messages_delete_own on public.nutrition_chat_messages;
create policy nutrition_chat_messages_delete_own on public.nutrition_chat_messages
  for delete using (auth.uid()::text = user_id);
