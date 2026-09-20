class CategoryModel {
  int? id;
  String? name;
  String? slug;
  int? count;

  CategoryModel({
    this.id,
    this.name,
    this.slug,
    this.count,
  });

  CategoryModel.fromJson(Map<String, dynamic> json) {
    if(json['id'] != null){
      id = (json['id'] != null) ? json['id'] : 0;
    }else{
      id = (json['term_id'] != null) ? json['term_id'] : 0;
    }

    name = _decodeHtmlEntities(json['name']?.toString() ?? '');
    slug = json['slug']?.toString();
    count = int.tryParse(json['count']?.toString() ?? '');
  }

  static String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#038;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAllMapped(RegExp(r'&#(\d+);'), (m) => String.fromCharCode(int.parse(m.group(1)!)))
        .replaceAllMapped(RegExp(r'&#x([0-9a-fA-F]+);'), (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;

    return data;
  }

  @override
  String toString() {
    return 'CategoryModel{id: $id, name: $name, slug: $slug}';
  }
}
