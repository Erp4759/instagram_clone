import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../models/chat_repository.dart';

class ChatScreen extends StatefulWidget {
  final String name;
  final String avatarUrl;

  const ChatScreen({super.key, required this.name, required this.avatarUrl});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> _messages;

  final Random _rnd = Random();
  bool _isTyping = false;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load or create conversation for this user
    _messages = ChatRepository.instance.getMessages(widget.name);
    // Ensure view scrolls to bottom after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  String _formatTimestamp(DateTime ts) {
    final now = DateTime.now();
    final diff = now.difference(ts);
    if (diff.inSeconds < 60) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    // fallback: simple date
    return '${ts.month}/${ts.day} ${ts.hour % 12 == 0 ? 12 : ts.hour % 12}:${ts.minute.toString().padLeft(2, '0')}${ts.hour >= 12 ? ' PM' : ' AM'}';
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    // If an image is selected, send the image instead of text
    final isImage = _selectedImageBytes != null;
    if (!isImage && text.isEmpty) return;

    final sentMsg = <String, dynamic>{
      'sent': true,
      'timestamp': DateTime.now(),
      'read': false,
    };
    if (isImage) {
      sentMsg['imageBytes'] = _selectedImageBytes;
      sentMsg['imageName'] = _selectedImageName ?? 'image';
    } else {
      sentMsg['text'] = text;
    }
    // Persist via repository. `_messages` references the same list instance
    // returned by the repository, so adding only once prevents duplicates.
    ChatRepository.instance.addMessage(widget.name, sentMsg);
    setState(() {
      _controller.clear();
      // clear preview if image was sent
      if (isImage) {
        _selectedImageBytes = null;
        _selectedImageName = null;
      }
      // indicate the other side is typing while we prepare a reply
      _isTyping = true;
    });
    _scrollToBottom();

    // Simple auto-reply rules (local/demo only):
    // - If message contains both "how" and "are" -> reply "I am good"
    // - Else if message contains the word "hi" -> reply "hello"
    // - Else if message contains the word "hello" -> reply "hi"
    // Replies are case-insensitive and match full words.
    // If an image was sent, pick one of 5 two-sentence image replies at random.
    String reply;
    if (isImage) {
      final replies = [
        'Wow, this looks great! The colors are amazing and really pop.',
        'Nice shot! The composition is on point and very pleasing to look at.',
        'Lovely picture — it tells a story and I love the mood.',
        'This is stunning! The detail is fantastic and very crisp.',
        'So cool! The lighting and angle make this really stand out.'
      ];
      reply = replies[_rnd.nextInt(replies.length)];
    } else {
      final lower = text.toLowerCase();
      final hasHow = RegExp(r"\bhow\b").hasMatch(lower);
      final hasAre = RegExp(r"\bare\b").hasMatch(lower);
      final hasHi = RegExp(r"\bhi\b").hasMatch(lower);
      final hasHello = RegExp(r"\bhello\b").hasMatch(lower);
      final hasThank = RegExp(r"\bthank|thanks\b").hasMatch(lower);
      final hasBye = RegExp(r"\bbye|goodbye\b").hasMatch(lower);
      final hasWhat = RegExp(r"\bwhat\b").hasMatch(lower);
      final hasGood = RegExp(r"\bgood|great|awesome\b").hasMatch(lower);

      if (hasHow && hasAre) {
        reply = 'I am good';
      } else if (hasHi) {
        reply = 'hello';
      } else if (hasHello) {
        reply = 'hi';
      } else if (hasThank) {
        reply = 'You are welcome!';
      } else if (hasBye) {
        reply = 'See you!';
      } else if (hasWhat) {
        reply = 'What do you mean?';
      } else if (hasGood) {
        reply = 'Amazing!';
      } else {
        // default random responses when nothing matched
        final defaults = ['Oh I agree with you', 'Amazing!', 'For real'];
        reply = defaults[_rnd.nextInt(defaults.length)];
      }
    }

