class CategoryCreateDTO {
  final String name;
  final String description;

  CategoryCreateDTO({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };
}
