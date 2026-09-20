import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/backend/models/job_model.dart';

void main() {
  group('JobModel.fromJson', () {
    test('parses valid complete JSON with meta', () {
      final json = {
        'id': 101,
        'title': {'rendered': 'Senior Flutter Developer'},
        'content': {'rendered': '<p>Job description here</p>'},
        'date': '2024-03-15T10:00:00',
        'link': 'https://example.com/jobs/101',
        'meta': {
          '_company_name': 'Acme Corp',
          '_job_location': 'Remote',
          '_job_type': 'Full-time',
        },
      };

      final job = JobModel.fromJson(json);

      expect(job.id, 101);
      expect(job.title, 'Senior Flutter Developer');
      expect(job.content, '<p>Job description here</p>');
      expect(job.date, '2024-03-15T10:00:00');
      expect(job.link, 'https://example.com/jobs/101');
      expect(job.companyName, 'Acme Corp');
      expect(job.location, 'Remote');
      expect(job.jobType, 'Full-time');
    });

    test('parses title and content as plain strings', () {
      final json = {
        'id': 102,
        'title': 'Plain Title',
        'content': 'Plain content',
        'date': '2024-01-01',
        'link': 'https://example.com/102',
      };

      final job = JobModel.fromJson(json);

      expect(job.id, 102);
      expect(job.title, 'Plain Title');
      expect(job.content, 'Plain content');
    });

    test('parses with job_listing_meta instead of meta', () {
      final json = {
        'id': 103,
        'title': 'Backend Dev',
        'job_listing_meta': {
          '_job_listing_company_name': 'Beta Inc',
          '_job_listing_location': 'New York',
          '_job_listing_job_type': 'Part-time',
        },
      };

      final job = JobModel.fromJson(json);

      expect(job.companyName, 'Beta Inc');
      expect(job.location, 'New York');
      expect(job.jobType, 'Part-time');
    });

    test('parses with top-level fallback fields', () {
      final json = {
        'id': 104,
        'title': 'Designer',
        'company_name': 'Gamma LLC',
        'location': 'London',
        'job_type': 'Contract',
      };

      final job = JobModel.fromJson(json);

      expect(job.companyName, 'Gamma LLC');
      expect(job.location, 'London');
      expect(job.jobType, 'Contract');
    });

    test('parses with null meta', () {
      final json = {
        'id': 105,
        'title': 'Tester',
        'meta': null,
      };

      final job = JobModel.fromJson(json);

      expect(job.id, 105);
      expect(job.title, 'Tester');
      expect(job.companyName, isNull);
      expect(job.location, isNull);
      expect(job.jobType, isNull);
    });

    test('parses with missing fields', () {
      final json = <String, dynamic>{
        'id': 106,
      };

      final job = JobModel.fromJson(json);

      expect(job.id, 106);
      expect(job.title, isNull);
      expect(job.content, isNull);
      expect(job.date, isNull);
      expect(job.link, isNull);
      expect(job.companyName, isNull);
      expect(job.location, isNull);
      expect(job.jobType, isNull);
    });

    test('parses empty JSON', () {
      final json = <String, dynamic>{};

      final job = JobModel.fromJson(json);

      expect(job.id, isNull);
      expect(job.title, isNull);
    });

    test('parses id as string', () {
      final json = {'id': '200'};

      final job = JobModel.fromJson(json);
      expect(job.id, 200);
    });

    test('cleans HTML entities from title', () {
      final json = {
        'id': 107,
        'title': 'Dev &amp; Design &#8211; It&#8217;s great',
      };

      final job = JobModel.fromJson(json);
      expect(job.title, "Dev & Design \u2013 It's great");
    });

    test('uses guid as fallback for link', () {
      final json = {
        'id': 108,
        'guid': 'https://example.com/?p=108',
      };

      final job = JobModel.fromJson(json);
      expect(job.link, 'https://example.com/?p=108');
    });

    test('uses geolocation_formatted_address as fallback location', () {
      final json = {
        'id': 109,
        'title': 'Remote Job',
        'meta': {
          'geolocation_formatted_address': '123 Main St, City',
        },
      };

      final job = JobModel.fromJson(json);
      expect(job.location, '123 Main St, City');
    });
  });

  group('JobModel.formattedDate', () {
    test('formats valid ISO date', () {
      final job = JobModel(date: '2024-03-15T10:00:00');
      expect(job.formattedDate, 'March 15, 2024');
    });

    test('returns empty string for null date', () {
      final job = JobModel(date: null);
      expect(job.formattedDate, '');
    });

    test('returns raw string for invalid date', () {
      final job = JobModel(date: 'not-a-date');
      expect(job.formattedDate, 'not-a-date');
    });
  });

  group('JobModel.toJson', () {
    test('serializes all fields', () {
      final job = JobModel(
        id: 1,
        title: 'Dev',
        content: 'Description',
        companyName: 'Corp',
        location: 'Remote',
        jobType: 'Full-time',
        date: '2024-01-01',
        link: 'https://example.com',
      );
      final json = job.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Dev');
      expect(json['company_name'], 'Corp');
      expect(json['location'], 'Remote');
      expect(json['job_type'], 'Full-time');
    });
  });
}
