/// DI Backwards Compatibility File
///
/// This file re-exports from the new core/di location
/// for backwards compatibility with existing imports.
///
/// New code should import from:
/// ```dart
/// import 'package:flutter_app/app/core/di/di.dart';
/// ```
library init;

// Re-export from core
export '../core/di/injection.dart';

// Legacy MainBinding - already defined in injection.dart
// Just re-export for backwards compatibility
