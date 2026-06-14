import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';

/// Wraps [child] and applies a Gaussian blur when discreet mode is on,
/// animating the blur radius in/out (matches the app's 180ms convention).
class DiscreetAmount extends ConsumerWidget {
  final Widget child;

  const DiscreetAmount({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discreet =
        ref.watch(settingsProvider).asData?.value.discreetMode ?? false;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: discreet ? 6.0 : 0.0),
      duration: const Duration(milliseconds: 180),
      builder: (context, sigma, child) => sigma == 0
          ? child!
          : ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: sigma,
                sigmaY: sigma,
                tileMode: TileMode.decal,
              ),
              child: child,
            ),
      child: child,
    );
  }
}
