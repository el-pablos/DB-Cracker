import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'ctos_container.dart';

/// Widget untuk menangani error dengan styling ctOS
class CtOSErrorBoundary extends StatelessWidget {
  final Widget child;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool showRetryButton;

  const CtOSErrorBoundary({
    Key? key,
    required this.child,
    this.errorMessage,
    this.onRetry,
    this.showRetryButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return _buildErrorWidget();
    }
    return child;
  }

  Widget _buildErrorWidget() {
    return CtOSContainer(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error icon
          Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              color: CtOSColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40.0),
              border: Border.all(
                color: CtOSColors.error,
                width: 2.0,
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              color: CtOSColors.error,
              size: 40.0,
            ),
          ),
          
          const SizedBox(height: 24.0),
          
          // Error title
          const CtOSText(
            'SISTEM ERROR',
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: CtOSColors.error,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12.0),
          
          // Error message
          CtOSText(
            errorMessage ?? 'Terjadi kesalahan yang tidak diketahui',
            fontSize: 14.0,
            color: CtOSColors.textSecondary,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          
          const SizedBox(height: 24.0),
          
          // Retry button
          if (showRetryButton && onRetry != null)
            CtOSButton(
              text: 'COBA LAGI',
              onPressed: onRetry!,
              icon: Icons.refresh,
              isPrimary: false,
            ),
        ],
      ),
    );
  }
}

/// Widget untuk loading state dengan styling ctOS
class CtOSLoadingWidget extends StatefulWidget {
  final String? message;
  final List<String>? consoleMessages;

  const CtOSLoadingWidget({
    Key? key,
    this.message,
    this.consoleMessages,
  }) : super(key: key);

  @override
  _CtOSLoadingWidgetState createState() => _CtOSLoadingWidgetState();
}

class _CtOSLoadingWidgetState extends State<CtOSLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CtOSContainer(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loading animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CtOSColors.primary.withValues(alpha: 0.3),
                    width: 3.0,
                  ),
                ),
                child: CircularProgressIndicator(
                  value: _animationController.value,
                  strokeWidth: 3.0,
                  valueColor: AlwaysStoppedAnimation<Color>(CtOSColors.primary),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24.0),
          
          // Loading message
          CtOSText(
            widget.message ?? 'MEMPROSES DATA...',
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: CtOSColors.primary,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16.0),
          
          // Console messages
          if (widget.consoleMessages != null && widget.consoleMessages!.isNotEmpty)
            Container(
              height: 120.0,
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: CtOSColors.background,
                border: Border.all(color: CtOSColors.border),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: ListView.builder(
                itemCount: widget.consoleMessages!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: CtOSText(
                      "> ${widget.consoleMessages![index]}",
                      fontSize: 11.0,
                      color: CtOSColors.textAccent,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget untuk empty state dengan styling ctOS
class CtOSEmptyWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const CtOSEmptyWidget({
    Key? key,
    required this.title,
    required this.message,
    this.icon,
    this.onAction,
    this.actionText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CtOSContainer(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty icon
          Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              color: CtOSColors.textSecondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(40.0),
              border: Border.all(
                color: CtOSColors.textSecondary,
                width: 2.0,
              ),
            ),
            child: Icon(
              icon ?? Icons.inbox_outlined,
              color: CtOSColors.textSecondary,
              size: 40.0,
            ),
          ),
          
          const SizedBox(height: 24.0),
          
          // Empty title
          CtOSText(
            title,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: CtOSColors.textPrimary,
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12.0),
          
          // Empty message
          CtOSText(
            message,
            fontSize: 14.0,
            color: CtOSColors.textSecondary,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          
          const SizedBox(height: 24.0),
          
          // Action button
          if (onAction != null && actionText != null)
            CtOSButton(
              text: actionText!,
              onPressed: onAction!,
              isPrimary: true,
            ),
        ],
      ),
    );
  }
}
