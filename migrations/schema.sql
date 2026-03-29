-- =============================================================================
-- AI Fabric Product Description & SEO — production schema (Supabase / PostgreSQL)
-- =============================================================================
-- Auth: Supabase Auth email/password only; reference auth.users via FKs.
-- Do not run automatically — apply via Supabase SQL editor or migration tooling.
-- =============================================================================

-- UUID generation (Supabase typically enables this; safe if already present)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- -----------------------------------------------------------------------------
-- Tables (dependency order: profiles → products; both depend on auth.users)
-- -----------------------------------------------------------------------------

-- One profile row per authenticated user (1:1 with auth.users).
CREATE TABLE public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  full_name text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT profiles_full_name_length CHECK (
    full_name IS NULL OR char_length(trim(full_name)) > 0
  )
);

COMMENT ON TABLE public.profiles IS 'Application profile; id matches auth.users.id (email/password users only).';
COMMENT ON COLUMN public.profiles.full_name IS 'Optional display name for UI.';

-- Fabric products: AI-generated description/SEO fields per PRD.
CREATE TABLE public.products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  name text NOT NULL,
  features jsonb NOT NULL DEFAULT '{}'::jsonb,
  description text,
  seo_title text,
  bullet_points jsonb NOT NULL DEFAULT '[]'::jsonb,
  meta_description text,
  is_published boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT products_name_not_blank CHECK (char_length(trim(name)) > 0),
  CONSTRAINT products_features_json_kind CHECK (
    jsonb_typeof(features) IN ('object', 'array')
  ),
  CONSTRAINT products_bullet_points_is_array CHECK (
    jsonb_typeof(bullet_points) = 'array'
  )
);

COMMENT ON TABLE public.products IS 'Fabric product content; scoped by user_id for RLS.';
COMMENT ON COLUMN public.products.features IS 'JSON object or array: material, traits, use cases, etc.';
COMMENT ON COLUMN public.products.bullet_points IS 'JSON array of strings (3–5 highlights).';
COMMENT ON COLUMN public.products.is_published
  IS 'When true, row is readable by public SELECT policy (storefront/catalog).';

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------

CREATE INDEX idx_products_user_id ON public.products (user_id);

CREATE INDEX idx_products_user_created_at
  ON public.products (user_id, created_at DESC);

CREATE INDEX idx_products_created_at ON public.products (created_at DESC);

CREATE INDEX idx_products_published_created_at
  ON public.products (is_published, created_at DESC)
  WHERE is_published;

CREATE INDEX idx_products_features_gin ON public.products USING gin (features);

-- -----------------------------------------------------------------------------
-- Functions
-- -----------------------------------------------------------------------------

-- Generic trigger: keep updated_at in sync with server clock.
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.set_updated_at() IS 'Sets NEW.updated_at to now() before UPDATE.';

-- After signup: create a profile row for each new auth.users row (Supabase pattern).
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id) VALUES (NEW.id)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

COMMENT ON FUNCTION public.handle_new_user() IS 'Inserts public.profiles when auth.users gains a row.';

-- -----------------------------------------------------------------------------
-- Triggers
-- -----------------------------------------------------------------------------

CREATE TRIGGER profiles_set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER products_set_updated_at
  BEFORE UPDATE ON public.products
  FOR EACH ROW
  EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- -----------------------------------------------------------------------------
-- Row Level Security
-- -----------------------------------------------------------------------------

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- profiles: users can read/insert/update/delete only their own row (id = auth.uid()).
CREATE POLICY profiles_select_own
  ON public.profiles
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY profiles_insert_own
  ON public.profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (id = auth.uid());

CREATE POLICY profiles_update_own
  ON public.profiles
  FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

CREATE POLICY profiles_delete_own
  ON public.profiles
  FOR DELETE
  TO authenticated
  USING (id = auth.uid());

-- products: owners full CRUD; anyone (including anon) can SELECT published rows.
CREATE POLICY products_select_owner_or_published
  ON public.products
  FOR SELECT
  TO anon, authenticated
  USING (user_id = auth.uid() OR is_published);

CREATE POLICY products_insert_owner
  ON public.products
  FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY products_update_owner
  ON public.products
  FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY products_delete_owner
  ON public.products
  FOR DELETE
  TO authenticated
  USING (user_id = auth.uid());
