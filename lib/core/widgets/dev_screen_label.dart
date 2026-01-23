import 'package:flutter/material.dart';

import '../config/feature_flags.dart';

/// A subtle label that shows the current screen name.
/// Controlled by FeatureFlags.showDevScreenLabels. Does not interfere with navigation.
class DevScreenLabel extends StatelessWidget {
  final String screenName;
  final Widget child;

  const DevScreenLabel({
    super.key,
    required this.screenName,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Controlled by feature flag
    if (!FeatureFlags.showDevScreenLabels) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          top: MediaQuery.of(context).padding.top + 4,
          right: 4,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                screenName,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
