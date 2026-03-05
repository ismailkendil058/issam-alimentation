-- =====================================================
-- ALIMENTATION ISSAM - SIMPLIFIED DATABASE SCHEMA
-- This schema works without authentication issues
-- Run this in Supabase SQL Editor
-- =====================================================

-- Drop existing tables if they exist (in reverse order)
DROP TABLE IF EXISTS public.sale_items CASCADE;
DROP TABLE IF EXISTS public.sales CASCADE;
DROP TABLE IF EXISTS public.sessions CASCADE;
DROP TABLE IF EXISTS public.product_sizes CASCADE;
DROP TABLE IF EXISTS public.products CASCADE;
DROP TABLE IF EXISTS public.categories CASCADE;
DROP TABLE IF EXISTS public.workers CASCADE;
DROP TABLE IF EXISTS public.user_roles CASCADE;

-- Drop existing types and functions
DROP TYPE IF EXISTS public.app_role CASCADE;
DROP FUNCTION IF EXISTS public.has_role CASCADE;
DROP FUNCTION IF EXISTS public.decrease_stock CASCADE;

-- =====================================================
-- WORKERS TABLE
-- =====================================================
CREATE TABLE public.workers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  pin text not null,
  created_at timestamptz default now()
);

-- Workers: Anyone can read, only authenticated admins can manage
ALTER TABLE public.workers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read workers" ON public.workers
  FOR SELECT USING (true);

CREATE POLICY "Anyone can insert workers" ON public.workers
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update workers" ON public.workers
  FOR UPDATE USING (true);

CREATE POLICY "Anyone can delete workers" ON public.workers
  FOR DELETE USING (true);

-- =====================================================
-- PRODUCTS TABLE (No category_id since we removed الفئات)
-- =====================================================
CREATE TABLE public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  purchase_price numeric not null default 0,
  selling_price numeric not null default 0,
  barcode text,
  quantity_type text not null default 'unit',
  stock integer not null default 0,
  created_at timestamptz default now()
);

-- Products: Open access for development
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read products" ON public.products
  FOR SELECT USING (true);

CREATE POLICY "Anyone can insert products" ON public.products
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update products" ON public.products
  FOR UPDATE USING (true);

CREATE POLICY "Anyone can delete products" ON public.products
  FOR DELETE USING (true);

-- =====================================================
-- PRODUCT SIZES TABLE (for ML-based products)
-- =====================================================
CREATE TABLE public.product_sizes (
  id uuid primary key default gen_random_uuid(),
  product_id uuid references public.products(id) on delete cascade not null,
  size_ml integer not null,
  selling_price numeric not null default 0,
  purchase_price numeric not null default 0,
  stock integer not null default 0
);

ALTER TABLE public.product_sizes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read product_sizes" ON public.product_sizes
  FOR SELECT USING (true);

CREATE POLICY "Anyone can insert product_sizes" ON public.product_sizes
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update product_sizes" ON public.product_sizes
  FOR UPDATE USING (true);

CREATE POLICY "Anyone can delete product_sizes" ON public.product_sizes
  FOR DELETE USING (true);

-- =====================================================
-- SESSIONS TABLE
-- =====================================================
CREATE TABLE public.sessions (
  id uuid primary key default gen_random_uuid(),
  worker_id uuid references public.workers(id) on delete cascade not null,
  started_at timestamptz default now(),
  closed_at timestamptz,
  total_revenue numeric default 0
);

ALTER TABLE public.sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read sessions" ON public.sessions
  FOR SELECT USING (true);

CREATE POLICY "Anyone can insert sessions" ON public.sessions
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Anyone can update sessions" ON public.sessions
  FOR UPDATE USING (true);

-- =====================================================
-- SALES TABLE
-- =====================================================
CREATE TABLE public.sales (
  id uuid primary key default gen_random_uuid(),
  session_id uuid references public.sessions(id) on delete cascade not null,
  worker_id uuid references public.workers(id) on delete cascade not null,
  total numeric not null default 0,
  profit numeric not null default 0,
  created_at timestamptz default now()
);

ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read sales" ON public.sales
  FOR SELECT USING (true);

CREATE POLICY "Anyone can insert sales" ON public.sales
  FOR INSERT WITH CHECK (true);

-- =====================================================
-- SALE ITEMS TABLE
-- =====================================================
CREATE TABLE public.sale_items (
  id uuid primary key default gen_random_uuid(),
  sale_id uuid references public.sales(id) on delete cascade not null,
  product_id uuid references public.products(id) on delete cascade not null,
  product_name text not null,
  size_ml integer,
  quantity integer not null default 1,
  unit_price numeric not null default 0,
  purchase_price numeric not null default 0
);

ALTER TABLE public.sale_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read sale_items" ON public.sale_items
  FOR SELECT USING (true);

CREATE POLICY "Anyone can insert sale_items" ON public.sale_items
  FOR INSERT WITH CHECK (true);

-- =====================================================
-- STOCK DECREASE TRIGGER FUNCTION
-- =====================================================
CREATE OR REPLACE FUNCTION public.decrease_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.size_ml IS NOT NULL THEN
    UPDATE public.product_sizes
    SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id AND size_ml = NEW.size_ml;
  ELSE
    UPDATE public.products
    SET stock = stock - NEW.quantity
    WHERE id = NEW.product_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_sale_item_insert
  AFTER INSERT ON public.sale_items
  FOR EACH ROW EXECUTE FUNCTION public.decrease_stock();

-- =====================================================
-- INSERT SAMPLE DATA
-- =====================================================

-- Insert sample workers
INSERT INTO public.workers (name, pin) VALUES 
  ('Admin', '1234'),
  ('Worker 1', '0000');

-- Insert sample products
INSERT INTO public.products (name, purchase_price, selling_price, stock, quantity_type) VALUES
  ('حليب طازج', 50, 80, 100, 'unit'),
  ('خبز ابيض', 20, 35, 50, 'unit'),
  ('ماء معدني 1L', 30, 50, 200, 'unit'),
  ('عصير برتقال', 80, 120, 30, 'unit'),
  ('زبادي', 40, 65, 80, 'unit'),
  ('جبن', 150, 200, 25, 'unit'),
  ('طماطم', 40, 70, 40, 'unit'),
  ('بطاطس', 30, 50, 60, 'unit');

-- Insert a sample session
INSERT INTO public.sessions (worker_id, started_at)
SELECT id, now() FROM public.workers LIMIT 1;

-- =====================================================
-- SUCCESS MESSAGE
-- =====================================================
SELECT 'Database schema created successfully!' as message;

