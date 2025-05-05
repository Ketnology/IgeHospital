import 'package:flutter/material.dart';
import 'package:ige_hospital/provider/colors_provider.dart';
import 'package:provider/provider.dart';

class DashboardCard extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final double elevation;
  final double hoverElevation;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.elevation = 2.0,
    this.hoverElevation = 8.0,
    this.borderRadius,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColourNotifier>(context);
    final effectiveBackgroundColor =
        widget.backgroundColor ?? notifier.getContainer;
    final effectiveBorderRadius =
        widget.borderRadius ?? BorderRadius.circular(10.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: effectiveBorderRadius,
            border: Border.all(color: notifier.getBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovering ? 0.2 : 0.1),
                blurRadius:
                    _isHovering ? widget.hoverElevation : widget.elevation,
                offset: Offset(0, _isHovering ? 4 : 2),
                spreadRadius: _isHovering ? 2 : 0,
              ),
            ],
          ),
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }
}
