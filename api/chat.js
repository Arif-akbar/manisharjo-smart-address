export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed. Gunakan metode POST.' });
  }

  try {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
      return res.status(500).json({ error: 'GEMINI_API_KEY belum disetel di Vercel Environment Variables.' });
    }

    const { message } = req.body;
    if (!message) {
      return res.status(400).json({ error: 'Pesan tidak boleh kosong.' });
    }

    const supabaseUrl = process.env.SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_ANON_KEY;
    
    let contextData = "Data rumah desa saat ini kosong.";
    if (supabaseUrl && supabaseKey) {
      try {
        const dbRes = await fetch(`${supabaseUrl}/rest/v1/houses?select=kode_rumah,nomor_rumah,nama,rt,rw,alamat_tambahan,latitude,longitude&aktif=eq.true`, {
          headers: { 'apikey': supabaseKey, 'Authorization': `Bearer ${supabaseKey}` }
        });
        if (dbRes.ok) {
          const houses = await dbRes.json();
          if (houses && houses.length > 0) {
            contextData = houses.map(h => 
              `- Nama: ${h.nama}, Kode: ${h.kode_rumah}, No: ${h.nomor_rumah}, RT/RW: ${h.rt}/${h.rw}, Info: ${h.alamat_tambahan || '-'}, Koordinat: ${h.latitude},${h.longitude}`
            ).join('\n');
          }
        }
      } catch (err) {
        console.error("Gagal mengambil data dari Supabase:", err);
      }
    }

    // Call Gemini API
    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=${apiKey}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        systemInstruction: {
          parts: [{ 
            text: `Anda adalah Asisten Cerdas KHUSUS untuk sistem 'Smart Address Desa Manisharjo'. Tugas Anda HANYA menjawab pertanyaan seputar pencarian rumah, navigasi desa, dan informasi dasar Desa Manisharjo. Jika pengguna menanyakan topik di luar konteks ini, TOLAKLAH dengan sopan. Jawablah dengan ramah, ringkas, dan berbahasa Indonesia.

Berikut adalah DATA RUMAH AKTIF di Desa Manisharjo saat ini yang HARUS Anda jadikan referensi utama untuk menjawab pertanyaan lokasi warga:
${contextData}

Jika pengguna menanyakan seseorang yang tidak ada di data di atas, katakan dengan sopan bahwa data warga tersebut belum terdaftar di sistem Smart Address.` 
          }]
        },
        contents: [{
          parts: [{ text: message }]
        }]
      })
    });

    const data = await response.json();

    if (!response.ok) {
      return res.status(response.status).json({ error: data.error?.message || 'Gagal terhubung ke Gemini API' });
    }

    // Ekstrak teks balasan dari format kembalian Gemini
    const reply = data.candidates?.[0]?.content?.parts?.[0]?.text || 'Maaf, saya sedang kesulitan memahami pertanyaan tersebut.';

    return res.status(200).json({ reply });
  } catch (error) {
    return res.status(500).json({ error: 'Terjadi kesalahan sistem internal.' });
  }
}
