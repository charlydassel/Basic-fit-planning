-- =====================================================================
-- Gym Crew : sécurisation de la table "docs" (Row Level Security)
-- À exécuter dans Supabase → SQL Editor, APRÈS avoir ajouté Firebase dans
-- Authentication → Sign In / Providers → Third-party Auth (voir README).
--
-- 1. Remplace TON_EMAIL_ADMIN ci-dessous par l'email de ton compte admin.
-- 2. Exécute tout le script.
-- 3. Mets SB_SECURE=true dans config.js.
--
-- Règles appliquées :
--  - tout le monde peut LIRE les publications (sauf messages privés et signalements) ;
--  - il faut être connecté pour publier ;
--  - chacun ne peut modifier / supprimer QUE ses propres publications ;
--  - l'admin peut tout supprimer et bannir ;
--  - un membre banni ne peut plus rien publier ;
--  - les messages privés ne sont lisibles que par les deux personnes concernées.
--
-- Pour tout annuler : exécute la partie « RETOUR ARRIÈRE » en bas du fichier
-- et remets SB_SECURE=false dans config.js.
-- =====================================================================

create or replace function public.gc_uid() returns text
language sql stable as $$ select coalesce(auth.jwt()->>'sub', '') $$;

create or replace function public.gc_admin() returns boolean
language sql stable as $$
  select lower(coalesce(auth.jwt()->>'email', '')) = lower('TON_EMAIL_ADMIN')
     and public.gc_uid() <> ''
$$;

create or replace function public.gc_banned() returns boolean
language sql stable security definer set search_path = public as $$
  select exists(select 1 from public.docs where collection = 'bans' and id = public.gc_uid())
$$;

-- Le document appartient-il à l'utilisateur connecté ?
create or replace function public.gc_owner(c text, i text, d jsonb) returns boolean
language sql stable as $$
  select public.gc_uid() <> '' and case
    when c in ('sessions','photos','comments','prs','reactions','pr_history','reports') then d->>'uid' = public.gc_uid()
    when c in ('profiles','checkins') then i = public.gc_uid()
    when c = 'follows' then d->>'from' = public.gc_uid()
    when c like 'dm\_%' then d->>'from' = public.gc_uid() and strpos(c, public.gc_uid()) > 0
    when c like 'inbox\_%' then c = 'inbox_' || public.gc_uid() or i = public.gc_uid()
    else false
  end
$$;

-- Qui peut lire ?
create or replace function public.gc_can_read(c text, d jsonb) returns boolean
language sql stable as $$
  select case
    when c like 'dm\_%' then public.gc_uid() <> '' and strpos(c, public.gc_uid()) > 0
    when c like 'inbox\_%' then c = 'inbox_' || public.gc_uid()
    when c = 'reports' then public.gc_admin() or d->>'uid' = public.gc_uid()
    else true
  end
$$;

alter table public.docs enable row level security;

-- Supprime les anciennes règles (y compris celles créées à la main au début du projet)
do $$ declare p record; begin
  for p in select policyname from pg_policies where schemaname = 'public' and tablename = 'docs' loop
    execute format('drop policy %I on public.docs', p.policyname);
  end loop;
end $$;

create policy gc_select on public.docs for select
  using (public.gc_can_read(collection, data));

create policy gc_insert on public.docs for insert
  with check (public.gc_admin() or (not public.gc_banned() and public.gc_owner(collection, id, data)));

create policy gc_update on public.docs for update
  using (public.gc_admin() or public.gc_owner(collection, id, data))
  with check (public.gc_admin() or (not public.gc_banned() and public.gc_owner(collection, id, data)));

create policy gc_delete on public.docs for delete
  using (public.gc_admin() or public.gc_owner(collection, id, data));

-- Temps réel : les changements sont envoyés instantanément aux téléphones
do $$ begin
  alter publication supabase_realtime add table public.docs;
exception when others then null; end $$;

-- =====================================================================
-- RETOUR ARRIÈRE (à exécuter seul si quelque chose ne marche plus) :
--
-- do $$ declare p record; begin
--   for p in select policyname from pg_policies where schemaname='public' and tablename='docs' loop
--     execute format('drop policy %I on public.docs', p.policyname);
--   end loop;
-- end $$;
-- alter table public.docs disable row level security;
-- =====================================================================
