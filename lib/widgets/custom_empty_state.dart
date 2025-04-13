import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionText;
  final double iconSize;
  final Color? iconColor;

  const CustomEmptyState({
    Key? key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onActionPressed,
    this.actionText,
    this.iconSize = 64.0,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppTheme.textSecondaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTheme.bodyText1.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: AppTheme.buttonText.copyWith(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoResultsEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onClearSearch;

  const NoResultsEmptyState({
    Key? key,
    this.message = 'No results found',
    this.onClearSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomEmptyState(
      message: message,
      icon: Icons.search_off_outlined,
      onActionPressed: onClearSearch,
      actionText: onClearSearch != null ? 'Clear Search' : null,
    );
  }
}

class NoInternetEmptyState extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetEmptyState({
    Key? key,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomEmptyState(
      message: 'No internet connection',
      icon: Icons.wifi_off_outlined,
      onActionPressed: onRetry,
      actionText: 'Retry',
    );
  }
}

class ErrorEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorEmptyState({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomEmptyState(
      message: message,
      icon: Icons.error_outline,
      onActionPressed: onRetry,
      actionText: 'Try Again',
      iconColor: AppTheme.errorColor,
    );
  }
} 