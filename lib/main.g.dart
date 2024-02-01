// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SequencerGridAdapter extends TypeAdapter<SequencerGrid> {
  @override
  final int typeId = 0;

  @override
  SequencerGrid read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SequencerGrid(
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SequencerGrid obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.gridString);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SequencerGridAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
