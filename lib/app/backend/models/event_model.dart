class EventCategoryModel {
  int? id;
  String? name;
  String? slug;

  EventCategoryModel({this.id, this.name, this.slug});

  EventCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name']?.toString();
    slug = json['slug']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'slug': slug};
  }
}

class VenueModel {
  int? id;
  String? venue;
  String? address;
  String? city;
  String? country;
  String? url;

  VenueModel({this.id, this.venue, this.address, this.city, this.country, this.url});

  VenueModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    venue = json['venue']?.toString();
    address = json['address']?.toString();
    city = json['city']?.toString();
    country = json['country']?.toString();
    url = json['url']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'venue': venue, 'address': address,
      'city': city, 'country': country, 'url': url,
    };
  }

  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }
}

class EventModel {
  int? id;
  String? title;
  String? description;
  String? excerpt;
  String? image;
  String? startDate;
  String? endDate;
  bool allDay = false;
  String? url;
  VenueModel? venue;
  List<EventCategoryModel> categories = [];
  String? cost;
  String? status;

  EventModel({
    this.id, this.title, this.description, this.excerpt, this.image,
    this.startDate, this.endDate, this.allDay = false, this.url,
    this.venue, this.cost, this.status,
  });

  EventModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title']?.toString();
    description = json['description']?.toString();
    excerpt = json['excerpt']?.toString();
    startDate = json['start_date']?.toString();
    endDate = json['end_date']?.toString();
    allDay = json['all_day'] == true;
    url = json['url']?.toString();
    cost = json['cost']?.toString();
    status = json['status']?.toString();

    if (json['image'] != null) {
      if (json['image'] is Map) {
        image = json['image']['url']?.toString();
      } else {
        image = json['image']?.toString();
      }
    }

    if (json['venue'] != null && json['venue'] is Map) {
      venue = VenueModel.fromJson(json['venue']);
    }

    if (json['categories'] != null && json['categories'] is List) {
      categories = (json['categories'] as List)
          .map((e) => EventCategoryModel.fromJson(e))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 'title': title, 'description': description,
      'excerpt': excerpt, 'image': image, 'start_date': startDate,
      'end_date': endDate, 'all_day': allDay, 'url': url,
      'venue': venue?.toJson(), 'cost': cost, 'status': status,
      'categories': categories.map((e) => e.toJson()).toList(),
    };
  }

  String get formattedDate {
    if (startDate == null) return '';
    try {
      final dt = DateTime.parse(startDate!);
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return startDate ?? '';
    }
  }

  String get formattedTime {
    if (startDate == null) return '';
    try {
      final dt = DateTime.parse(startDate!);
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${hour == 0 ? 12 : hour}:${dt.minute.toString().padLeft(2, '0')} $amPm';
    } catch (_) {
      return '';
    }
  }

  String get formattedTimeRange {
    final start = formattedTime;
    if (endDate == null) return start;
    try {
      final dt = DateTime.parse(endDate!);
      final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final end = '${hour == 0 ? 12 : hour}:${dt.minute.toString().padLeft(2, '0')} $amPm';
      return '$start - $end';
    } catch (_) {
      return start;
    }
  }
}
