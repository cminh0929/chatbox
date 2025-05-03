import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'chat_detail_screen.dart';

class ConversationListScreen extends StatefulWidget {
  @override
  _ConversationListScreenState createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  List<int> _conversationIds = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final ids = await DatabaseHelper.instance.getConversationIds();
    setState(() {
      _conversationIds = ids;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lịch sử trò chuyện')),
      body: ListView.builder(
        itemCount: _conversationIds.length,
        itemBuilder: (context, index) {
          final convId = _conversationIds[index];
          return ListTile(
            title: Text('Cuộc trò chuyện #$convId'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(conversationId: convId),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
