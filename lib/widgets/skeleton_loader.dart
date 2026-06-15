import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SkeletonLoader(width: 200, height: 32),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(5, (_) => const SkeletonLoader(width: 220, height: 100)),
              ),
              const SizedBox(height: 24),
              const SkeletonLoader(width: double.infinity, height: 150),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: SkeletonLoader(width: double.infinity, height: 300)),
                  const SizedBox(width: 24),
                  const Expanded(child: SkeletonLoader(width: double.infinity, height: 300)),
                ],
              ),
              const SizedBox(height: 32),
              const SkeletonLoader(width: 200, height: 32),
              const SizedBox(height: 16),
              const SkeletonLoader(width: double.infinity, height: 400),
            ],
          ),
        ),
      ),
    );
  }
}
