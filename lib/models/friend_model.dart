// models/friend_model.dart
import 'package:hive/hive.dart';

part 'friend_model.g.dart';

@HiveType(typeId: 1)
class FriendModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String imagePath; // local path to stored image

  FriendModel({required this.name, required this.imagePath});
}
