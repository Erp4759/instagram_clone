import 'package:flutter/foundation.dart';

class ChatRepository extends ChangeNotifier {
  ChatRepository._internal();
  static final ChatRepository instance = ChatRepository._internal();

  // In-memory store keyed by conversation name. Values are lists of message maps
  // with keys: 'text' (String), 'sent' (bool), 'timestamp' (DateTime),
  // and optional 'read' (bool).
  final Map<String, List<Map<String, dynamic>>> _store = {};

  List<Map<String, dynamic>> getMessages(String name) {
    return _store.putIfAbsent(name, () {
      final now = DateTime.now();
      return [
        {
          'text': 'Hi!',
          'sent': true,
          'timestamp': now.subtract(const Duration(minutes: 5)),
          'read': true,
        },
        {
          'text': 'Nice to meet you!',
          'sent': true,
          'timestamp': now.subtract(const Duration(minutes: 4)),
          'read': true,
        },
        {
          'text': 'Hello — nice to meet you too.',
          'sent': false,
          'timestamp': now.subtract(const Duration(minutes: 3)),
        },
      ];
    });
  }

  void addMessage(String name, Map<String, dynamic> message) {
    getMessages(name).add(message);
    notifyListeners();
  }

  void clearConversation(String name) => _store.remove(name);

  /// Return a list of known conversation names
  List<String> getConversationNames() {
    // If no conversations exist yet, seed a few demo conversations so the
    // Messages screen has something to display during development.
    if (_store.isEmpty) {
      final seeds = ['ta_junhyuk', 'friend1', 'friend2', 'aespa_official'];
      for (final s in seeds) {
        getMessages(s);
      }
    }
    return _store.keys.toList();
  }

  /// Return the last message map for the conversation, or null
  Map<String, dynamic>? getLastMessage(String name) {
    final msgs = _store[name];
    if (msgs == null || msgs.isEmpty) return null;
    return msgs.last as Map<String, dynamic>?;
  }
}
