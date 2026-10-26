class CategoryModel {
  final String slug;
  final String name;
  final String url;

  const CategoryModel({
    required this.slug,
    required this.name,
    required this.url,
  });

  factory CategoryModel.fromJson(dynamic json) {
    if (json is String) {
      final formattedName = json.isNotEmpty
          ? json[0].toUpperCase() + json.substring(1).replaceAll('-', ' ')
          : json;
      return CategoryModel(slug: json, name: formattedName, url: '');
    }
    final map = json as Map<String, dynamic>;
    return CategoryModel(
      slug: map['slug'] as String? ?? '',
      name: map['name'] as String? ?? '',
      url: map['url'] as String? ?? '',
    );
  }
}
