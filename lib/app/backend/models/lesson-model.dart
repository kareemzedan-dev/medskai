import 'dart:convert';

import 'package:flutter_app/app/backend/models/cate-model.dart';

class ItemLesson {
  int? id;
  String? type;
  String? title;
  bool? preview;
  String? duration;
  String? graduation;
  String? status;
  bool? locked;
  ItemLesson({
    this.id,
    this.type,
    this.title,
    this.preview,
    this.duration,
    this.graduation,
    this.status,
    this.locked,
  });
  ItemLesson.fromJson(Map<String, dynamic> json) {
    if (json['id'] != null) {
      id = int.tryParse(json['id']?.toString() ?? '') ?? 0;
    }
    type = json['type'];
    title = json['title'];
    preview = json['preview'] is bool ? json['preview'] : false;
    duration = json['duration'];
    graduation = json['graduation'];
    status = json['status'];
    locked = json['locked'] is bool ? json['locked'] : false;
  }
}

class LessonModel {
  int? id;
  String? title;
  int? course_id;
  String? description;
  int? order;
  List<ItemLesson>? items;
  bool isExpanded = false;

  List<CategoryModel>? categories = [];
  dynamic meta_data;
  int count_students = 0;
  LessonModel({
    this.id,
    this.title,
    this.course_id,
    this.description,
    this.order,
    this.items,
    this.isExpanded = false,
  });

  LessonModel.fromJson(Map<String, dynamic> json) {
    if (json['id'] != null) {
      id = int.tryParse(json['id']?.toString() ?? '') ?? 0;
    }
    if (json['course_id'] != null) {
      course_id = int.tryParse(json['course_id']?.toString() ?? '') ?? 0;
    }
    if (json['order'] != null) {
      order = int.tryParse(json['order']?.toString() ?? '') ?? 0;
    }
    title = json['title'];
    description = json['description'];

    if (json['items'] != null) {
      final List<dynamic> newData = json['items'] as List<dynamic>;
      List<ItemLesson> temp = [];
      for (var element in newData) {
        ItemLesson cate = ItemLesson.fromJson(element);
        temp.add(cate);
      }
      items = temp;
    }
  }
}
