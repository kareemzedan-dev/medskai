import 'package:flutter/material.dart';

class UserInfoModel extends ChangeNotifier {
  int? id;
  String? username;
  String? name;
  String? first_name;
  String? last_name;
  String? email;
  String? url;
  String? description;
  String? nickname;
  //UserTab? tabs;
  dynamic tabs;
  late String avatar_url = "";
  dynamic instructor_data;
  int completed_courses_count = 0;
  int enrolled_courses_count = 0;

  UserInfoModel({
    this.id,
    this.username,
    this.name,
    this.first_name,
    this.last_name,
    this.email,
    this.url,
    this.description,
    this.nickname,
    this.tabs,
    this.avatar_url = "",
    this.instructor_data,
    this.completed_courses_count = 0,
    this.enrolled_courses_count = 0,
  });

  UserInfoModel.fromJson(Map<String, dynamic> json) {
    if (json['id'] != null) {
      id = int.tryParse(json['id']?.toString() ?? '') ?? 0;
    }
    username = json['username']?.toString();
    name = json['name']?.toString();
    first_name = json['first_name']?.toString();
    nickname = json['nickname']?.toString();
    last_name = json['last_name']?.toString();
    email = json['email']?.toString();
    url = json['url']?.toString();
    description = json['description']?.toString();

    // if(json['tabs'] != null){
    //   tabs = UserTab.fromJson(json['tabs']);
    // }
    tabs = json['tabs'];

    if (json['avatar_url'] != null) {
      avatar_url = json['avatar_url'].toString();
    } else {
      avatar_url = "";
    }
    instructor_data = json['instructor_data'];
    
    if (json['completed_courses_count'] != null) {
      completed_courses_count = int.tryParse(json['completed_courses_count'].toString()) ?? 0;
    }
    if (json['enrolled_courses_count'] != null) {
      enrolled_courses_count = int.tryParse(json['enrolled_courses_count'].toString()) ?? 0;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['name'] = name;
    data['first_name'] = first_name;
    data['last_name'] = last_name;
    data['email'] = email;
    data['url'] = url;
    data['description'] = description;
    data['tabs'] = tabs;
    data['avatar_url'] = avatar_url;
    data['instructor_data'] = instructor_data;
    data['nickname'] = nickname;
    data['completed_courses_count'] = completed_courses_count;
    data['enrolled_courses_count'] = enrolled_courses_count;

    return data;
  }
}
class UserTab {
  MyCourses? my_courses;
  OrderData? orders;
  UserTab({this.my_courses,this.orders});

  UserTab.fromJson(Map<String, dynamic> json){
    if (json['my-courses'] is Map<String, dynamic>) {
      my_courses = MyCourses.fromJson(json['my-courses']);
    }
    if (json['orders'] is Map<String, dynamic>) {
      orders = OrderData.fromJson(json['orders']);
    }
  }

}

class Order {
  final String orderKey;
  final int total;
  final String currency;
  final String status;
  final String date;

  Order({
    required this.orderKey,
    required this.total,
    required this.currency,
    required this.status,
    required this.date,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderKey: json['order_key']?.toString() ?? '',
      total: int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      currency: json['currency']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }
}

class OrderData {
  final String title;
  final String slug;
  final int priority;
  final String icon;
  final Map<String, Order> content;

  OrderData({
    required this.title,
    required this.slug,
    required this.priority,
    required this.icon,
    required this.content,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    Map<String, Order> orders = {};
    final content = json['content'];
    if (content is Map) {
      content.forEach((orderId, orderJson) {
        if (orderJson is Map<String, dynamic>) {
          orders[orderId.toString()] = Order.fromJson(orderJson);
        }
      });
    }

    return OrderData(
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      priority: int.tryParse(json['priority']?.toString() ?? '0') ?? 0,
      icon: json['icon']?.toString() ?? '',
      content: orders,
    );
  }
}

class MyCourses {

  String? title;
  String? slug;
  int? priority;
  String? icon;
  String? content;

  MyCourses.fromJson(Map<String, dynamic> json) {

    title = json['title']?.toString() ?? '';
    slug = json['slug']?.toString() ?? '';
    priority = int.tryParse(json['priority']?.toString() ?? '') ?? 0;
    icon = json['icon']?.toString() ?? '';
    content = json['content']?.toString() ?? '';
  }

  MyCourses({this.title, this.slug, this.priority, this.icon, this.content});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['slug'] = slug;
    data['priority'] = priority;
    data['icon'] = icon;
    data['content'] = content;
    return data;
  }
}