class JobModel {
  int? id;
  String? title;
  String? content;
  String? companyName;
  String? location;
  String? jobType;
  String? date;
  String? link;

  JobModel({
    this.id, this.title, this.content, this.companyName,
    this.location, this.jobType, this.date, this.link,
  });

  JobModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? '');

    if (json['title'] is Map) {
      title = json['title']['rendered']?.toString();
    } else {
      title = json['title']?.toString();
    }
    // Clean HTML entities from title
    title = title
        ?.replaceAll('&amp;', '&')
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8217;', "'");

    if (json['content'] is Map) {
      content = json['content']['rendered']?.toString();
    } else {
      content = json['content']?.toString();
    }

    date = json['date']?.toString();
    link = json['link']?.toString() ?? json['guid']?.toString();

    // Try multiple meta field patterns used by WP Job Manager
    final meta = json['meta'] is Map ? json['meta'] as Map : null;
    final jobMeta = json['job_listing_meta'] is Map ? json['job_listing_meta'] as Map : null;
    final source = meta ?? jobMeta;

    if (source != null) {
      companyName = source['_company_name']?.toString()
          ?? source['_job_listing_company_name']?.toString();
      location = source['_job_location']?.toString()
          ?? source['_job_listing_location']?.toString()
          ?? source['geolocation_formatted_address']?.toString();
      jobType = source['_job_type']?.toString()
          ?? source['_job_listing_job_type']?.toString();
    }

    // Fallback: some themes put these at top level
    companyName ??= json['company_name']?.toString();
    location ??= json['location']?.toString() ?? json['job_location']?.toString();
    jobType ??= json['job_type']?.toString() ?? json['type']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'title': title, 'content': content,
      'company_name': companyName, 'location': location,
      'job_type': jobType, 'date': date, 'link': link,
    };
  }

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

  String get plainTextExcerpt {
    if (content == null || content!.isEmpty) return '';
    // Strip HTML tags using regex
    String stripped = content!.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
    // Replace multiple spaces with a single space
    stripped = stripped.replaceAll(RegExp(r'\s+'), ' ');
    if (stripped.length > 120) {
      return '${stripped.substring(0, 120)}...';
    }
    return stripped;
  }
}
