import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../database/database_helper.dart';
import '../services/openai_service.dart';
import '../widgets/message_bubble.dart';
import 'conversation_list_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ChatMessage> _messages = [];
  late int currentConversationId;

  @override
  void initState() {
    super.initState();
    currentConversationId = DateTime.now().millisecondsSinceEpoch;
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
      final botReply = await OpenAIService.sendMessage(userMessage);
      final botNow = DateTime.now().toIso8601String();

      setState(() {
        _messages.add(ChatMessage(
          conversationId: currentConversationId,
          sender: 'bot',
          content: botReply,
          timestamp: botNow,
        ));
      });

      await DatabaseHelper.instance.insertMessage(ChatMessage(
        conversationId: currentConversationId,
        sender: 'bot',
        content: botReply,
        timestamp: botNow,
      ));
    } catch (e) {
      print('Lỗi gửi tin nhắn: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatGPT'),
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
                return MessageBubble(
                  text: msg.content,
                  isUser: msg.sender == 'user',
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Nhập tin nhắn...'),
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
