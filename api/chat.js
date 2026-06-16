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

    // Call Gemini API
    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=${apiKey}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        systemInstruction: {
          parts: [{ 
            text: "Anda adalah Asisten Cerdas KHUSUS untuk sistem 'Smart Address Desa Manisharjo'. Tugas Anda HANYA menjawab pertanyaan seputar pencarian rumah, navigasi desa, dan informasi dasar Desa Manisharjo. Jika pengguna menanyakan topik di luar konteks ini (seperti politik, sejarah negara, pemrograman, atau topik umum lainnya yang tidak berhubungan dengan Desa Manisharjo), TOLAKLAH dengan sangat sopan dan katakan bahwa Anda hanya diprogram untuk melayani pertanyaan seputar sistem ini. Jawablah dengan ramah, ringkas, dan selalu menggunakan bahasa Indonesia yang baik." 
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
