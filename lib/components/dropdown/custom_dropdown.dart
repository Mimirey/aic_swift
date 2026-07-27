import 'package:flutter/material.dart';
import 'dropdown_color_scheme.dart';

class CustomDropdown<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final String hint;
  final ValueChanged<T> onChanged;

  final String Function(T) itemLabel;

  final bool Function(T a, T b)? compareFn;
  final bool useErrorIcon;

  final String? helperText;
  final String? errorText;
  final TextStyle? helperStyle;
  final TextStyle? errorStyle;
  final int? helperMaxLines;
  final int? errorMaxLines;
  final Color? errorOutline;

  final String? Function(T?)? validator;

  final void Function()? onEmpty;
  final String emptyText;

  final List<int> disabledIndexes;

  final DropdownColorScheme? colorScheme;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
    required this.hint,
    this.value,
    this.compareFn,
    this.helperText,
    this.errorText,
    this.helperStyle,
    this.errorStyle,
    this.helperMaxLines,
    this.errorMaxLines,
    this.validator,
    this.errorOutline,
    this.useErrorIcon = false,
    this.onEmpty,
    this.emptyText = 'Data tidak tersedia',
    this.disabledIndexes = const [],
    this.colorScheme,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownMapState<T>();
}

class _CustomDropdownMapState<T> extends State<CustomDropdown<T>>
    with SingleTickerProviderStateMixin {
  static const double _itemHeight = 46;
  static const int _maxVisibleItems = 5;

  final ScrollController _scrollController = ScrollController();
  late AnimationController _controller;
  late Animation<Offset> _slide;

  bool isOpen = false;
  String? _validationError;

  DropdownColorScheme get _colors =>
      widget.colorScheme ?? DropdownColorScheme.defaults();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool _isSelected(T item) {
    if (widget.value == null) return false;
    if (widget.compareFn != null) {
      return widget.compareFn!(item, widget.value as T);
    }
    return item == widget.value;
  }

  bool _isDisabled(int index) => widget.disabledIndexes.contains(index);

  double _popupHeight() {
    if (widget.items.isEmpty) return _itemHeight + 9;
    return widget.items.length > _maxVisibleItems
        ? _itemHeight * _maxVisibleItems
        : _itemHeight * widget.items.length + 9;
  }

  bool get _hasError {
    final errorMessage = _getCurrentError();
    return errorMessage != null && errorMessage.isNotEmpty;
  }

  String? _getCurrentError() {
    return widget.errorText ?? _validationError;
  }

  bool validate() {
    if (widget.validator != null) {
      setState(() {
        _validationError = widget.validator!(widget.value);
      });
      return _validationError == null;
    }
    return true;
  }

  void clearValidation() {
    setState(() {
      _validationError = null;
    });
  }

  Future<void> _openDropdown(BuildContext context) async {
    if (widget.items.isEmpty && widget.onEmpty != null) {
      widget.onEmpty!();
    }

    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => isOpen = true);

    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    const double screenEdgePadding = 16.0;
    const double triggerGap = -20.0;

    double popupH = _popupHeight();

    final spaceBelow =
        screenHeight -
        (offset.dy + size.height) -
        screenEdgePadding -
        bottomPadding;
    final spaceAbove = offset.dy - screenEdgePadding;

    final openAbove =
        spaceBelow < popupH + triggerGap && spaceAbove > spaceBelow;

    if (openAbove) {
      if (popupH + triggerGap > spaceAbove) {
        popupH = spaceAbove - triggerGap;
      }
    } else {
      if (popupH + triggerGap > spaceBelow) {
        popupH = spaceBelow - triggerGap;
      }
    }
    popupH = popupH.clamp(_itemHeight, double.infinity);

    final double topPos;
    if (openAbove) {
      topPos = offset.dy - popupH - triggerGap;
    } else {
      topPos = offset.dy + size.height + triggerGap;
    }

    final maxTop = screenHeight - popupH - screenEdgePadding - bottomPadding;
    final clampedTop = maxTop >= screenEdgePadding
        ? topPos.clamp(screenEdgePadding, maxTop)
        : screenEdgePadding;

    final slideTween = Tween<Offset>(
      begin: Offset(0, openAbove ? 0.08 : -0.08),
      end: Offset.zero,
    );
    _slide = slideTween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward(from: 0);

    final selected = await showDialog<T>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: clampedTop,
              child: Material(
                color: Colors.transparent,
                child: SlideTransition(
                  position: _slide,
                  child: Container(
                    width: size.width,
                    height: popupH,
                    decoration: _popupDecoration(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: widget.items.isEmpty
                          ? Center(
                              child: Text(
                                widget.emptyText,
                                style: TextStyle(
                                  color: _colors.hintTextColor,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : Scrollbar(
                              controller: _scrollController,
                              thumbVisibility:
                                  widget.items.length > _maxVisibleItems,
                              thickness: 3,
                              radius: const Radius.circular(8),
                              child: ListView(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(6),
                                children: List.generate(
                                  widget.items.length,
                                  (index) =>
                                      _buildItem(widget.items[index], index),
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    _controller.reverse();
    setState(() => isOpen = false);

    if (selected != null) {
      clearValidation();
      widget.onChanged(selected);
    }
  }

  Widget _buildItem(T item, int index) {
    final selected = _isSelected(item);
    final disabled = _isDisabled(index);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Opacity(
        opacity: disabled ? 0.38 : 1.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            // Disabled item tidak bisa di-tap
            onTap: disabled ? null : () => Navigator.pop(context, item),
            splashColor: disabled
                ? Colors.transparent
                : selected
                ? _colors.selectedItemSplashColor
                : _colors.itemSplashColor,
            highlightColor: disabled
                ? Colors.transparent
                : selected
                ? _colors.selectedItemHighlightColor
                : _colors.itemHighlightColor,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: selected && !disabled
                    ? _colors.selectedItemBackground
                    : Colors.transparent,
              ),
              child: Container(
                height: _itemHeight,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.itemLabel(item),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected && !disabled
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: selected && !disabled
                              ? _colors.selectedItemTextColor
                              : _colors.itemTextColor,
                        ),
                      ),
                    ),
                    if (selected && !disabled)
                      Icon(
                        Icons.check,
                        size: 20,
                        color: _colors.checkIconColor,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _popupDecoration() {
    return BoxDecoration(
      color: _colors.popupFillColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _colors.popupBorderColor),
      boxShadow: [
        BoxShadow(
          color: _colors.popupShadowColor.withValues(alpha: 0.1),
          blurRadius: 10,
        ),
      ],
    );
  }

  BoxDecoration _triggerDecoration() {
    final errorColor = widget.errorOutline ?? _colors.errorBorderColor;
    return BoxDecoration(
      color: _colors.fillColor,
      border: Border.all(
        color: _hasError
            ? errorColor
            : isOpen
            ? _colors.activeBorderColor
            : _colors.borderColor,
        width: _hasError ? 1.005 : 1.0,
      ),
      borderRadius: BorderRadius.circular(16),
    );
  }

  Widget _buildHelperOrErrorText() {
    final errorMessage = _getCurrentError();

    if (errorMessage != null && errorMessage.isNotEmpty) {
      final errorColor = widget.errorStyle?.color ?? _colors.errorTextColor;
      return Padding(
        padding: const EdgeInsets.only(top: 6, left: 14, right: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.useErrorIcon
                ? Padding(
                    padding: const EdgeInsets.only(top: 2, right: 6),
                    child: Icon(
                      Icons.error_outline,
                      size: 14,
                      color: errorColor,
                    ),
                  )
                : const SizedBox.shrink(),
            Expanded(
              child: Text(
                errorMessage,
                maxLines: widget.errorMaxLines ?? 2,
                overflow: TextOverflow.ellipsis,
                style:
                    widget.errorStyle ??
                    TextStyle(
                      fontSize: 12,
                      color: _colors.errorTextColor,
                      height: 1.4,
                    ),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.helperText != null && widget.helperText!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 6, left: 14, right: 14),
        child: Text(
          widget.helperText!,
          maxLines: widget.helperMaxLines ?? 2,
          overflow: TextOverflow.ellipsis,
          style:
              widget.helperStyle ??
              TextStyle(
                fontSize: 12,
                color: _colors.helperTextColor,
                height: 1.4,
              ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openDropdown(context),
          child: Container(
            decoration: _triggerDecoration(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.value == null
                        ? widget.hint
                        : widget.itemLabel(widget.value as T),
                    style: TextStyle(
                      fontSize: 16,
                      color: widget.value == null
                          ? _colors.hintTextColor
                          : _colors.valueTextColor,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: _hasError
                        ? (widget.errorOutline ?? _colors.errorBorderColor)
                        : _colors.suffixIconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildHelperOrErrorText(),
      ],
    );
  }
}
