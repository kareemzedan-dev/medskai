import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/backend/models/course_model.dart';

void main() {
  group('CourseModel.fromJson', () {
    test('parses valid complete JSON', () {
      final json = {
        'id': 1,
        'name': 'Flutter Course',
        'slug': 'flutter-course',
        'permalink': 'https://example.com/flutter-course',
        'image': 'https://example.com/image.png',
        'date_created': '2024-01-01',
        'date_created_gmt': '2024-01-01T00:00:00',
        'status': 'publish',
        'on_sale': true,
        'content': '<p>Course content</p>',
        'excerpt': 'Short description',
        'duration': '10 hours',
        'rating': 4.5,
        'price': '29.99',
        'price_rendered': '\$29.99',
        'origin_price': '49.99',
        'origin_price_rendered': '\$49.99',
        'sale_price': '29.99',
        'sale_price_rendered': '\$29.99',
        'count_students': '150',
        'categories': [
          {'id': 1, 'name': 'Programming', 'slug': 'programming'},
        ],
        'meta_data': {'_lp_passing_condition': '80'},
        'can_retake': true,
        'instructor': {'id': 1, 'name': 'John'},
      };

      final course = CourseModel.fromJson(json);

      expect(course.id, 1);
      expect(course.name, 'Flutter Course');
      expect(course.slug, 'flutter-course');
      expect(course.permalink, 'https://example.com/flutter-course');
      expect(course.image, 'https://example.com/image.png');
      expect(course.date_created, '2024-01-01');
      expect(course.status, 'publish');
      expect(course.on_sale, true);
      expect(course.content, '<p>Course content</p>');
      expect(course.excerpt, 'Short description');
      expect(course.duration, '10 hours');
      expect(course.rating, 4.5);
      expect(course.price, 29.99);
      expect(course.price_rendered, '\$29.99');
      expect(course.origin_price, 49.99);
      expect(course.sale_price, 29.99);
      expect(course.count_students, 150);
      expect(course.can_retake, true);
      expect(course.instructor, isNotNull);
      expect(course.meta_data, isNotNull);
      expect(course.meta_data!.lp_passing_condition, 80.0);
    });

    test('parses JSON with null fields', () {
      final json = {
        'id': 2,
        'name': null,
        'slug': null,
        'permalink': null,
        'image': null,
        'date_created': null,
        'status': null,
        'on_sale': null,
        'content': null,
        'excerpt': null,
        'duration': null,
        'rating': null,
        'price': null,
        'price_rendered': null,
        'origin_price': null,
        'sale_price': null,
        'categories': null,
        'meta_data': null,
        'can_retake': null,
        'instructor': null,
        'count_students': null,
      };

      final course = CourseModel.fromJson(json);

      expect(course.id, 2);
      expect(course.name, isNull);
      expect(course.slug, isNull);
      expect(course.rating, 0); // default
      expect(course.price, isNull);
      expect(course.can_retake, false); // null falls to else branch
      expect(course.count_students, 0);
    });

    test('parses JSON with missing keys', () {
      final json = <String, dynamic>{
        'id': 5,
        'name': 'Minimal Course',
      };

      final course = CourseModel.fromJson(json);

      expect(course.id, 5);
      expect(course.name, 'Minimal Course');
      expect(course.slug, isNull);
      expect(course.permalink, isNull);
      expect(course.image, isNull);
      expect(course.status, isNull);
      expect(course.on_sale, isNull);
      expect(course.content, isNull);
      expect(course.excerpt, isNull);
      expect(course.price, isNull);
      expect(course.categories, isEmpty);
      expect(course.meta_data, isNull);
      expect(course.can_retake, false);
      expect(course.count_students, 0);
    });

    test('parses JSON with wrong types (string for id)', () {
      final json = {
        'id': '42',
        'name': 'Type Mismatch Course',
        'rating': '3.7',
        'price': '19.99',
        'count_students': '25',
        'origin_price': '39.99',
        'sale_price': '19.99',
      };

      final course = CourseModel.fromJson(json);

      expect(course.id, 42);
      expect(course.rating, 3.7);
      expect(course.price, 19.99);
      expect(course.count_students, 25);
      expect(course.origin_price, 39.99);
      expect(course.sale_price, 19.99);
    });

    test('parses empty JSON {}', () {
      final json = <String, dynamic>{};

      final course = CourseModel.fromJson(json);

      expect(course.id, 0); // int.tryParse on null => 0
      expect(course.name, isNull);
      expect(course.slug, isNull);
      expect(course.price, isNull);
      expect(course.rating, 0);
      expect(course.count_students, 0);
      expect(course.can_retake, false);
    });

    test('parses can_retake as "0" string', () {
      final json = {
        'id': 10,
        'can_retake': '0',
      };

      final course = CourseModel.fromJson(json);
      expect(course.can_retake, false);
    });

    test('parses can_retake as false boolean', () {
      final json = {
        'id': 11,
        'can_retake': false,
      };

      final course = CourseModel.fromJson(json);
      expect(course.can_retake, false);
    });

    test('handles meta_data as empty list', () {
      final json = {
        'id': 12,
        'meta_data': [],
      };

      final course = CourseModel.fromJson(json);
      expect(course.meta_data, isNull);
    });

    test('handles origin_price as empty string', () {
      final json = {
        'id': 13,
        'origin_price': '',
      };

      final course = CourseModel.fromJson(json);
      expect(course.origin_price, isNull);
    });
  });

  group('CourseDataModel.fromJson', () {
    test('parses valid JSON with result', () {
      final json = {
        'graduation': 'passed',
        'status': 'completed',
        'start_time': '2024-01-01',
        'end_time': '2024-06-01',
        'expiration_time': '2025-01-01',
        'result': {
          'result': '85.5',
          'pass': 1,
          'count_items': '10',
          'completed_items': '8',
          'items': {
            'lesson': {'completed': '5', 'passed': '5', 'total': '6'},
            'quiz': {'completed': '3', 'passed': '3', 'total': '4'},
          },
        },
      };

      final data = CourseDataModel.fromJson(json);

      expect(data.graduation, 'passed');
      expect(data.status, 'completed');
      expect(data.start_time, '2024-01-01');
      expect(data.result, isNotNull);
      expect(data.result!.result, 85.5);
      expect(data.result!.count_items, 10);
      expect(data.result!.completed_items, 8);
      expect(data.result!.items, isNotNull);
      expect(data.result!.items!.lesson!.completed, 5);
      expect(data.result!.items!.quiz!.total, 4);
    });

    test('parses JSON without result', () {
      final json = {
        'graduation': 'in-progress',
        'status': 'enrolled',
      };

      final data = CourseDataModel.fromJson(json);
      expect(data.graduation, 'in-progress');
      expect(data.result, isNull);
    });
  });

  group('MetaData.fromJson', () {
    test('parses passing condition', () {
      final meta = MetaData.fromJson({'_lp_passing_condition': '75'});
      expect(meta.lp_passing_condition, 75.0);
    });

    test('handles null passing condition', () {
      final meta = MetaData.fromJson({});
      expect(meta.lp_passing_condition, isNull);
    });
  });

  group('CourseModel.toJson', () {
    test('round-trips basic fields', () {
      final course = CourseModel(
        id: 1,
        name: 'Test',
        slug: 'test',
        price: 9.99,
      );
      final json = course.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Test');
      expect(json['slug'], 'test');
      expect(json['price'], 9.99);
    });
  });
}
