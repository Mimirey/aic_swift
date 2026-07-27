import 'package:flutter/material.dart';
import 'dropdown_color_scheme.dart';

class CustomSearchableDropdown<T> extends StatefulWidget {
  final String? label;
  final String hint;
  final T? value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T) itemLabel;
  final bool Function(T, T)? compareItems;
  final bool enabled;

  final String? helperText;
  final String? errorText;
  final TextStyle? helperStyle;
  final TextStyle? errorStyle;
  final int? helperMaxLines;
  final int? errorMaxLines;
  final Color? errorOutline;
  final bool useErrorIcon;

  final String? Function(T?)? validator;
  final bool Function(T, String)? customFilter;

  final void Function()? onEmpty;
  final String emptyText;
  final Widget Function(String)? emptyBuilder;

  final DropdownColorScheme? colorScheme;

  const CustomSearchableDropdown({
    super.key,
    this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
    this.compareItems,
    this.enabled = true,
    this.helperText,
    this.errorText,
    this.helperStyle,
    this.errorStyle,
    this.helperMaxLines,
    this.errorMaxLines,
    this.errorOutline,
    this.useErrorIcon = false,
    this.validator,
    this.customFilter,
    this.onEmpty,
    this.emptyText = 'Data tidak tersedia',
    this.emptyBuilder,
    this.colorScheme,
  });

  @override
  State<CustomSearchableDropdown<T>> createState() =>
      _CustomSearchableDropdownState<T>();
}

