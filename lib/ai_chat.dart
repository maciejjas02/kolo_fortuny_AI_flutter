import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class AiChatPanel extends StatefulWidget {
  final String? lastResult;
  
  const AiChatPanel({super.key, this.lastResult});

  @override
  State<AiChatPanel> createState() => _AiChatPanelState();
}

class _AiChatPanelState extends State<AiChatPanel> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  
  // Klucz API zakodowany (XOR + Base64)
  String get _getApiKey {
    // Zakodowany klucz - dekodowanie w runtime
    const encoded = 'ZmRoXjdFalAxM1RCR0luUVBBeTE4dldJRmJ2YjJGWFFyR0l6S0RFb1FUUExRSmVxdDNnRWQ3Nw==';
    const xorKey = 42; // Klucz XOR
    
    try {
      final decoded = utf8.decode(base64.decode(encoded));
      final result = String.fromCharCodes(
        decoded.codeUnits.map((c) => c ^ xorKey)
      );
      return result;
    } catch (e) {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    
    if (widget.lastResult != null) {
      _addMessage(
        'Witaj! Widzę, że koło zatrzymało się na opcji "${widget.lastResult}". '
        'Mogę odpowiedzieć na pytania o wynik lub porozmawiać o czymkolwiek! 😊',
        isUser: false,
      );
    } else {
      _addMessage(
        'Cześć! Jestem AI chatbotem koła fortuny. Zakręć kołem, a potem możemy porozmawiać o wyniku! 🎡',
        isUser: false,
      );
    }
  }

  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });
    
    // Scroll do końca
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addMessage(message, isUser: true);
    _messageController.clear();

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _getAiResponse(message);
      _addMessage(response, isUser: false);
    } catch (e) {
      _addMessage(
        'Przepraszam, wystąpił błąd: $e\n\nSpróbuj ponownie! 😅',
        isUser: false,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getAiResponse(String userMessage) async {
    // Używamy Groq API - super szybki!
    const apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
    final apiKey = _getApiKey;
    
    // Budujemy kontekst z historią
    final messages = [
      {
        'role': 'system',
        'content': 'Jesteś asystentem AI w aplikacji "Koło Fortuny". Twoim zadaniem jest mówić ciekawostki o opcji która się wylosowała. np. jeśli wylosowano "Samochód", opowiadasz o samochodach, ich historii, ciekawostkach itp. '
            'Użytkownik kręci kołem i losuje opcje. Pomagasz mu w rozmowie o wynikach, '
            'jesteś pozytywny, pomocny i wspierający. Odpowiadaj po polsku (chyba, że uzytkownik zechce inaczej). '
            '${widget.lastResult != null ? 'Ostatni wynik użytkownika to: "${widget.lastResult}"' : ''}'
      },
      // Dodaj historię konwersacji (ostatnie 5 wiadomości)
      ..._messages.take(_messages.length > 10 ? 10 : _messages.length).map((msg) => {
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      }),
      {
        'role': 'user',
        'content': userMessage,
      }
    ];
    
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content != null && content.isNotEmpty) {
          return content;
        }
      } else {
        print('Groq API error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Groq API exception: $e');
      return _getSimpleResponse(userMessage);
    }
    
    return _getSimpleResponse(userMessage);
  }

  String _getSimpleResponse(String message) {
    final lower = message.toLowerCase();
    
    if (widget.lastResult != null) {
      if (lower.contains('wynik') || lower.contains('wygrałem') || lower.contains('przegrałem')) {
        return 'Twój wynik to "${widget.lastResult}". Czy chcesz spróbować jeszcze raz? 🎲';
      }
      if (lower.contains('szczęście') || lower.contains('los')) {
        return 'Wylosowałeś opcję "${widget.lastResult}". To czysty przypadek! Może następnym razem będzie inna opcja? 🍀';
      }
    }
    
    if (lower.contains('cześć') || lower.contains('hej') || lower.contains('witaj')) {
      return 'Cześć! Miło Cię poznać! Jak mogę Ci pomóc? 👋';
    }
    if (lower.contains('jak się masz') || lower.contains('co słychać')) {
      return 'Świetnie! Kręcę się jak to koło fortuny! 😄 A u Ciebie?';
    }
    if (lower.contains('dziękuję') || lower.contains('dzięki')) {
      return 'Nie ma za co! Zawsze do usług! 😊';
    }
    if (lower.contains('pomoc') || lower.contains('co potrafisz')) {
      return 'Mogę rozmawiać o wynikach z koła fortuny, odpowiadać na pytania i po prostu pogadać! Spróbuj zakręcić kołem i zobaczmy co wypadnie! 🎡';
    }
    if (lower.contains('koło') || lower.contains('zakręć')) {
      return 'Zamknij czat i kliknij przycisk START, żeby zakręcić kołem! Potem wróć i porozmawiamy o wyniku! 🎯';
    }
    
    final responses = [
      'To interesujące! Powiedz mi więcej! 🤔',
      'Rozumiem! Co jeszcze chciałbyś wiedzieć? 💭',
      'Świetna obserwacja! Masz jeszcze jakieś pytania? 🌟',
      'Zgadzam się! Chcesz spróbować szczęścia z kołem? 🎲',
      'To dobry punkt! Co teraz? 🎯',
    ];
    
    return responses[message.length % responses.length];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade900.withOpacity(0.95),
            Colors.blue.shade900.withOpacity(0.95),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'AI Chatbot',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ChatBubble(
                  text: message.text,
                  isUser: message.isUser,
                );
              },
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI pisze...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          
          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Napisz wiadomość...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, size: 20, color: Colors.white),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Colors.blue, Colors.purple],
                      )
                    : null,
                color: isUser ? null : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
