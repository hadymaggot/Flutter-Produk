import 'package:flutter/material.dart';

class PullToRefreshWidget extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  const PullToRefreshWidget({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
