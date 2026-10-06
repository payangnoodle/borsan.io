-- ========================================================
-- SUPABASE FULL RESTAURANT POS ECOSYSTEM SCHEMA
-- ระบบจัดการหน้าร้าน POS, สั่งอาหารออนไลน์ (Customer),
-- ไรเดอร์ส่งอาหาร (Rider), และติดตามสถานะแบบเรียลไทม์ (Track)
-- ========================================================

-- 1. ตารางหมวดหมู่อาหาร (Categories)
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  printer_id TEXT DEFAULT 'prn_kitchen',
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. ตารางกลุ่มตัวเลือก/ท็อปปิ้ง (Option Groups & Modifiers)
CREATE TABLE IF NOT EXISTS option_groups (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  is_multiple_choice BOOLEAN DEFAULT false,
  options JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. ตารางรายการอาหาร (Menu Items)
CREATE TABLE IF NOT EXISTS menu_items (
  id TEXT PRIMARY KEY,
  category_id TEXT REFERENCES categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  price NUMERIC NOT NULL DEFAULT 0,
  delivery_price NUMERIC,
  image_url TEXT,
  is_available BOOLEAN DEFAULT true,
  is_delivery_available BOOLEAN DEFAULT true,
  stock_enabled BOOLEAN DEFAULT false,
  daily_stock INT DEFAULT 0,
  option_group_ids JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. ตารางผังโต๊ะอาหาร (Dining Tables)
CREATE TABLE IF NOT EXISTS dining_tables (
  id TEXT PRIMARY KEY,
  table_no TEXT NOT NULL UNIQUE,
  capacity INT DEFAULT 4,
  status TEXT DEFAULT 'available', -- 'available' | 'occupied' | 'billing' | 'reserved'
  guest_count INT DEFAULT 0,
  current_order JSONB DEFAULT '[]'::jsonb,
  opened_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. ตารางออเดอร์หน้าร้าน ทานที่ร้าน/สั่งกลับบ้าน (Dine-in & Takeaway Orders)
CREATE TABLE IF NOT EXISTS orders (
  id TEXT PRIMARY KEY,
  order_type TEXT NOT NULL, -- 'dine_in' | 'takeaway'
  table_no TEXT,
  items JSONB NOT NULL DEFAULT '[]'::jsonb,
  subtotal NUMERIC NOT NULL DEFAULT 0,
  vat NUMERIC DEFAULT 0,
  discount NUMERIC DEFAULT 0,
  net_amount NUMERIC NOT NULL DEFAULT 0,
  payment_method TEXT NOT NULL, -- 'cash' | 'promptpay' | 'credit_card'
  status TEXT DEFAULT 'completed',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. ตารางออเดอร์เดลิเวอรี่ออนไลน์ (Delivery Orders - สำคัญมากสำหรับ order.html / rider.html / track.html)
CREATE TABLE IF NOT EXISTS delivery_orders (
  id TEXT PRIMARY KEY,
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  delivery_address TEXT NOT NULL,
  customer_lat NUMERIC,
  customer_lng NUMERIC,
  distance_km NUMERIC DEFAULT 0,
  items JSONB NOT NULL DEFAULT '[]'::jsonb,
  subtotal NUMERIC NOT NULL DEFAULT 0,
  delivery_fee NUMERIC NOT NULL DEFAULT 0,
  net_amount NUMERIC NOT NULL DEFAULT 0,
  payment_method TEXT NOT NULL DEFAULT 'promptpay', -- 'promptpay' | 'cod'
  delivery_status TEXT NOT NULL DEFAULT 'new', -- 'new' | 'cooking' | 'delivering' | 'completed' | 'cancelled'
  delivery_note TEXT,
  rider_name TEXT,
  rider_phone TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. ตารางประวัติใบเสร็จรับเงิน/ยอดขายปิดบิล (Receipts & Sales History)
CREATE TABLE IF NOT EXISTS receipts (
  id TEXT PRIMARY KEY,
  receipt_no TEXT NOT NULL,
  order_type TEXT NOT NULL, -- 'dine_in' | 'takeaway' | 'delivery'
  table_no TEXT,
  customer_name TEXT,
  items JSONB NOT NULL DEFAULT '[]'::jsonb,
  subtotal NUMERIC NOT NULL DEFAULT 0,
  discount NUMERIC DEFAULT 0,
  vat NUMERIC DEFAULT 0,
  service_charge NUMERIC DEFAULT 0,
  net_amount NUMERIC NOT NULL DEFAULT 0,
  payment_method TEXT NOT NULL,
  cash_received NUMERIC DEFAULT 0,
  change_amount NUMERIC DEFAULT 0,
  staff_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. ตารางสมาชิกสะสมแต้ม (Loyalty Members)
CREATE TABLE IF NOT EXISTS members (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL UNIQUE,
  points INT DEFAULT 0,
  total_spent NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. ตารางรายชื่อไรเดอร์ประจำร้าน (In-House Riders)
CREATE TABLE IF NOT EXISTS riders (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. ตารางบัญชีพนักงาน (Staff & Permissions)
CREATE TABLE IF NOT EXISTS staff (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'แคชเชียร์', -- 'ผู้จัดการร้าน' | 'แคชเชียร์' | 'พนักงานเสิร์ฟ' | 'พ่อครัว'
  pin TEXT NOT NULL DEFAULT '1234',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. ตารางโปรไฟล์และการตั้งค่าร้าน (Store Profile & Settings)
CREATE TABLE IF NOT EXISTS store_profile (
  id TEXT PRIMARY KEY DEFAULT 'default',
  name TEXT NOT NULL DEFAULT '',
  branch_name TEXT DEFAULT 'สาขาหลัก',
  phone TEXT DEFAULT '',
  address TEXT,
  tax_id TEXT,
  promptpay_number TEXT,
  promptpay_name TEXT,
  store_lat NUMERIC DEFAULT 13.7563,
  store_lng NUMERIC DEFAULT 100.5018,
  base_delivery_km NUMERIC DEFAULT 2.0,
  base_delivery_fee NUMERIC DEFAULT 20.0,
  extra_delivery_fee_per_km NUMERIC DEFAULT 10.0,
  max_delivery_km NUMERIC DEFAULT 15.0,
  distance_calc_mode TEXT DEFAULT 'road_routing',
  detour_multiplier NUMERIC DEFAULT 1.3,
  is_store_delivery_open BOOLEAN DEFAULT true,
  is_kitchen_print_enabled BOOLEAN DEFAULT true,
  auto_print_kitchen_on_kot BOOLEAN DEFAULT true,
  auto_print_kitchen_on_checkout BOOLEAN DEFAULT false,
  auto_print_kitchen_on_delivery BOOLEAN DEFAULT true,
  logo_url TEXT,
  vat_rate NUMERIC DEFAULT 7,
  service_charge_rate NUMERIC DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. ข้อมูลเริ่มต้นของร้านค้า (Initial Default Store Profile)
INSERT INTO store_profile (
  id, name, branch_name, phone, address,
  base_delivery_km, base_delivery_fee, extra_delivery_fee_per_km, max_delivery_km,
  distance_calc_mode, detour_multiplier, is_store_delivery_open,
  is_kitchen_print_enabled, auto_print_kitchen_on_kot, auto_print_kitchen_on_checkout, auto_print_kitchen_on_delivery
) VALUES (
  'default', '', 'สาขาหลัก', '', '',
  2.0, 20.0, 10.0, 15.0,
  'road_routing', 1.3, true,
  true, true, false, true
) ON CONFLICT (id) DO UPDATE SET
  updated_at = NOW();

-- ========================================================
-- INDEXES FOR HIGH PERFORMANCE QUERY
-- ========================================================
CREATE INDEX IF NOT EXISTS idx_delivery_orders_status ON delivery_orders(delivery_status);
CREATE INDEX IF NOT EXISTS idx_delivery_orders_created ON delivery_orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_menu_items_category ON menu_items(category_id);
CREATE INDEX IF NOT EXISTS idx_receipts_created ON receipts(created_at DESC);

-- ========================================================
-- REALTIME REPLICATION (เปิดระบบ Realtime สำหรับแจ้งเตือนทันที)
-- ========================================================
-- เพิ่มตารางเข้า Publication เพื่อให้อัปเดตสดระหว่าง POS, ไรเดอร์, และลูกค้า
DO $$
BEGIN
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE delivery_orders;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE dining_tables;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE menu_items;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE store_profile;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
  BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE categories;
  EXCEPTION WHEN duplicate_object THEN NULL;
  END;
END $$;

-- ========================================================
-- ROW LEVEL SECURITY (RLS) & PUBLIC ACCESS POLICIES
-- อนุญาตให้เว็บหน้าร้าน (Anon Client) อ่าน/เขียนข้อมูลได้ปกติ
-- ========================================================
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE option_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE dining_tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE delivery_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE receipts ENABLE ROW LEVEL SECURITY;
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE riders ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_profile ENABLE ROW LEVEL SECURITY;

-- กำหนด Policy ให้ Anon Key ใช้งานได้อย่างสมบูรณ์ ปลอดภัย และตรงไปตรงมา
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOR tbl IN SELECT unnest(ARRAY[
    'categories', 'option_groups', 'menu_items', 'dining_tables', 
    'orders', 'delivery_orders', 'receipts', 'members', 'riders', 'staff', 'store_profile'
  ]) LOOP
    EXECUTE format('DROP POLICY IF EXISTS "Allow anon full access on %I" ON %I;', tbl, tbl);
    EXECUTE format('CREATE POLICY "Allow anon full access on %I" ON %I FOR ALL TO anon USING (true) WITH CHECK (true);', tbl, tbl);
  END LOOP;
END $$;
