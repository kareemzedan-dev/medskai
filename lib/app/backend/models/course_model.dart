import 'dart:convert';

import 'package:flutter_app/app/backend/models/cate-model.dart';
import 'package:flutter_app/app/backend/models/lesson-model.dart';

class CourseModel {
  int? id;
  String? name;
  String? slug;
  String? permalink;
  String? image;
  String? date_created;
  String? date_created_gmt;
  String? status;
  bool? on_sale;
  String? content;
  String? excerpt;
  String? duration = "";
  double? rating = 0;
  double? price;
  String? price_rendered;
  double? origin_price;
  String? origin_price_rendered;
  double? sale_price;
  String? sale_price_rendered;
  List<CategoryModel>? categories = [];
  MetaData? meta_data;
  int count_students = 0;
  int count_items = 0;
  int totalLessons = 0;
  CourseDataModel? course_data;
  bool? can_retake;
  dynamic instructor;

  List<LessonModel>? sections;
  CourseModel({
    this.id,
    this.name,
    this.slug,
    this.permalink,
    this.image,
    this.date_created,
    this.date_created_gmt,
    this.status,
    this.on_sale,
    this.content,
    this.excerpt,
    this.duration,
    this.rating,
    this.price,
    this.price_rendered,
    this.origin_price,
    this.origin_price_rendered,
    this.sale_price,
    this.sale_price_rendered,
    this.categories,
    this.meta_data,
    this.count_students = 0,
    this.course_data,
    this.can_retake,
    this.instructor,
  });

  String get levelLabel => (price ?? 0) == 0 ? 'Beginner' : 'Advanced';

  String get categoryLabel {
    if (categories != null && categories!.isNotEmpty) {
      return categories!.first.name ?? '';
    }
    return '';
  }

  CourseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0;
    name = json['name']?.toString().replaceAllMapped(RegExp(r'&#(\d+);'), (m) => String.fromCharCode(int.parse(m.group(1)!))).replaceAll('&amp;', '&').replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&quot;', '"');
    slug = json['slug'];
    permalink = json['permalink'];
    image = json['image'];
    date_created = json['date_created'];
    date_created_gmt = json['date_created_gmt'];
    status = json['status'];
    on_sale = json['on_sale'];
    content = json['content'];

    excerpt = json['excerpt'];
    if (json['duration'] != null) duration = json['duration'];
    if (json['instructor'] != null) instructor = json['instructor'];
    if (json['count_students'] != null) {
      count_students = int.tryParse(json['count_students']?.toString() ?? '') ?? 0;
    }
    if (json['total_lessons'] != null) {
      totalLessons = int.tryParse(json['total_lessons']?.toString() ?? '') ?? 0;
    }
    if (json['count_items'] != null) {
      count_items = int.tryParse(json['count_items']?.toString() ?? '') ?? 0;
    } else if (json['sections'] is List) {
      count_items = (json['sections'] as List).length;
    }
    if (json['rating'] != null) {
      if (json['rating'] is num) {
        rating = (json['rating'] as num).toDouble();
      } else if (json['rating'] is String) {
        rating = double.tryParse(json['rating']) ?? 0;
      }
    }
    if (json['price'] != null) price = double.tryParse(json['price']?.toString() ?? '') ?? 0;
    price_rendered = json['price_rendered'];
    if (json['origin_price'] != null&&json['origin_price'] != "") {
      origin_price = double.tryParse(json['origin_price']?.toString() ?? '') ?? 0;
    }
    origin_price_rendered = json['origin_price_rendered'];
    if (json['sale_price'] != null) {
      sale_price = double.tryParse(json['sale_price']?.toString() ?? '') ?? 0;
    }
    sale_price_rendered = json['sale_price_rendered'];
    if (json['categories'] is List) {
      final List<dynamic> newData = json['categories'] as List<dynamic>;
      List<CategoryModel> cates = [];
      for (var element in newData) {
        CategoryModel cate = CategoryModel.fromJson(element);
        cates.add(cate);
      }
      categories = cates;
    }
    if (json['meta_data'] != null) {
      if (json['meta_data'] is List && (json['meta_data'] as List).isEmpty) {
        // empty list, skip
      } else {
        meta_data = MetaData.fromJson(json['meta_data']);
      }
    }
    if (json['sections'] is List) {
      final List<dynamic> newDataSection = json['sections'] as List<dynamic>;
      List<LessonModel> sectionsTemp = [];
      for (var element in newDataSection) {
        LessonModel temp = LessonModel.fromJson(element);
        sectionsTemp.add(temp);
      }
      sections = sectionsTemp;
    }
    if (json['course_data'] != null) {
      course_data = CourseDataModel.fromJson(json['course_data']);
    }

