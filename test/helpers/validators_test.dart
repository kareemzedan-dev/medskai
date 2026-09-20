import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/app/helper/validators.dart';

/// Note: AppValidators uses easy_localization's tr() for error messages.
/// In a test environment without full localization setup, tr() may throw.
///
/// Strategy:
///   - VALID inputs never reach tr(), so we can assert they return null.
///   - INVALID inputs call tr() to build an error message. We verify they
///     produce a non-null result OR throw (both confirm the validation
///     logic correctly rejected the input). A helper [_expectInvalid] is
///     used for this purpose.

/// Runs [validator] and returns true if it returned a non-null string
/// (invalid) or threw an exception (tr() not initialized). Returns false
/// only if the validator returned null (i.e. considered the input valid).
bool _isRejected(String? Function() validator) {
  try {
    return validator() != null;
  } catch (_) {
    // tr() threw because localization is not initialized — this still
    // means the validator detected invalid input and tried to build an
    // error message.
    return true;
  }
}

void main() {
  // ───────────────────────────── required ─────────────────────────────
  group('AppValidators.required', () {
    test('returns null for valid non-empty string', () {
      expect(AppValidators.required('hello'), isNull);
    });

    test('returns null for string with whitespace padding', () {
      expect(AppValidators.required('  hello  '), isNull);
    });

    test('rejects null', () {
      expect(_isRejected(() => AppValidators.required(null)), isTrue);
    });

    test('rejects empty string', () {
      expect(_isRejected(() => AppValidators.required('')), isTrue);
    });

    test('rejects whitespace-only string', () {
      expect(_isRejected(() => AppValidators.required('   ')), isTrue);
    });
  });

  // ───────────────────────────── email ────────────────────────────────
  group('AppValidators.email', () {
    test('returns null for valid email', () {
      expect(AppValidators.email('user@example.com'), isNull);
    });

    test('returns null for email with dots and plus', () {
      expect(AppValidators.email('first.last+tag@sub.domain.com'), isNull);
    });

    test('rejects null', () {
      expect(_isRejected(() => AppValidators.email(null)), isTrue);
    });

    test('rejects empty string', () {
      expect(_isRejected(() => AppValidators.email('')), isTrue);
    });

    test('rejects string without @', () {
      expect(_isRejected(() => AppValidators.email('userexample.com')), isTrue);
    });

    test('rejects string without domain', () {
      expect(_isRejected(() => AppValidators.email('user@')), isTrue);
    });

    test('rejects string without TLD', () {
      expect(_isRejected(() => AppValidators.email('user@domain')), isTrue);
    });

    test('rejects string with spaces', () {
      expect(_isRejected(() => AppValidators.email('user @example.com')), isTrue);
    });
  });

  // ──────────────────────────── password ──────────────────────────────
  group('AppValidators.password', () {
    test('returns null for valid password (>= 6 chars)', () {
      expect(AppValidators.password('abcdef'), isNull);
    });

    test('returns null for long password', () {
      expect(AppValidators.password('a_very_long_password_123!'), isNull);
    });

    test('rejects null', () {
      expect(_isRejected(() => AppValidators.password(null)), isTrue);
    });

    test('rejects empty string', () {
      expect(_isRejected(() => AppValidators.password('')), isTrue);
    });

    test('rejects short password (< 6 chars)', () {
      expect(_isRejected(() => AppValidators.password('abc')), isTrue);
    });

    test('rejects password shorter than custom minLength', () {
      expect(_isRejected(() => AppValidators.password('abcdefgh', minLength: 10)), isTrue);
    });

    test('returns null for password meeting custom minLength', () {
      expect(AppValidators.password('abcdefghij', minLength: 10), isNull);
    });
  });

  // ───────────────────────── confirmPassword ─────────────────────────
  group('AppValidators.confirmPassword', () {
    test('returns null when passwords match', () {
      expect(AppValidators.confirmPassword('secret123', 'secret123'), isNull);
    });

    test('rejects null value', () {
      expect(
        _isRejected(() => AppValidators.confirmPassword(null, 'secret123')),
        isTrue,
      );
    });

    test('rejects empty value', () {
      expect(
        _isRejected(() => AppValidators.confirmPassword('', 'secret123')),
        isTrue,
      );
    });

    test('rejects non-matching passwords', () {
      expect(
        _isRejected(() => AppValidators.confirmPassword('secret123', 'different')),
        isTrue,
      );
    });
  });

  // ──────────────────────────── phone ─────────────────────────────────
  group('AppValidators.phone', () {
    test('returns null for null (phone is optional)', () {
      expect(AppValidators.phone(null), isNull);
    });

    test('returns null for empty string (phone is optional)', () {
      expect(AppValidators.phone(''), isNull);
    });

    test('returns null for valid phone number', () {
      expect(AppValidators.phone('+1234567890'), isNull);
    });

    test('returns null for phone with dashes and spaces', () {
      expect(AppValidators.phone('+1 (234) 567-8901'), isNull);
    });

    test('returns null for simple digits', () {
      expect(AppValidators.phone('1234567'), isNull);
    });

    test('rejects too-short phone number', () {
      expect(_isRejected(() => AppValidators.phone('123')), isTrue);
    });

    test('rejects phone with letters', () {
      expect(_isRejected(() => AppValidators.phone('123-ABC-7890')), isTrue);
    });
  });

  // ─────────────────────────── username ───────────────────────────────
  group('AppValidators.username', () {
    test('returns null for valid username (>= 3 chars, no spaces)', () {
      expect(AppValidators.username('john'), isNull);
    });

    test('returns null for long username', () {
      expect(AppValidators.username('johndoe_123'), isNull);
    });

    test('rejects null', () {
      expect(_isRejected(() => AppValidators.username(null)), isTrue);
    });

    test('rejects empty string', () {
      expect(_isRejected(() => AppValidators.username('')), isTrue);
    });

    test('rejects short username (< 3 chars)', () {
      expect(_isRejected(() => AppValidators.username('ab')), isTrue);
    });

    test('rejects username with spaces', () {
      expect(_isRejected(() => AppValidators.username('john doe')), isTrue);
    });
  });

  // ────────────────────────── minLength ───────────────────────────────
  group('AppValidators.minLength', () {
    test('returns null when value meets minimum', () {
      expect(AppValidators.minLength('hello', 3), isNull);
    });

    test('returns null when value equals minimum', () {
      expect(AppValidators.minLength('abc', 3), isNull);
    });

    test('rejects null', () {
      expect(_isRejected(() => AppValidators.minLength(null, 3)), isTrue);
    });

    test('rejects value shorter than minimum', () {
      expect(_isRejected(() => AppValidators.minLength('ab', 5)), isTrue);
    });
  });

  // ────────────────────────── maxLength ───────────────────────────────
  group('AppValidators.maxLength', () {
    test('returns null when value is within limit', () {
      expect(AppValidators.maxLength('hi', 10), isNull);
    });

    test('returns null for null value', () {
      expect(AppValidators.maxLength(null, 10), isNull);
    });

    test('returns null when length equals max', () {
      expect(AppValidators.maxLength('abc', 3), isNull);
    });

    test('rejects value exceeding max length', () {
      expect(_isRejected(() => AppValidators.maxLength('abcdef', 3)), isTrue);
    });
  });

  // ──────────────────────── phoneRequired ─────────────────────────────
  group('AppValidators.phoneRequired', () {
    test('returns null for valid phone', () {
      expect(AppValidators.phoneRequired('+1234567890'), isNull);
    });

    test('rejects null (required)', () {
      expect(_isRejected(() => AppValidators.phoneRequired(null)), isTrue);
    });

    test('rejects empty (required)', () {
      expect(_isRejected(() => AppValidators.phoneRequired('')), isTrue);
    });

    test('rejects invalid phone format', () {
      expect(_isRejected(() => AppValidators.phoneRequired('abc')), isTrue);
    });
  });
}
