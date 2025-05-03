class ChatMessage {
  final int? id;
  final int conversationId;
  final String sender; // 'user' hoặc 'bot'
  final String content;
  final String timestamp;

  ChatMessage({
    this.id,
    required this.conversationId,
    required this.sender,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender': sender,
      'content': content,
      'timestamp': timestamp,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      conversationId: map['conversation_id'],
      sender: map['sender'],
      content: map['content'],
      timestamp: map['timestamp'],
    );
  }
}
