import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Intranet/modules/projects/models/dashboard_colors.dart';

class ProjectShimmer extends StatelessWidget {
  const ProjectShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          height: 140,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class ProjectEmptyWidget extends StatelessWidget {
  const ProjectEmptyWidget({
    super.key,
    this.onRetry,
    this.title = 'No Projects Found',
    this.subtitle = 'Try adjusting search or filters',
  });

  final VoidCallback? onRetry;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                style: DashboardColors.primaryFilledButton(),
                onPressed: onRetry,
                child: const Text('Refresh'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProjectErrorWidget extends StatelessWidget {
  const ProjectErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                style: DashboardColors.primaryFilledButton(),
                onPressed: onRetry,
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
