import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/profile_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _profile = ProfileRepository.instance;
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _pronounsController;
  late final TextEditingController _bioController;
  late final TextEditingController _musicController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _profile.name);
    _usernameController = TextEditingController(text: _profile.username);
    _pronounsController = TextEditingController(text: _profile.pronouns);
    _bioController = TextEditingController(text: _profile.bio);
    _musicController = TextEditingController(text: _profile.music);
  }

  Future<void> _pickProfileImage() async {
    try {
      final xfile = await _picker.pickImage(source: ImageSource.gallery);
      if (xfile == null) return;
      final bytes = await xfile.readAsBytes();
      _profile.update(avatarBytes: bytes);
      setState(() {});
    } catch (e) {
      // ignore
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _pronounsController.dispose();
    _bioController.dispose();
    _musicController.dispose();
    super.dispose();
  }

  void _saveAndClose() {
    _profile.update(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      pronouns: _pronounsController.text.trim(),
      bio: _bioController.text.trim(),
      music: _musicController.text.trim(),
    );
    Navigator.of(context).pop();
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
            onPressed: () => Navigator.of(context).pop()),
        title: const Text('Edit profile', style: TextStyle(fontSize: 18)),
        actions: [
          TextButton(
            onPressed: _saveAndClose,
            child: const Text('Done'),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundImage: _profile.avatarImage,
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.add, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
              child: TextButton(
            onPressed: _pickProfileImage,
            child: const Text('Change profile picture'),
          )),
          const SizedBox(height: 16),
          _buildLabel('Name'),
          TextField(controller: _nameController),
          const SizedBox(height: 12),
          _buildLabel('Username'),
          TextField(controller: _usernameController),
          const SizedBox(height: 12),
          _buildLabel('Pronouns'),
          TextField(controller: _pronounsController),
          const SizedBox(height: 12),
          _buildLabel('Bio'),
          TextField(controller: _bioController, maxLines: 3),
          const SizedBox(height: 12),
          _buildLabel('Add link'),
          const SizedBox(height: 6),
          const Text('Add link', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          _buildLabel('Add banners'),
          const SizedBox(height: 12),
          _buildLabel('Gender'),
          ListTile(
            title: Text(_profile.gender),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final val = await showModalBottomSheet<String>(
                  context: context,
                  builder: (c) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: const Text('Prefer not to say'),
                          onTap: () => Navigator.of(c).pop('Prefer not to say'),
                        ),
                        ListTile(
                          title: const Text('Male'),
                          onTap: () => Navigator.of(c).pop('Male'),
                        ),
                        ListTile(
                          title: const Text('Female'),
                          onTap: () => Navigator.of(c).pop('Female'),
                        ),
                      ],
                    );
                  });
              if (val != null) {
                _profile.update(gender: val);
                setState(() {});
              }
            },
          ),
          const SizedBox(height: 8),
          _buildLabel('Music'),
          TextField(controller: _musicController),
          const SizedBox(height: 16),
          const Divider(),
          ListTile(
            title: const Text('Switch to professional account'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text('Personal information settings'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text('Show your profile is verified'),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6.0),
        child: Text(text, style: const TextStyle(color: Colors.black54)),
      );
}
