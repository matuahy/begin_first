class Intent {
  const Intent({
    required this.id,
    required this.title,
    this.nextStep,
    this.tags = const [],
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? nextStep;
  final List<String> tags;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Intent copyWith({
    String? id,
    String? title,
    String? nextStep,
    List<String>? tags,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Intent(
      id: id ?? this.id,
      title: title ?? this.title,
      nextStep: nextStep ?? this.nextStep,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