    // simulate typing time based on message length (longer messages -> longer typing)
    int typingMs = text.length * 120; // ~120ms per char
    if (typingMs < 800) typingMs = 800;
    if (typingMs > 2500) typingMs = 2500;

    // simulate a short delay like a real reply
    Future.delayed(Duration(milliseconds: typingMs), () {
      final replyMsg = {
        'text': reply,
        'sent': false,
        'timestamp': DateTime.now(),
      };
      // Persist via repository (which _messages references)
      ChatRepository.instance.addMessage(widget.name, replyMsg);

      // mark the most recent sent message(s) as read
      for (var i = _messages.length - 1; i >= 0; i--) {
        final m = _messages[i];
        if (m['sent'] == true && (m['read'] == null || m['read'] == false)) {
          m['read'] = true;
          break; // mark only the last unread sent message
        }
      }

      setState(() {
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _pickImage() async {
    try {
      final xfile = await _picker.pickImage(source: ImageSource.gallery);
      if (xfile == null) return;
      final bytes = await xfile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = xfile.name;
      });
      // scroll so preview is visible
      _scrollToBottom();
    } catch (e) {
      // ignore errors in demo
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.avatarUrl),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(widget.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.videocam_outlined), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                controller: _scrollController,
                itemCount: _messages.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Optional center timestamp or profile button area
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Sep 12, 12:20 AM',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 12)),
                        ),
                      ),
                    );
                  }

                  final msg = _messages[index - 1];
                  final sent = msg['sent'] as bool;
                  final hasImage = msg.containsKey('imageBytes') &&
                      msg['imageBytes'] != null;
                  final text = !hasImage && msg['text'] != null
                      ? (msg['text'] as String)
                      : '';

                  final bubble = ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.72),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: sent ? Colors.purple : Colors.grey.shade200,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(sent ? 16 : 4),
                          bottomRight: Radius.circular(sent ? 4 : 16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasImage) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                  msg['imageBytes'] as Uint8List,
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 8),
                          ] else ...[
                            Text(text,
                                style: TextStyle(
                                    color:
                                        sent ? Colors.white : Colors.black87)),
                            const SizedBox(height: 6),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Builder(builder: (context) {
                                final ts = msg['timestamp'] is DateTime
                                    ? msg['timestamp'] as DateTime
                                    : DateTime.now();
                                return Text(_formatTimestamp(ts),
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: sent
                                            ? Colors.white70
                                            : Colors.black54));
                              }),
                              if (sent && (msg['read'] == true)) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.done_all,
                                    size: 12, color: Colors.lightBlueAccent)
                              ]
                            ],
                          )
                        ],
                      ),
                    ),
                  );

                  return Row(
                    mainAxisAlignment:
                        sent ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!sent)
                        CircleAvatar(
                            radius: 14,
                            backgroundImage: NetworkImage(widget.avatarUrl)),
                      if (!sent) const SizedBox(width: 8),
                      bubble,
                      if (sent) const SizedBox(width: 8),
                      if (sent)
                        CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(
                                'https://picsum.photos/seed/me/200/200')),
                    ],
                  );
                },
              ),
            ),

            // Typing indicator (when the other side is 'typing')
            if (_isTyping)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                child: Row(
                  children: [
                    CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(widget.avatarUrl)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('typing...',
                          style: TextStyle(color: Colors.black54)),
                    )
                  ],
                ),
              ),

            // Selected image preview (shows when user picked an image)
            if (_selectedImageBytes != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(_selectedImageBytes!,
                          width: 84, height: 84, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_selectedImageName ?? 'Selected image',
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedImageBytes = null;
                          _selectedImageName = null;
                        });
                      },
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),
              ),

            // Input area
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration.collapsed(
                                  hintText: 'Message...'),
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                          IconButton(
                              icon: const Icon(Icons.mic_none),
                              onPressed: () {}),
                          IconButton(
                              icon: const Icon(Icons.image_outlined),
                              onPressed: _pickImage),
                          IconButton(
                              icon: const Icon(Icons.emoji_emotions_outlined),
                              onPressed: () {}),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    mini: true,
                    backgroundColor: Colors.purple,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
