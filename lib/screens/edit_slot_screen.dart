import 'package:flutter/material.dart';
import '../models/timetable_slot.dart';

class EditSlotScreen extends StatefulWidget {
  final TimetableSlot slot;

  const EditSlotScreen({Key? key, required this.slot}) : super(key: key);

  @override
  _EditSlotScreenState createState() => _EditSlotScreenState();
}

class _EditSlotScreenState extends State<EditSlotScreen> {
  final _formKey = GlobalKey<FormState>();
  late String subject;
  late String teacher;
  late String room;

  @override
  void initState() {
    super.initState();
    subject = widget.slot.subject;
    teacher = widget.slot.teacher;
    room = widget.slot.room;
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final updatedSlot = TimetableSlot(
        id: widget.slot.id,
        subject: subject,
        teacher: teacher,
        room: room,
        day: widget.slot.day,
        timeSlot: widget.slot.timeSlot,
      );
      Navigator.pop(context, updatedSlot);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Slot')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: subject,
                decoration: const InputDecoration(labelText: 'Subject'),
                onChanged: (val) => subject = val,
                validator: (val) => val!.isEmpty ? 'Enter subject' : null,
              ),
              TextFormField(
                initialValue: teacher,
                decoration: const InputDecoration(labelText: 'Teacher'),
                onChanged: (val) => teacher = val,
                validator: (val) => val!.isEmpty ? 'Enter teacher' : null,
              ),
              TextFormField(
                initialValue: room,
                decoration: const InputDecoration(labelText: 'Room'),
                onChanged: (val) => room = val,
                validator: (val) => val!.isEmpty ? 'Enter room' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
