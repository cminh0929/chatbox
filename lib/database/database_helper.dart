import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chat_message.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chat.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id INTEGER,
        sender TEXT,
        content TEXT,
        timestamp TEXT
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion == 1) {
      await db.execute('ALTER TABLE chat_messages ADD COLUMN conversation_id INTEGER DEFAULT 0');
    }
  }

  Future<int> insertMessage(ChatMessage message) async {
    final db = await instance.database;
    return await db.insert('chat_messages', message.toMap());
  }

  Future<List<int>> getConversationIds() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT conversation_id FROM chat_messages ORDER BY conversation_id DESC'
    );
    return result.map((row) => row['conversation_id'] as int).toList();
  }

  Future<List<ChatMessage>> getMessagesByConversationId(int conversationId) async {
    final db = await instance.database;
    final result = await db.query(
      'chat_messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );
    return result.map((json) => ChatMessage.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
