import 'package:flutter/material.dart';

class ErrorBox extends StatelessWidget {
  final String errorMessage;
  final String actionText;
  final Future<void> Function() onPressed;
  const ErrorBox({
    super.key,
    required this.errorMessage,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 150,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 0.5, color: theme.colorScheme.outline),
        color: theme.colorScheme.surface.withAlpha(180),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            errorMessage,
            style: theme.textTheme.bodyLarge!.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onPressed, child: Text(actionText)),
        ],
      ),
    );
  }
}
