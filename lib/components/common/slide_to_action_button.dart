import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SlideToActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onConfirm;
  final Color backgroundColor;
  final Color trackColor;

  const SlideToActionButton({
    super.key,
    required this.label,
    required this.onConfirm,
    this.icon = Icons.chevron_right_rounded,
    this.backgroundColor = AppColors.primaryDark,
    this.trackColor = AppColors.inputFill,
  });

  @override
  State<SlideToActionButton> createState() => _SlideToActionButtonState();
}

class _SlideToActionButtonState extends State<SlideToActionButton>
    with SingleTickerProviderStateMixin {
  static const double _thumbSize = 48;
  static const double _trackHeight = 56;

  late final AnimationController _controller;
  double _dragDx = 0;
  double _maxDrag = 0;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 220))
      ..addListener(() => setState(() => _dragDx = _controller.value * _maxDrag));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_confirmed) return;
    setState(() => _dragDx = (_dragDx + details.delta.dx).clamp(0, _maxDrag));
  }

  void _onDragEnd(DragEndDetails details) {
    if (_confirmed) return;
    final threshold = _maxDrag * 0.75;
    if (_dragDx >= threshold) {
      setState(() {
        _confirmed = true;
        _dragDx = _maxDrag;
      });
      widget.onConfirm();
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _confirmed = false;
          _dragDx = 0;
        });
      });
    } else {
      _controller.value = _dragDx / _maxDrag;
      _controller.reverse(from: _controller.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _maxDrag = constraints.maxWidth - _thumbSize - 8;
        final progress = _maxDrag == 0 ? 0.0 : (_dragDx / _maxDrag).clamp(0.0, 1.0);

        return Container(
          height: _trackHeight,
          decoration: BoxDecoration(
            color: widget.trackColor,
            borderRadius: BorderRadius.circular(_trackHeight / 2),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Center(
                child: Opacity(
                  opacity: 1 - progress,
                  child: Text(
                    widget.label,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Transform.translate(
                  offset: Offset(_dragDx, 0),
                  child: GestureDetector(
                    onHorizontalDragUpdate: _onDragUpdate,
                    onHorizontalDragEnd: _onDragEnd,
                    child: Container(
                      width: _thumbSize,
                      height: _thumbSize,
                      decoration: BoxDecoration(color: widget.backgroundColor, shape: BoxShape.circle),
                      child: Icon(_confirmed ? Icons.check_rounded : widget.icon, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}