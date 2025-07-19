// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_slot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimetableSlotAdapter extends TypeAdapter<TimetableSlot> {
  @override
  final int typeId = 0;

  @override
  TimetableSlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimetableSlot(
      id: fields[0] as String,
      subject: fields[1] as String,
      teacher: fields[2] as String,
      room: fields[3] as String,
      day: fields[4] as String,
      timeSlot: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TimetableSlot obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.teacher)
      ..writeByte(3)
      ..write(obj.room)
      ..writeByte(4)
      ..write(obj.day)
      ..writeByte(5)
      ..write(obj.timeSlot);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableSlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
