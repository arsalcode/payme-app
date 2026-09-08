import { createClient } from '@supabase/supabase-js';

export const SUPABASE_URL = 'https://nufsjvxspufpiaerermn.supabase.co';
export const SUPABASE_ANON_KEY = 'sb_publishable_0vYNbUVgPHABfm5nwpr17Q_FUDD2quu';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