    if (json['can_retake'] != null) {
      if (json["can_retake"].toString() == "0") {
        can_retake =
            (int.tryParse(json["can_retake"]?.toString() ?? '') ?? 0) == 0 ? false : true;
      }
      if (json["can_retake"] == false || json["can_retake"] == true) {
        can_retake = json["can_retake"];
      }
    } else {
      can_retake = false;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['permalink'] = permalink;
    data['image'] = image;
    data['date_created'] = date_created;
    data['date_created_gmt'] = date_created_gmt;
    data['status'] = status;
    data['on_sale'] = on_sale;
    data['content'] = content;

    data['excerpt'] = excerpt;
    data['duration'] = duration;
    data['rating'] = rating;
    data['price'] = price;
    data['price_rendered'] = price_rendered;
    data['origin_price'] = origin_price;
    data['origin_price_rendered'] = origin_price_rendered;
    data['sale_price'] = sale_price;
    data['sale_price_rendered'] = sale_price_rendered;
    data['categories'] = categories;
    data['meta_data'] = meta_data;
    data['sections'] = sections;

    return data;
  }
}

class CourseDataModel {
  String? graduation;
  String? status;
  String? start_time;
  String? end_time;
  String? expiration_time;
  CourseDataResult? result;
  CourseDataModel({
    this.graduation,
    this.status,
    this.start_time,
    this.end_time,
    this.expiration_time,
    this.result,
  });
  CourseDataModel.fromJson(Map<String, dynamic> json) {
    graduation = json['graduation'];
    status = json['status'];
    start_time = json['start_time'];
    end_time = json['end_time'];
    expiration_time = json['expiration_time'];
    if (json['result'] != null) {
      result = CourseDataResult.fromJson(json['result']);
    }
  }
}

class CourseDataResult {
  double? result;
  int? pass;
  int? count_items;
  int? completed_items;
  ItemResult? items;
  CourseDataResult({
    this.result,
    this.pass,
    this.count_items,
    this.completed_items,
    this.items,
  });
  CourseDataResult.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      result = double.tryParse(json['result']?.toString() ?? '') ?? 0;
    }
    pass = json['pass'];
    if (json['count_items'] != null) {
      count_items = int.tryParse(json['count_items']?.toString() ?? '') ?? 0;
    }
    if (json['completed_items'] != null) {
      completed_items = int.tryParse(json['completed_items']?.toString() ?? '') ?? 0;
    }
    if (json['items'] != null && json['items'] is Map && (json['items'] as Map).isNotEmpty) {
      items = ItemResult.fromJson(json['items']);
    }

  }
}

class ItemResult {
  ItemOption? lesson;
  ItemOption? quiz;
  ItemResult({this.lesson, this.quiz});
  ItemResult.fromJson(Map<String, dynamic> json) {
    if (json['lesson'] != null) {
      lesson = ItemOption.fromJson(json['lesson']);
    }
    if (json['quiz'] != null) {
      quiz = ItemOption.fromJson(json['quiz']);
    }
  }
}

class ItemOption {
  int? completed;
  int? passed;
  int? total;
  ItemOption({this.completed, this.passed, this.total});
  ItemOption.fromJson(Map<String, dynamic> json) {
    if (json['completed'] != null) {
      completed = int.tryParse(json['completed']?.toString() ?? '') ?? 0;
    }
    if (json['passed'] != null) {
      passed = int.tryParse(json['passed']?.toString() ?? '') ?? 0;
    }
    if (json['total'] != null) {
      total = int.tryParse(json['total']?.toString() ?? '') ?? 0;
    }
  }
}

class MetaData {
  double? lp_passing_condition;
  String? lp_level;
  MetaData({this.lp_passing_condition, this.lp_level});
  MetaData.fromJson(Map<String, dynamic> json) {
    if (json['_lp_passing_condition'] != null) {
      lp_passing_condition =
          double.tryParse(json['_lp_passing_condition']?.toString() ?? '') ?? 0;
    }
    if (json['_lp_level'] != null) {
      lp_level = json['_lp_level']?.toString();
    }
  }
}
