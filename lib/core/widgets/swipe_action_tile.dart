import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SwipeAction {
  const SwipeAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

/// Swipe left to reveal action buttons behind [child].
///
/// Tiles sharing the same [openTile] notifier close each other, so only one
/// is open at a time. Set its value to null to close all of them.
class SwipeActionTile extends StatefulWidget {
  const SwipeActionTile({
    super.key,
    required this.id,
    required this.child,
    required this.actions,
    this.openTile,
    this.onTap,
    this.actionWidth = 76,
    this.backgroundColor,
  });

  final Object id;
  final Widget child;
  final List<SwipeAction> actions;

  /// Called when the row is tapped while its actions are hidden.
  final VoidCallback? onTap;
  final ValueNotifier<Object?>? openTile;
  final double actionWidth;

  /// Defaults to the theme's surface colour.
  final Color? backgroundColor;

  @override
  State<SwipeActionTile> createState() => _SwipeActionTileState();
}

class _SwipeActionTileState extends State<SwipeActionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  double get _maxSlide => widget.actions.length * widget.actionWidth;

  @override
  void initState() {
    super.initState();
    widget.openTile?.addListener(_onOpenTileChanged);
  }

  @override
  void didUpdateWidget(SwipeActionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.openTile != widget.openTile) {
      oldWidget.openTile?.removeListener(_onOpenTileChanged);
      widget.openTile?.addListener(_onOpenTileChanged);
    }
  }

  @override
  void dispose() {
    widget.openTile?.removeListener(_onOpenTileChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onOpenTileChanged() {
    if (widget.openTile!.value != widget.id) _animateTo(0);
  }

  void _open() {
    _animateTo(1);
    widget.openTile?.value = widget.id;
  }

  void _close() {
    _animateTo(0);
    if (widget.openTile?.value == widget.id) widget.openTile!.value = null;
  }

  void _animateTo(double target) {
    if (_controller.value == target) return;
    _controller.animateTo(target, curve: Curves.easeOutCubic);
  }

  /// A tap closes this row if it's open; otherwise it closes any other open
  /// row and runs [SwipeActionTile.onTap].
  void _onTap() {
    if (_controller.value > 0) return _close();
    widget.openTile?.value = null;
    widget.onTap?.call();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.primaryDelta! / _maxSlide;
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -300) return _open();
    if (velocity > 300) return _close();
    _controller.value > 0.5 ? _open() : _close();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (final action in widget.actions)
                SizedBox(
                  width: widget.actionWidth,
                  child: Material(
                    color: action.color,
                    child: InkWell(
                      onTap: () {
                        _close();
                        action.onTap();
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(action.icon, color: Colors.white, size: 22),
                          const SizedBox(height: 6),
                          Text(
                            action.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.translate(
              offset: Offset(-_controller.value * _maxSlide, 0),
              child: child,
            ),
            child: Material(
              color: widget.backgroundColor ?? context.colors.surface,
              child: InkWell(onTap: _onTap, child: widget.child),
            ),
          ),
        ),
      ],
    );
  }
}
