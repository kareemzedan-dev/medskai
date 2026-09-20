class BlogPostModel {
  int? id;
  String? title;
  String? excerpt;
  String? content;
  String? date;
  String? link;
  String? slug;
  String? imageUrl;
  String? categoryName;
  String? authorName;
  String? authorAvatar;
  List<String> tags = [];

  BlogPostModel({
    this.id,
    this.title,
    this.excerpt,
    this.date,
    this.link,
    this.slug,
    this.imageUrl,
    this.categoryName,
    this.content,
    this.authorName,
  });

  BlogPostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    // title comes as {rendered: "..."}
    if (json['title'] is Map) {
      title = _stripHtml(json['title']['rendered'] ?? '');
    } else {
      title = json['title']?.toString();
    }

    // excerpt comes as {rendered: "..."}
    if (json['excerpt'] is Map) {
      excerpt = _stripHtml(json['excerpt']['rendered'] ?? '');
    } else {
      excerpt = json['excerpt']?.toString();
    }

    // content comes as {rendered: "..."}
    if (json['content'] is Map) {
      content = json['content']['rendered']?.toString();
    } else {
      content = json['content']?.toString();
    }

    date = json['date']?.toString();
    link = json['link']?.toString();
    slug = json['slug']?.toString();

    // Extract featured image from _embedded
    if (json['_embedded'] != null && json['_embedded']['wp:featuredmedia'] != null) {
      final media = json['_embedded']['wp:featuredmedia'];
      if (media is List && media.isNotEmpty) {
        imageUrl = media[0]['source_url']?.toString();
      }
    }

    // Extract author from _embedded
    if (json['_embedded'] != null && json['_embedded']['author'] != null) {
      final authors = json['_embedded']['author'];
      if (authors is List && authors.isNotEmpty) {
        authorName = authors[0]['name']?.toString();
        // Get avatar (96px)
        if (authors[0]['avatar_urls'] != null) {
          authorAvatar = authors[0]['avatar_urls']['96']?.toString();
        }
      }
    }

    // Extract terms from _embedded
    if (json['_embedded'] != null && json['_embedded']['wp:term'] != null) {
      final termGroups = json['_embedded']['wp:term'];
      if (termGroups is List) {
        for (final group in termGroups) {
          if (group is List) {
            for (final term in group) {
              final taxonomy = term['taxonomy']?.toString();
              final name = term['name']?.toString();
              if (taxonomy == 'category' && name != null && categoryName == null) {
                categoryName = name;
              } else if (taxonomy == 'post_tag' && name != null) {
                tags.add(name);
              }
            }
          }
        }
      }
    }
  }

  /// Format date from "2022-09-20T04:11:51" to "September 20, 2022"
  String get formattedDate {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date!);
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return date ?? '';
    }
  }

  /// Strip HTML tags and decode entities
  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&#038;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#8230;', '...')
        .replaceAll('\n', '')
        .trim();
  }
}