class _CustomSearchableDropdownState<T>
    extends State<CustomSearchableDropdown<T>>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const double _itemHeight = 46;
  static const int _maxVisibleItems = 5;
  static const double _screenEdgePadding = 16.0;
  static const double _triggerGap = 10.0;
  static const double _emptyStateHeight = 180.0;

  final LayerLink _layerLink = LayerLink();
  final ScrollController _listScrollController = ScrollController();
  final TextEditingController _displayController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late AnimationController _animController;
  late Animation<Offset> _slide;

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  String? _validationError;

  double _triggerWidth = 0;
  double _triggerHeight = 0;
  Offset _triggerGlobalOffset = Offset.zero;

  DropdownColorScheme get _colors =>
      widget.colorScheme ?? DropdownColorScheme.defaults();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.removeListener(_onQueryChanged);
    _removeOverlay();
    _listScrollController.dispose();
    _displayController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (!_isOpen || _overlayEntry == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isOpen || _overlayEntry == null) return;
      _updateTriggerGeometry();
      _overlayEntry!.markNeedsBuild();
    });
  }

  void _updateTriggerGeometry() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached || overlayBox == null) {
      return;
    }
    _triggerWidth = renderBox.size.width;
    _triggerHeight = renderBox.size.height;
    _triggerGlobalOffset = renderBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );
  }

  void _onQueryChanged() => _overlayEntry?.markNeedsBuild();

  String? _getCurrentError() => widget.errorText ?? _validationError;

  bool get _hasError {
    final e = _getCurrentError();
    return e != null && e.isNotEmpty;
  }

  bool validate() {
    if (widget.validator != null) {
      setState(() => _validationError = widget.validator!(widget.value));
      return _validationError == null;
    }
    return true;
  }

  void clearValidation() => setState(() => _validationError = null);

  bool _compareItems(T a, T b) =>
      widget.compareItems != null ? widget.compareItems!(a, b) : a == b;

  bool _isSelected(T item) {
    final current = widget.value;
    if (current == null) return false;
    return _compareItems(item, current);
  }

  List<T> get _filtered {
    final query = _searchController.text.trim();
    if (query.isEmpty) return widget.items;
    return widget.items.where((item) {
      if (widget.customFilter != null) return widget.customFilter!(item, query);
      return widget.itemLabel(item).toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  double _calcPopupHeight(int count) {
    if (count == 0) {
      return widget.emptyBuilder != null ? _emptyStateHeight : _itemHeight + 16;
    }
    return count > _maxVisibleItems
        ? _itemHeight * _maxVisibleItems + 16
        : _itemHeight * count + 16;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  ({double popupH, Offset followerOffset, bool openAbove}) _computeGeometry(
    BuildContext overlayContext,
    int itemCount,
  ) {
    final mediaQuery = MediaQuery.of(overlayContext);
    final screenHeight = mediaQuery.size.height;
    final bottomPadding = mediaQuery.padding.bottom;
    final keyboardH = mediaQuery.viewInsets.bottom;

    final spaceBelow =
        screenHeight -
        (_triggerGlobalOffset.dy + _triggerHeight) -
        _screenEdgePadding -
        bottomPadding -
        keyboardH;
    final spaceAbove = _triggerGlobalOffset.dy - _screenEdgePadding;

    final desiredH = _calcPopupHeight(itemCount);

    final openAbove =
        spaceBelow < desiredH + _triggerGap && spaceAbove > spaceBelow;

    final availableH = (openAbove ? spaceAbove : spaceBelow) - _triggerGap;
    final popupH = desiredH.clamp(
      _itemHeight,
      availableH.clamp(_itemHeight, double.infinity),
    );

    final followerOffset = openAbove
        ? Offset(0, -popupH - _triggerGap)
        : Offset(0, _triggerHeight + _triggerGap);

    return (
      popupH: popupH,
      followerOffset: followerOffset,
      openAbove: openAbove,
    );
  }

  void _openDropdown() {
    if (!widget.enabled || _isOpen) return;
    if (widget.items.isEmpty && widget.onEmpty != null) widget.onEmpty!();

    _searchController.clear();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;
    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlayBox == null) return;

    _triggerWidth = renderBox.size.width;
    _triggerHeight = renderBox.size.height;
    _triggerGlobalOffset = renderBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );

    final geoGuess = _computeGeometry(context, widget.items.length);

    _slide = Tween<Offset>(
      begin: Offset(0, geoGuess.openAbove ? 0.08 : -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward(from: 0);

    setState(() => _isOpen = true);

    _overlayEntry = OverlayEntry(builder: _buildOverlayContent);
    Overlay.of(context).insert(_overlayEntry!);
    _focusNode.requestFocus();
  }

  Widget _buildOverlayContent(BuildContext overlayContext) {
    final filtered = _filtered;
    final geo = _computeGeometry(overlayContext, filtered.length);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _closeDropdown(selected: null),
          ),
        ),

        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: true,
          offset: geo.followerOffset,
          child: Align(
            alignment: Alignment.topLeft,
            child: Material(
              color: Colors.transparent,
              child: SlideTransition(
                position: _slide,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  width: _triggerWidth,
                  height: geo.popupH,
                  decoration: BoxDecoration(
                    color: _colors.popupFillColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _colors.popupBorderColor),
                    boxShadow: [
                      BoxShadow(
                        color: _colors.popupShadowColor.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: filtered.isEmpty
                        ? Center(
                            child: widget.emptyBuilder != null
                                ? widget.emptyBuilder!(
                                    _searchController.text.trim(),
                                  )
                                : Text(
                                    widget.emptyText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _colors.hintTextColor,
                                    ),
                                  ),
                          )
                        : Scrollbar(
                            controller: _listScrollController,
                            thumbVisibility: filtered.length > _maxVisibleItems,
                            thickness: 3,
                            radius: const Radius.circular(8),
                            child: ListView(
                              controller: _listScrollController,
                              padding: const EdgeInsets.all(6),
                              children: filtered.map(_buildItem).toList(),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _closeDropdown({required T? selected}) {
    if (!_isOpen && _overlayEntry == null) return;

    _removeOverlay();
    _searchController.clear();
    _animController.reverse();

    if (!mounted) return;

    setState(() => _isOpen = false);

    _displayController.text = selected != null
        ? widget.itemLabel(selected)
        : (widget.value != null ? widget.itemLabel(widget.value as T) : '');

    _focusNode.unfocus();

    if (selected != null) {
      clearValidation();
      widget.onChanged?.call(selected);
    }
  }

  Widget _buildItem(T item) {
    final selected = _isSelected(item);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _closeDropdown(selected: item),
          splashColor: selected
              ? _colors.selectedItemSplashColor
              : _colors.itemSplashColor,
          highlightColor: selected
              ? _colors.selectedItemHighlightColor
              : _colors.itemHighlightColor,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: selected
                  ? _colors.selectedItemBackground
                  : Colors.transparent,
            ),
            child: SizedBox(
              height: _itemHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.itemLabel(item),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: selected
                              ? _colors.selectedItemTextColor
                              : _colors.itemTextColor,
                        ),
                      ),
                    ),
                    if (selected)
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

  Color get _activeBorderColor => _hasError
      ? (widget.errorOutline ?? _colors.errorBorderColor)
      : _colors.activeBorderColor;

  OutlineInputBorder _inputBorder(Color color, {double width = 1.0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  Widget _buildHelperOrErrorText() {
    final errorMessage = _getCurrentError();
    if (errorMessage != null && errorMessage.isNotEmpty) {
      final errorColor = widget.errorStyle?.color ?? _colors.errorTextColor;
      return Padding(
        padding: const EdgeInsets.only(top: 6, left: 14, right: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.useErrorIcon)
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 6),
                child: Icon(Icons.error_outline, size: 14, color: errorColor),
              )
            else
              const SizedBox.shrink(),
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
  void didUpdateWidget(covariant CustomSearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isOpen) {
      final newText = widget.value != null
          ? widget.itemLabel(widget.value as T)
          : '';
      if (_displayController.text != newText) {
        _displayController.text = newText;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOpen && _displayController.text.isEmpty && widget.value != null) {
      _displayController.text = widget.itemLabel(widget.value as T);
    }

    final errorColor = widget.errorOutline ?? _colors.errorBorderColor;
    final activeController = _isOpen ? _searchController : _displayController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 8),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: TextField(
            controller: activeController,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: !_isOpen,
            onTap: _openDropdown,
            style: TextStyle(fontSize: 16, color: _colors.valueTextColor),
            decoration: InputDecoration(
              hintText: _isOpen ? 'Cari...' : widget.hint,
              hintStyle: TextStyle(fontSize: 16, color: _colors.hintTextColor),
              prefixIcon: _isOpen
                  ? Icon(Icons.search, size: 20, color: _colors.searchIconColor)
                  : null,
              suffixIcon: AnimatedRotation(
                turns: _isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: _hasError ? errorColor : _colors.suffixIconColor,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              filled: true,
              fillColor: _colors.fillColor,
              border: _inputBorder(_colors.borderColor),
              enabledBorder: _inputBorder(
                _hasError ? errorColor : _colors.borderColor,
                width: _hasError ? 1.005 : 1.0,
              ),
              focusedBorder: _inputBorder(
                _hasError ? errorColor : _colors.activeBorderColor,
                width: _hasError ? 1.005 : 1.0,
              ),
              disabledBorder: _inputBorder(_colors.disabledBorderColor),
              errorBorder: _inputBorder(errorColor),
              focusedErrorBorder: _inputBorder(errorColor),
            ),
          ),
        ),
        _buildHelperOrErrorText(),
      ],
    );
  }
}
