class CategoryUpdateDto {
  final String name;
  final String description;

  CategoryUpdateDto({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };
}
