import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/app/core/error/app_error.dart';
import 'package:flutter_app/app/util/theme.dart';
import 'package:flutter_app/l10n/locale_keys.g.dart';

/// Reusable inline error state widget
///
/// Shows an error icon, message, and optional retry button.
/// Used as the full-page error state for screens that fail to load.
class ErrorStateWidget extends StatelessWidget {
  final AppError? appError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Color? backgroundColor;

  const ErrorStateWidget({
    super.key,
    this.appError,
    this.errorMessage,
    this.onRetry,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.kaiColors;
    final title = appError?.title ?? errorMessage ?? tr(LocaleKeys.errors_unexpected_title);
    final description = appError?.description;
    final showRetry = onRetry != null && (appError?.isRetryable ?? true);

    return Container(
      color: backgroundColor ?? colors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _iconForErrorType(appError?.type),
                  size: 64,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontFamily: 'Manrope',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontFamily: 'Manrope',
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (showRetry)
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MedsKaiColors.primary,
                      foregroundColor: MedsKaiColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      appError?.actionHint ?? tr(LocaleKeys.common_retry),
                      style: const TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconForErrorType(ErrorType? type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off_rounded;
      case ErrorType.authentication:
        return Icons.lock_outline_rounded;
      case ErrorType.server:
        return Icons.cloud_off_rounded;
      case ErrorType.validation:
        return Icons.warning_amber_rounded;
      case ErrorType.unexpected:
      case null:
        return Icons.error_outline_rounded;
    }
  }
}
