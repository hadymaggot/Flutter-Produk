import 'package:flutter/material.dart';

class PullToRefreshWidget extends StatefulWidget {

  final Future<void> Function() onRefresh;
  final Widget child;

  const PullToRefreshWidget({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  State<PullToRefreshWidget> createState() => _PullToRefreshWidgetState();
}

class _PullToRefreshWidgetState extends State<PullToRefreshWidget> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: widget.child,
    );
  }
   @override
  void dispose() {
    super.dispose();
  }
}
