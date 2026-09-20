import 'package:flutter_app/app/util/toast.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sanitizeToastMessage', () {
    test('removes HTML tags from WordPress API errors', () {
      expect(
        sanitizeToastMessage(
          '<strong>Error:</strong> Unknown email address. Check again or try your username.',
        ),
        'Error: Unknown email address. Check again or try your username.',
      );
    });

    test('decodes common HTML entities and normalizes whitespace', () {
      expect(
        sanitizeToastMessage('Invalid&nbsp;login &amp; password<br>Try again'),
        'Invalid login & password Try again',
      );
    });
  });
}
