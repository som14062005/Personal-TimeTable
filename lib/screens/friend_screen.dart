import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import '/models/friend_model.dart';
import '/fullscreen_image_viewer.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  final Box<FriendModel> friendsBox = Hive.box<FriendModel>('friendsBox');

  void _addOrEditFriend({FriendModel? friend, int? index}) async {
    final nameController = TextEditingController(text: friend?.name ?? '');
    File? imageFile = friend != null ? File(friend.imagePath) : null;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(friend == null ? 'Add Friend' : 'Edit Friend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: const Text('Pick Timetable Image'),
              onPressed: () async {
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() {
                    imageFile = File(picked.path);
                  });
                }
              },
            ),
            if (imageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Image.file(imageFile!, height: 100),
              ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: Text(friend == null ? 'Add' : 'Update'),
            onPressed: () async {
              if (nameController.text.isEmpty || imageFile == null) return;

              final newFriend = FriendModel(
                name: nameController.text,
                imagePath: imageFile!.path,
              );

              if (friend == null) {
                await friendsBox.add(newFriend);
              } else {
                await friendsBox.putAt(index!, newFriend);
              }

              Navigator.of(ctx).pop();
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  void _deleteFriend(int index) async {
    await friendsBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final friends = friendsBox.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditFriend(),
          )
        ],
      ),
      body: friends.isEmpty
          ? const Center(child: Text('No friends added yet'))
          : ListView.builder(
              itemCount: friends.length,
              itemBuilder: (ctx, index) {
                final friend = friends[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: FileImage(File(friend.imagePath)),
                    ),
                    title: Text(friend.name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenImageViewer(
                            imagePath: friend.imagePath,
                            title: friend.name,
                          ),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _addOrEditFriend(friend: friend, index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteFriend(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
