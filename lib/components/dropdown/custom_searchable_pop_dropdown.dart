import 'package:flutter/material.dart';
import 'dropdown_color_scheme.dart';

class CustomSearchablePopDropdown<T> extends StatefulWidget {
  final String? label;
  final String hint;
  final T? value;
  final List<T> items;
  final ValueChanged<T?>? onChanged;
  final String Function(T) itemLabel;
  final bool Function(T, T)? compareItems;
  final bool enabled;

  final List<int> disabledIndexes;

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

  final Widget Function(String query)? emptyBuilder;

  final DropdownColorScheme? colorScheme;

  final void Function(String query)? onSearch;
  final bool isLoading;
  final void Function()? onLoadMore;
  final bool hasMore;

  final String searchHint;

  final int minSearchLength;

  final String? minSearchLengthHint;

  const CustomSearchablePopDropdown({
    super.key,
    this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
    this.compareItems,
    this.enabled = true,
    this.disabledIndexes = const [],
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
    this.onSearch,
    this.isLoading = false,
    this.onLoadMore,
    this.hasMore = false,
    this.searchHint = 'Cari...',
    this.minSearchLength = 0,
    this.minSearchLengthHint,
  });

  @override
  State<CustomSearchablePopDropdown<T>> createState() =>
      _CustomSearchableDropdownState<T>();
}

