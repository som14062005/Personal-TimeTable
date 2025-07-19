import 'package:flutter/material.dart';

class SlotBox extends StatelessWidget {
  final String subject;
  final String teacher;
  final String room;
  final VoidCallback onEdit; // <- Accepts zero-arg function

  const SlotBox({
    super.key,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        width: 120,
        height: 80,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.deepPurple[50],
          border: Border.all(color: Colors.deepPurple),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(teacher),
            Text(room),
          ],
        ),
      ),
    );
  }
}
