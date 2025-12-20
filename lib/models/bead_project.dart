import 'package:hive/hive.dart';

class BeadProject {
  final String id;
  final String originalImagePath;
  final int targetSize;
  final DateTime updatedAt;

  BeadProject({
    required this.id,
    required this.originalImagePath,
    required this.targetSize,
    required this.updatedAt,
  });
}

class BeadProjectAdapter extends TypeAdapter<BeadProject> {
  @override
  final int typeId = 0;

  @override
  BeadProject read(BinaryReader reader) {
    return BeadProject(
      id: reader.readString(),
      originalImagePath: reader.readString(),
      targetSize: reader.readInt(),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, BeadProject obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.originalImagePath);
    writer.writeInt(obj.targetSize);
    writer.writeInt(obj.updatedAt.millisecondsSinceEpoch);
  }
}
