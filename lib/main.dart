import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'database/database_helper.dart';
import 'models/chat_message.dart';
import 'screens/conversation_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatGPT Flutter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];
  late String apiKey;
  late int currentConversationId;

  @override
  void initState() {
    super.initState();
    apiKey = dotenv.env['API_OPENAI_KEY'] ?? '';
    if (apiKey.isEmpty) {
      print('ERROR: API Key is missing. Check your .env file.');
    }
    currentConversationId = DateTime.now().millisecondsSinceEpoch;
  }

  Future<String> sendMessage(String message) async {
    if (apiKey.isEmpty) {
      return 'Error: API Key is missing.';
    }

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': message},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedBody);
      return data['choices'][0]['message']['content'].trim();
    } else {
      print('API Error: ${response.body}');
      return 'Lỗi: Không nhận được phản hồi từ API.';
    }
  }

  void _sendMessage() async {
    final String userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    final now = DateTime.now().toIso8601String();

    setState(() {
      _messages.add(ChatMessage(
        conversationId: currentConversationId,
        sender: 'user',
        content: userMessage,
        timestamp: now,
      ));
    });

    _controller.clear();

    await DatabaseHelper.instance.insertMessage(ChatMessage(
      conversationId: currentConversationId,
      sender: 'user',
      content: userMessage,
      timestamp: now,
    ));

    try {
      String botResponse = await sendMessage(userMessage);

      final botNow = DateTime.now().toIso8601String();

      setState(() {
        _messages.add(ChatMessage(
          conversationId: currentConversationId,
          sender: 'bot',
          content: botResponse,
          timestamp: botNow,
        ));
      });

      await DatabaseHelper.instance.insertMessage(ChatMessage(
        conversationId: currentConversationId,
        sender: 'bot',
        content: botResponse,
        timestamp: botNow,
      ));
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          conversationId: currentConversationId,
          sender: 'bot',
          content: 'Lỗi: ${e.toString()}',
          timestamp: DateTime.now().toIso8601String(),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatBML'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ConversationListScreen()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.sender == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(msg.content),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