class _CustomSearchableDropdownState<T>
    extends State<CustomSearchablePopDropdown<T>>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const double _itemHeight = 46.0;
  static const int _maxVisibleItems = 5;
  static const double _searchBarHeight = 52.0;
  static const double _verticalPadding = 12.0;
  static const double _screenEdgePadding = 16.0;
  static const double _triggerGap = 10.0;

  final LayerLink _layerLink = LayerLink();
  final ScrollController _listScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late AnimationController _animController;
  late Animation<Offset> _slide;

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _isOpening = false;

  double _triggerWidth = 0;
  double _triggerHeight = 0;
  Offset _triggerGlobalOffset = Offset.zero;

  String? _validationError;

  DropdownColorScheme get _colors =>
      widget.colorScheme ?? DropdownColorScheme.defaults();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _searchController.addListener(_onQueryChanged);
    _listScrollController.addListener(_onListScroll);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.removeListener(_onQueryChanged);
    _listScrollController.removeListener(_onListScroll);
    _safeRemoveOverlay();
    _listScrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    if (!_isOpen || _overlayEntry == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_isOpen || _overlayEntry == null) return;
      final renderBox = context.findRenderObject() as RenderBox?;
      final overlayBox =
          Overlay.of(context).context.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.attached && overlayBox != null) {
        _triggerWidth = renderBox.size.width;
        _triggerHeight = renderBox.size.height;
        _triggerGlobalOffset = renderBox.localToGlobal(
          Offset.zero,
          ancestor: overlayBox,
        );
      }
      _overlayEntry!.markNeedsBuild();
    });
  }

  void _onListScroll() {
    if (widget.onLoadMore == null || !widget.hasMore) return;
    if (_listScrollController.position.pixels >=
        _listScrollController.position.maxScrollExtent - 80) {
      widget.onLoadMore!();
    }
  }

  void _onQueryChanged() {
    final query = _searchController.text.trim();

    if (widget.onSearch != null) {
      if (widget.minSearchLength > 0 &&
          query.isNotEmpty &&
          query.length < widget.minSearchLength) {
        if (_overlayEntry != null && mounted) _overlayEntry!.markNeedsBuild();
        return;
      }
      widget.onSearch!(query);
    }

    if (_overlayEntry != null && mounted) {
      _overlayEntry!.markNeedsBuild();
    }
  }

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

  bool _isDisabled(T item) {
    if (widget.disabledIndexes.isEmpty) return false;
    final originalIndex = widget.items.indexOf(item);
    return originalIndex != -1 &&
        widget.disabledIndexes.contains(originalIndex);
  }

  List<T> get _filtered {
    if (widget.onSearch != null) return widget.items;
    final query = _searchController.text.trim();
    if (query.isEmpty) return widget.items;
    return widget.items.where((item) {
      if (widget.customFilter != null) return widget.customFilter!(item, query);
      return widget.itemLabel(item).toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  double _calcPopupHeight({required double maxH}) {
    final filtered = _filtered;

    if (widget.isLoading && filtered.isEmpty) {
      return (_searchBarHeight + _itemHeight + _verticalPadding).clamp(
        _searchBarHeight + _itemHeight,
        maxH,
      );
    }

    if (filtered.isEmpty) {
      return (_searchBarHeight + _itemHeight + _verticalPadding).clamp(
        _searchBarHeight + _itemHeight,
        maxH,
      );
    }

    final visibleCount = filtered.length.clamp(1, _maxVisibleItems);
    final listH = _itemHeight * visibleCount + _verticalPadding;
    return (_searchBarHeight + listH).clamp(
      _searchBarHeight + _itemHeight,
      maxH,
    );
  }

  ({double popupH, Offset followerOffset, bool openAbove}) _computeGeometry(
    BuildContext overlayContext,
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

    final maxPossibleH =
        _searchBarHeight + (_itemHeight * _maxVisibleItems) + _verticalPadding;

    final openAbove =
        spaceBelow < maxPossibleH + _triggerGap && spaceAbove > spaceBelow;

    final maxH = (openAbove ? spaceAbove : spaceBelow) - _triggerGap;
    final clampedMaxH = maxH.clamp(
      _searchBarHeight + _itemHeight,
      double.infinity,
    );

    final popupH = _calcPopupHeight(maxH: clampedMaxH);

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
    if (!widget.enabled || _isOpen || _isOpening) return;
    _isOpening = true;

    if (widget.items.isEmpty && widget.onEmpty != null) widget.onEmpty!();

    _searchController.clear();
    if (widget.onSearch != null) widget.onSearch!('');

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) {
      _isOpening = false;
      return;
    }

    final overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlayBox == null) {
      _isOpening = false;
      return;
    }

    final size = renderBox.size;
    _triggerWidth = size.width;
    _triggerHeight = size.height;
    _triggerGlobalOffset = renderBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );

    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final keyboardH = mediaQuery.viewInsets.bottom;
    final bottomPadding = mediaQuery.padding.bottom;
    final spaceBelow =
        screenHeight -
        (_triggerGlobalOffset.dy + _triggerHeight) -
        _screenEdgePadding -
        bottomPadding -
        keyboardH;
    final spaceAbove = _triggerGlobalOffset.dy - _screenEdgePadding;
    final maxPossibleH =
        _searchBarHeight + (_itemHeight * _maxVisibleItems) + _verticalPadding;
    final initialOpenAbove =
        spaceBelow < maxPossibleH + _triggerGap && spaceAbove > spaceBelow;

    _slide = Tween<Offset>(
      begin: Offset(0, initialOpenAbove ? 0.06 : -0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward(from: 0);

    setState(() => _isOpen = true);

    _safeRemoveOverlay();
    _overlayEntry = OverlayEntry(builder: _buildOverlayContent);
    Overlay.of(context).insert(_overlayEntry!);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isOpen) _searchFocusNode.requestFocus();
      _isOpening = false;
    });
  }

  void _closeDropdown({required T? selected}) {
    if (!mounted) return;
    if (!_isOpen && _overlayEntry == null) return;

    _animController.reverse();
    _safeRemoveOverlay();
    _searchController.clear();

    if (!mounted) return;
    setState(() => _isOpen = false);

    _searchFocusNode.unfocus();

    if (selected != null) {
      clearValidation();
      widget.onChanged?.call(selected);
    }
  }

  void _safeRemoveOverlay() {
    try {
      _overlayEntry?.remove();
    } catch (_) {}
    _overlayEntry = null;
  }

  Widget _buildOverlayContent(BuildContext overlayContext) {
    final geo = _computeGeometry(overlayContext);

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
          showWhenUnlinked: false,
          offset: geo.followerOffset,
          child: Align(
            alignment: Alignment.topLeft,
            child: SlideTransition(
              position: _slide,
              child: Material(
                color: Colors.transparent,
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSearchBar(),
                        Expanded(child: _buildListContent()),
                      ],
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: TextStyle(fontSize: 14, color: _colors.valueTextColor),
        decoration: InputDecoration(
          hintText: widget.searchHint,
          hintStyle: TextStyle(fontSize: 14, color: _colors.hintTextColor),
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: _colors.searchIconColor,
          ),
          suffixIcon: widget.isLoading
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _colors.activeBorderColor,
                      ),
                    ),
                  ),
                )
              : _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 16,
                    color: _colors.hintTextColor,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    if (widget.onSearch != null) widget.onSearch!('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          filled: true,
          fillColor: _colors.fillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _colors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _colors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: _colors.activeBorderColor),
          ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildListContent() {
    final filtered = _filtered;
    final query = _searchController.text.trim();

    if (widget.minSearchLength > 0 &&
        query.isNotEmpty &&
        query.length < widget.minSearchLength) {
      final remaining = widget.minSearchLength - query.length;
      final guideText =
          widget.minSearchLengthHint ??
          'Ketik $remaining karakter lagi untuk mencari';
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            guideText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _colors.hintTextColor),
          ),
        ),
      );
    }

    if (widget.minSearchLength > 0 &&
        query.isEmpty &&
        filtered.isEmpty &&
        !widget.isLoading) {
      final guideText =
          widget.minSearchLengthHint ??
          'Ketik minimal ${widget.minSearchLength} karakter untuk mencari';
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            guideText,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _colors.hintTextColor),
          ),
        ),
      );
    }

    if (widget.isLoading && filtered.isEmpty) {
      return Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(
              _colors.activeBorderColor,
            ),
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      if (widget.emptyBuilder != null) {
        return widget.emptyBuilder!(query);
      }
      return Center(
        child: Text(
          widget.emptyText,
          style: TextStyle(fontSize: 14, color: _colors.hintTextColor),
        ),
      );
    }

    return Scrollbar(
      controller: _listScrollController,
      thumbVisibility: filtered.length > _maxVisibleItems,
      thickness: 3,
      radius: const Radius.circular(8),
      child: ListView.builder(
        controller: _listScrollController,
        padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
        itemCount:
            filtered.length + (widget.isLoading && filtered.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filtered.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          return _buildItem(filtered[index]);
        },
      ),
    );
  }

  Widget _buildItem(T item) {
    final selected = _isSelected(item);
    final disabled = _isDisabled(item);

    final textColor = disabled
        ? _colors.hintTextColor.withValues(alpha: 0.5)
        : selected
        ? _colors.selectedItemTextColor
        : _colors.itemTextColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: disabled ? null : () => _closeDropdown(selected: item),
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
                          color: textColor,
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
  void didUpdateWidget(covariant CustomSearchablePopDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isOpen && _overlayEntry != null) {
      if (oldWidget.items != widget.items ||
          oldWidget.isLoading != widget.isLoading ||
          oldWidget.disabledIndexes != widget.disabledIndexes ||
          oldWidget.emptyBuilder != widget.emptyBuilder) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _isOpen && _overlayEntry != null) {
            _overlayEntry!.markNeedsBuild();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = widget.errorOutline ?? _colors.errorBorderColor;

    final currentValue = widget.value != null
        ? widget.itemLabel(widget.value as T)
        : '';

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
          child: GestureDetector(
            onTap: _openDropdown,
            child: Container(
              decoration: BoxDecoration(
                color: widget.enabled
                    ? _colors.fillColor
                    : _colors.fillColor.withValues(alpha: 0.6),
                border: Border.all(
                  color: _hasError
                      ? errorColor
                      : _isOpen
                      ? _colors.activeBorderColor
                      : _colors.borderColor,
                  width: _hasError ? 1.005 : 1.0,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      currentValue.isEmpty ? widget.hint : currentValue,
                      style: TextStyle(
                        fontSize: 16,
                        color: currentValue.isEmpty
                            ? _colors.hintTextColor
                            : _colors.valueTextColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: _hasError ? errorColor : _colors.suffixIconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _buildHelperOrErrorText(),
      ],
    );
  }
}
