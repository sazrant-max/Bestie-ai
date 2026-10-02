
-- V8 subscription/trial state
create table if not exists public.subscriptions(
 user_id uuid primary key references auth.users(id) on delete cascade,
 provider text not null default 'stripe',
 provider_customer_id text,
 provider_subscription_id text,
 status text not null default 'trialing' check(status in('trialing','active','past_due','canceled','incomplete','unpaid')),
 trial_started_at timestamptz, trial_ends_at timestamptz, current_period_end timestamptz,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
alter table public.subscriptions enable row level security;
drop policy if exists subscriptions_self on public.subscriptions;
create policy subscriptions_self on public.subscriptions for select to authenticated using(user_id=auth.uid() or public.is_owner());
create or replace function public.has_premium_access()
returns boolean language sql stable security definer set search_path=public as $$
select exists(select 1 from public.subscriptions where user_id=auth.uid() and (status='active' or (status='trialing' and trial_ends_at>now())));
$$;
revoke all on function public.has_premium_access() from public;
grant execute on function public.has_premium_access() to authenticated;

-- V9 payment indexes
create index if not exists subscriptions_status_idx on public.subscriptions(status);
create index if not exists subscriptions_trial_idx on public.subscriptions(trial_ends_at);
