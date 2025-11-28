import 'package:flutter/material.dart';

import 'chat_screen.dart';
import '../models/chat_repository.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  @override
  void initState() {
    super.initState();
    ChatRepository.instance.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    ChatRepository.instance.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() => setState(() {});

  String _formatTs(dynamic ts) {
    if (ts is DateTime) {
      final now = DateTime.now();
      final diff = now.difference(ts);
      if (diff.inSeconds < 60) return 'Now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      return '${ts.month}/${ts.day}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    // Build conversation summaries using the repository and sort by last message
    final convNames = ChatRepository.instance.getConversationNames();
    final summaries = convNames.map((name) {
      final last = ChatRepository.instance.getLastMessage(name);
      final ts = last != null && last['timestamp'] is DateTime
          ? last['timestamp'] as DateTime
          : DateTime.fromMillisecondsSinceEpoch(0);
      final text = last != null ? (last['text'] as String? ?? '') : '';
      final avatar =
          'https://picsum.photos/seed/${name.hashCode % 1000}/200/200';
      return {'name': name, 'lastText': text, 'ts': ts, 'avatar': avatar};
    }).toList();

    summaries
        .sort((a, b) => (b['ts'] as DateTime).compareTo(a['ts'] as DateTime));

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
          children: const [
            Text('ta_junhyuk', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(width: 6),
            Icon(Icons.arrow_drop_down),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Search bar
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.centerLeft,
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.black54),
                SizedBox(width: 8),
                Text('Search', style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Note / pinned bubble
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipOval(
                      child: Image.network(
                          'https://picsum.photos/seed/note/120/120',
                          fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Your note',
                      style: TextStyle(color: Colors.black54, fontSize: 12)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Messages header with Requests
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text('Messages',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  SizedBox(width: 6),
                  Icon(Icons.do_not_disturb_on,
                      size: 18, color: Colors.black54),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Requests (1)',
                    style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Messages list (from repository, sorted by last message timestamp)
          ...summaries.map((m) {
            final name = m['name'] as String;
            final subtitle = m['lastText'] as String;
            final avatar = m['avatar'] as String;
            final ts = m['ts'];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(avatar),
              ),
              title: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle:
                  Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Text(_formatTs(ts),
                  style: const TextStyle(color: Colors.black54, fontSize: 12)),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ChatScreen(name: name, avatarUrl: avatar),
                ));
              },
            );
          }).toList(),

          const SizedBox(height: 18),

          // Find friends section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Find friends to follow and message',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),

          _buildFollowRow(
            icon: Icons.contact_page_outlined,
            title: 'Connect contacts',
            subtitle: 'Follow people you know.',
            buttonLabel: 'Connect',
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          _buildFollowRow(
            icon: Icons.search,
            title: 'Search for friends',
            subtitle: "Find your friends' accounts.",
            buttonLabel: 'Search',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildFollowRow(
      {required IconData icon,
      required String title,
      required String subtitle,
      required String buttonLabel,
      required VoidCallback onPressed}) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.grey.shade100),
          child: Icon(icon, color: Colors.black54),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 13)),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          child: Text(buttonLabel),
        ),
        const SizedBox(width: 8),
        IconButton(
            icon: const Icon(Icons.close, color: Colors.black26),
            onPressed: () {}),
      ],
    );
  }
}
