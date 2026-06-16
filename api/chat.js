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

    // Call Gemini API (Gemini 1.5 Flash)
    const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        systemInstruction: {
          parts: [{ 
            text: "Anda adalah Asisten Cerdas untuk sistem 'Smart Address Desa Manisharjo'. Tugas Anda adalah menjawab pertanyaan warga atau kurir terkait desa, layanan, atau data rumah. Jawablah dengan ramah, profesional, ringkas, dan menggunakan bahasa Indonesia yang baik. Jangan memberikan jawaban yang membingungkan atau terlalu panjang." 
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
