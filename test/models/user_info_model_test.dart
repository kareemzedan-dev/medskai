import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/backend/models/user_info_model.dart';

void main() {
  group('UserInfoModel.fromJson', () {
    test('parses valid complete JSON', () {
      final json = {
        'id': 1,
        'username': 'johndoe',
        'name': 'John Doe',
        'first_name': 'John',
        'last_name': 'Doe',
        'email': 'john@example.com',
        'url': 'https://example.com',
        'description': 'A user',
        'nickname': 'johnny',
        'tabs': {'some': 'data'},
        'avatar_url': 'https://example.com/avatar.png',
        'instructor_data': {'rating': 4.5},
      };

      final user = UserInfoModel.fromJson(json);

      expect(user.id, 1);
      expect(user.username, 'johndoe');
      expect(user.name, 'John Doe');
      expect(user.first_name, 'John');
      expect(user.last_name, 'Doe');
      expect(user.email, 'john@example.com');
      expect(user.url, 'https://example.com');
      expect(user.description, 'A user');
      expect(user.nickname, 'johnny');
      expect(user.tabs, isNotNull);
      expect(user.avatar_url, 'https://example.com/avatar.png');
      expect(user.instructor_data, isNotNull);
    });

    test('parses JSON with null fields', () {
      final json = {
        'id': null,
        'username': null,
        'name': null,
        'first_name': null,
        'last_name': null,
        'email': null,
        'url': null,
        'description': null,
        'nickname': null,
        'tabs': null,
        'avatar_url': null,
        'instructor_data': null,
      };

      final user = UserInfoModel.fromJson(json);

      expect(user.id, isNull);
      expect(user.username, isNull);
      expect(user.name, isNull);
      expect(user.avatar_url, ''); // defaults to empty string
      expect(user.instructor_data, isNull);
    });

    test('parses empty JSON', () {
      final json = <String, dynamic>{};

      final user = UserInfoModel.fromJson(json);

      expect(user.id, isNull);
      expect(user.username, isNull);
      expect(user.avatar_url, '');
    });

    test('parses id as string', () {
      final json = {'id': '42'};

      final user = UserInfoModel.fromJson(json);
      expect(user.id, 42);
    });

    test('toJson round-trips data', () {
      final user = UserInfoModel(
        id: 5,
        username: 'test',
        name: 'Test User',
        email: 'test@test.com',
      );
      final json = user.toJson();

      expect(json['id'], 5);
      expect(json['username'], 'test');
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@test.com');
    });
  });

  group('UserTab.fromJson', () {
    test('parses valid JSON with my-courses and orders', () {
      final json = {
        'my-courses': {
          'title': 'My Courses',
          'slug': 'my-courses',
          'priority': '10',
          'icon': 'dashicons-welcome-learn-more',
          'content': 'some content',
        },
        'orders': {
          'title': 'Orders',
          'slug': 'orders',
          'priority': '20',
          'icon': 'dashicons-clipboard',
          'content': {
            '101': {
              'order_key': 'wc_order_abc123',
              'total': '50',
              'currency': 'USD',
              'status': 'completed',
              'date': '2024-01-15',
            },
          },
        },
      };

      final tab = UserTab.fromJson(json);

      expect(tab.my_courses, isNotNull);
      expect(tab.my_courses!.title, 'My Courses');
      expect(tab.my_courses!.slug, 'my-courses');
      expect(tab.my_courses!.priority, 10);

      expect(tab.orders, isNotNull);
      expect(tab.orders!.title, 'Orders');
      expect(tab.orders!.slug, 'orders');
      expect(tab.orders!.priority, 20);
      expect(tab.orders!.content.length, 1);
      expect(tab.orders!.content['101']!.orderKey, 'wc_order_abc123');
      expect(tab.orders!.content['101']!.total, 50);
    });

    test('parses JSON with missing sections', () {
      final json = <String, dynamic>{};

      final tab = UserTab.fromJson(json);

      expect(tab.my_courses, isNull);
      expect(tab.orders, isNull);
    });

    test('parses JSON with non-map values (skips)', () {
      final json = {
        'my-courses': 'not a map',
        'orders': 123,
      };

      final tab = UserTab.fromJson(json);

      expect(tab.my_courses, isNull);
      expect(tab.orders, isNull);
    });
  });

  group('OrderData.fromJson', () {
    test('parses valid JSON', () {
      final json = {
        'title': 'Orders',
        'slug': 'orders',
        'priority': '5',
        'icon': 'icon-orders',
        'content': {
          '200': {
            'order_key': 'key_200',
            'total': '100',
            'currency': 'EUR',
            'status': 'pending',
            'date': '2024-03-01',
          },
          '201': {
            'order_key': 'key_201',
            'total': '250',
            'currency': 'USD',
            'status': 'completed',
            'date': '2024-03-15',
          },
        },
      };

      final orderData = OrderData.fromJson(json);

      expect(orderData.title, 'Orders');
      expect(orderData.slug, 'orders');
      expect(orderData.priority, 5);
      expect(orderData.icon, 'icon-orders');
      expect(orderData.content.length, 2);
      expect(orderData.content['200']!.currency, 'EUR');
      expect(orderData.content['201']!.total, 250);
    });

    test('parses JSON with null content', () {
      final json = {
        'title': 'Orders',
        'slug': 'orders',
        'priority': '0',
        'icon': '',
        'content': null,
      };

      final orderData = OrderData.fromJson(json);

      expect(orderData.title, 'Orders');
      expect(orderData.content, isEmpty);
    });

    test('parses JSON with empty content', () {
      final json = {
        'title': null,
        'slug': null,
        'priority': null,
        'icon': null,
        'content': {},
      };

      final orderData = OrderData.fromJson(json);

      expect(orderData.title, '');
      expect(orderData.slug, '');
      expect(orderData.priority, 0);
      expect(orderData.icon, '');
      expect(orderData.content, isEmpty);
    });
  });

  group('Order.fromJson', () {
    test('parses valid JSON', () {
      final json = {
        'order_key': 'wc_order_xyz',
        'total': '75',
        'currency': 'GBP',
        'status': 'processing',
        'date': '2024-02-20',
      };

      final order = Order.fromJson(json);

      expect(order.orderKey, 'wc_order_xyz');
      expect(order.total, 75);
      expect(order.currency, 'GBP');
      expect(order.status, 'processing');
      expect(order.date, '2024-02-20');
    });

    test('parses JSON with null values', () {
      final json = <String, dynamic>{
        'order_key': null,
        'total': null,
        'currency': null,
        'status': null,
        'date': null,
      };

      final order = Order.fromJson(json);

      expect(order.orderKey, '');
      expect(order.total, 0);
      expect(order.currency, '');
      expect(order.status, '');
      expect(order.date, '');
    });
  });

  group('MyCourses.fromJson', () {
    test('parses valid JSON', () {
      final json = {
        'title': 'My Courses',
        'slug': 'my-courses',
        'priority': '10',
        'icon': 'icon-class',
        'content': 'html content',
      };

      final mc = MyCourses.fromJson(json);

      expect(mc.title, 'My Courses');
      expect(mc.slug, 'my-courses');
      expect(mc.priority, 10);
      expect(mc.icon, 'icon-class');
      expect(mc.content, 'html content');
    });

    test('parses JSON with null values', () {
      final json = <String, dynamic>{};

      final mc = MyCourses.fromJson(json);

      expect(mc.title, '');
      expect(mc.slug, '');
      expect(mc.priority, 0);
      expect(mc.icon, '');
      expect(mc.content, '');
    });
  });
}
