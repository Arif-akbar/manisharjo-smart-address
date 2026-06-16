export default async function handler(req, res) {
  try {
    // Mengambil URL dan Key dari Environment Variables Vercel
    const supabaseUrl = process.env.SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_ANON_KEY;
    
    if (!supabaseUrl || !supabaseKey) {
      return res.status(500).json({ 
        status: 'Error',
        error: 'SUPABASE_URL atau SUPABASE_ANON_KEY belum disetel di Vercel Environment Variables.' 
      });
    }

    // Melakukan request REST API super ringan ke Supabase
    // Mengambil 1 baris dari tabel 'houses' hanya untuk mencatat "Aktivitas" di server Supabase
    const response = await fetch(`${supabaseUrl}/rest/v1/houses?select=id&limit=1`, {
      method: 'GET',
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    });

    if (response.ok) {
      return res.status(200).json({ 
        status: 'OK', 
        message: 'Ping berhasil! Database Supabase sukses diketuk dan akan terus aktif.' 
      });
    } else {
      return res.status(response.status).json({ 
        status: 'Error', 
        message: 'Gagal merespon dari Supabase.',
        details: await response.text()
      });
    }
  } catch (error) {
    return res.status(500).json({ status: 'Error', message: error.message });
  }
}
