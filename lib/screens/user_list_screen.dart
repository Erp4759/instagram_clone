import 'package:flutter/material.dart';

class UserListScreen extends StatelessWidget {
  final String title;
  final List<String> users;

  const UserListScreen({super.key, required this.title, required this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final u = users[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundImage:
                  NetworkImage('https://picsum.photos/seed/$u/120/120'),
            ),
            title: Text(u, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text(''),
            trailing: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              child:
                  const Text('Message', style: TextStyle(color: Colors.black)),
            ),
          );
        },
      ),
    );
  }
}
