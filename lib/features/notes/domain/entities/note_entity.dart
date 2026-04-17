class NoteEntity {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String userId;

  NoteEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.modifiedAt,
    required this.userId,
  });

  NoteEntity copyWith({
    String? title,
    String? description,
    DateTime? modifiedAt,
  }) {
    return NoteEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      userId: userId,
    );
  }
}