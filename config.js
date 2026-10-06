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
  SUPABASE_URL: '',

  // 2. ระบุ Supabase Anon Key ของคุณ (ขึ้นต้นด้วย 'eyJh...')
  SUPABASE_ANON_KEY: '',

  // 3. รหัสร้านค้า (สำหรับเชื่อมโยงข้อมูลสาขา)
  STORE_ID: 'default',

  // 4. เวอร์ชันระบบ
  APP_VERSION: '2.1.0'
};

// Helper: ดึง Supabase Client ที่พร้อมใช้งาน (เช็กจาก Config กลาง หรือ LocalStorage Override)
window.getWposSupabaseClient = function() {
  if (typeof window.supabase === 'undefined') return null;
  
  const url = localStorage.getItem('wpos_supabase_url') || window.WPOS_CONFIG.SUPABASE_URL || '';
  const key = localStorage.getItem('wpos_supabase_anon_key') || window.WPOS_CONFIG.SUPABASE_ANON_KEY || '';
  
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
