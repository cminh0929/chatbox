import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/chat_message.dart';

class ChatDetailScreen extends StatefulWidget {
  final int conversationId;

  ChatDetailScreen({required this.conversationId});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final messages = await DatabaseHelper.instance.getMessagesByConversationId(widget.conversationId);
    setState(() {
      _messages = messages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cuộc trò chuyện #${widget.conversationId}')),
      body: ListView.builder(
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
    );
  }
}
