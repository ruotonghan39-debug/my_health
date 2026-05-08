-- TinyBurn Phase 2 — run in Supabase SQL editor (or supabase db push)

-- Profiles (1:1 auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nickname text not null default '',
  avatar text,
  bio text,
  updated_at timestamptz not null default now()
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  type text not null check (type in ('diet', 'exercise', 'weight')),
  content text not null default '',
  images jsonb not null default '[]'::jsonb,
  calories int,
  meta jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists posts_created_at_idx on public.posts (created_at desc);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now()
);

create index if not exists comments_post_id_idx on public.comments (post_id, created_at);

create table if not exists public.weight_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  weight double precision not null,
  recorded_at timestamptz not null default now()
);

create index if not exists weight_records_user_day_idx
  on public.weight_records (user_id, recorded_at desc);

-- RLS
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.weight_records enable row level security;

-- Profiles: everyone authenticated can read; users manage own row
create policy "profiles_select_authenticated"
  on public.profiles for select
  to authenticated
  using (true);

create policy "profiles_insert_own"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

create policy "profiles_update_own"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id);

-- Posts: community read-all for MVP
create policy "posts_select_authenticated"
  on public.posts for select
  to authenticated
  using (true);

create policy "posts_insert_own"
  on public.posts for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "posts_update_own"
  on public.posts for update
  to authenticated
  using (auth.uid() = user_id);

create policy "posts_delete_own"
  on public.posts for delete
  to authenticated
  using (auth.uid() = user_id);

-- Comments
create policy "comments_select_authenticated"
  on public.comments for select
  to authenticated
  using (true);

create policy "comments_insert_own"
  on public.comments for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "comments_delete_own"
  on public.comments for delete
  to authenticated
  using (auth.uid() = user_id);

-- Weight records
create policy "weight_select_own"
  on public.weight_records for select
  to authenticated
  using (auth.uid() = user_id);

create policy "weight_insert_own"
  on public.weight_records for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "weight_delete_own"
  on public.weight_records for delete
  to authenticated
  using (auth.uid() = user_id);

-- New user: optional trigger to create empty profile
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, nickname)
  values (
    new.id,
    coalesce(nullif(split_part(coalesce(new.email, ''), '@', 1), ''), '用户')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Storage bucket (create bucket in Dashboard UI named post-images, public read)
-- Policies below assume bucket id = post-images

insert into storage.buckets (id, name, public)
values ('post-images', 'post-images', true)
on conflict (id) do nothing;

create policy "post_images_select_public"
  on storage.objects for select
  using (bucket_id = 'post-images');

create policy "post_images_insert_authenticated"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'post-images');

create policy "post_images_delete_own_prefix"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'post-images'
    and split_part(name, '/', 1) = auth.uid()::text
  );
