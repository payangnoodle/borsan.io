/**
 * ========================================================
 * WPOS - Global Configuration (การตั้งค่าระบบและ Cloud กลาง)
 * ========================================================
 * ใส่ Supabase Project URL และ Anon Key ที่ได้จากแดชบอร์ด Supabase ของคุณ
 * เพื่อให้อุปกรณ์ทุกเครื่อง (แท็บเล็ตหน้าร้าน, มือถือลูกค้า, มือถือไรเดอร์)
 * สามารถสื่อสารและรับ-ส่งออเดอร์ข้ามเครื่องกันได้แบบสดๆ (Realtime Cloud Sync)
 */

window.WPOS_CONFIG = {
  // 1. ระบุ Supabase URL ของคุณ (เช่น 'https://xyzcompany.supabase.co')
  SUPABASE_URL: 'https://zvqfprabmfvmnlmrtifq.supabase.co',

  // 2. ระบุ Supabase Anon Key ของคุณ (ขึ้นต้นด้วย 'eyJh...')
  SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp2cWZwcmFibWZ2bW5sbXJ0aWZxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEzMDIxMzAsImV4cCI6MjEwNjg3ODEzMH0.v7qyWNY_h28OGTOefK6NEDweZmbyNLNKVYV1Xr5ARSU',

  // 3. รหัสร้านค้า (สำหรับเชื่อมโยงข้อมูลสาขา)
  STORE_ID: 'default',

  // 4. เวอร์ชันระบบ
  APP_VERSION: '2.1.0',

  // 5. ข้อมูลร้านค้าเริ่มต้น (แสดงผลกรณีเปิดเว็บครั้งแรกหรือยังไม่ได้ต่อ Supabase)
  DEFAULT_STORE: {
    name: 'ก๋วยเตี๋ยวป่ายาง @บ่อแสน',
    branch_name: 'สาขาหลัก',
    phone: '',
    address: '',
    promptpay_number: ''
  },

  // 6. หมวดหมู่อาหารเริ่มต้น (กรณีไม่ได้เชื่อมต่อ Supabase หรือเครื่องลูกค้าเปิดครั้งแรก)
  DEFAULT_CATEGORIES: [],

  // 7. รายการอาหารเริ่มต้น (กรณีไม่ได้เชื่อมต่อ Supabase หรือเครื่องลูกค้าเปิดครั้งแรก)
  DEFAULT_MENU_ITEMS: [],

  // 8. กลุ่มตัวเลือกและท็อปปิ้งเริ่มต้น
  DEFAULT_OPTION_GROUPS: []
};

// Helper: ดึง Supabase Client ที่พร้อมใช้งาน (เช็กจาก Config กลาง หรือ LocalStorage Override)
window.getWposSupabaseClient = function() {
  if (typeof window.supabase === 'undefined') return null;
  
  let url = localStorage.getItem('wpos_supabase_url') || window.WPOS_CONFIG.SUPABASE_URL || '';
  let key = localStorage.getItem('wpos_supabase_anon_key') || window.WPOS_CONFIG.SUPABASE_ANON_KEY || '';
  
  url = url.trim().replace(/\/rest\/v1\/?$/i, '').replace(/\/+$/, '');
  key = key.trim();

  if (!url || !key) return null;
  
  if (!window._wpos_sb_instance || window._wpos_sb_instance_url !== url || window._wpos_sb_instance_key !== key) {
    try {
      window._wpos_sb_instance = window.supabase.createClient(url, key);
      window._wpos_sb_instance_url = url;
      window._wpos_sb_instance_key = key;
    } catch (e) {
      console.warn('Failed to initialize Supabase client:', e);
      return null;
    }
  }
  return window._wpos_sb_instance;
};
