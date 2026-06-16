import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Data statis untuk preview tampilan
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Halo! Saya adalah Asisten AI Manisharjo Smart Address. Ada yang bisa saya bantu hari ini?", 
      isUser: false
    ),
    ChatMessage(
      text: "Tolong carikan lokasi rumah Bapak Budi Santoso dong.", 
      isUser: true
    ),
    ChatMessage(
      text: "Baik, Bapak Budi Santoso tinggal di RT 02 / RW 01, Nomor Rumah 45 (Kode: RMH-0045). Apakah Anda ingin saya arahkan rute Google Maps ke sana?", 
      isUser: false
    ),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(text: _messageController.text, isUser: true));
      // Indikator berpikir
      _messages.add(ChatMessage(text: "Mengetik...", isUser: false));
    });
    
    final userText = _messageController.text;
    _messageController.clear();
    _scrollToBottom();
    
    _fetchAIResponse(userText);
  }

  Future<void> _fetchAIResponse(String message) async {
    try {
      final String? directApiKey = dotenv.env['GEMINI_API_KEY'];
      String replyText = '';

      if (directApiKey != null && directApiKey.isNotEmpty) {
        // [MODE LOKAL/DEVELOPMENT] Panggil API Gemini langsung jika ada kunci di .env
        final response = await http.post(
          Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$directApiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "systemInstruction": {
              "parts": [{ 
                "text": "Anda adalah Asisten Cerdas untuk sistem 'Smart Address Desa Manisharjo'. Tugas Anda adalah menjawab pertanyaan warga atau kurir terkait desa, layanan, atau data rumah. Jawablah dengan ramah, profesional, ringkas, dan menggunakan bahasa Indonesia yang baik. Jangan memberikan jawaban yang membingungkan atau terlalu panjang." 
              }]
            },
            "contents": [{
              "parts": [{"text": message}]
            }]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          replyText = data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          replyText = 'Maaf, terjadi kesalahan API Lokal: ${response.statusCode}';
        }
      } else {
        // [MODE PRODUKSI/VERCEL] Panggil jalur rahasia Vercel (/api/chat)
        final response = await http.post(
          Uri.parse('/api/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'message': message}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          replyText = data['reply'] ?? 'Maaf, balasan kosong.';
        } else {
          final data = jsonDecode(response.body);
          replyText = 'Maaf, terjadi kesalahan Server: ${data['error'] ?? response.statusCode}';
        }
      }

      if (mounted) {
        setState(() {
          _messages.removeLast(); // Hapus pesan "Mengetik..."
          _messages.add(ChatMessage(text: replyText, isUser: false));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.removeLast(); // Hapus pesan "Mengetik..."
          _messages.add(ChatMessage(text: 'Maaf, sepertinya jaringan bermasalah. Coba lagi nanti. ($e)', isUser: false));
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  child: Icon(Icons.smart_toy, color: theme.colorScheme.primary),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Asisten Desa AI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Online', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.green.shade700)),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5),
        ),
        child: Column(
          children: [
            // Area pesan
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message.isUser;
                  
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isUser 
                            ? theme.colorScheme.primary 
                            : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: isUser 
                              ? Colors.white 
                              : (isDark ? Colors.white : Colors.black87),
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Area ketik pesan
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan ke Asisten AI...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
