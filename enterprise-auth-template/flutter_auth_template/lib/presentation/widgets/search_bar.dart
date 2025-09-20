import 'package:flutter/material.dart';
import 'dart:async';

/// Custom search bar widget with various features
class CustomSearchBar extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showClearButton;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Duration debounceTime;
  final bool enabled;
  final BoxDecoration? decoration;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  const CustomSearchBar({
    Key? key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.showClearButton = true,
    this.autofocus = false,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.search,
    this.debounceTime = const Duration(milliseconds: 300),
    this.enabled = true,
    this.decoration,
    this.padding,
    this.textStyle,
    this.hintStyle,
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _debounce;
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _showClear = _controller.text.isNotEmpty;
    });

    if (widget.onChanged != null) {
      _debounce?.cancel();
      _debounce = Timer(widget.debounceTime, () {
        widget.onChanged!(_controller.text);
      });
    }
  }

  void _clearSearch() {
    _controller.clear();
    widget.onClear?.call();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration:
          widget.decoration ??
          BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          widget.prefixIcon ??
              Icon(
                Icons.search,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              enabled: widget.enabled,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              style:
                  widget.textStyle ??
                  TextStyle(color: colorScheme.onSurface, fontSize: 16),
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Search...',
                hintStyle:
                    widget.hintStyle ??
                    TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: widget.onSubmitted,
              onTap: widget.onTap,
            ),
          ),
          if (widget.showClearButton && _showClear)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                size: 20,
              ),
              onPressed: _clearSearch,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            )
          else if (widget.suffixIcon != null)
            widget.suffixIcon!,
        ],
      ),
    );
  }
}

/// Search bar with suggestions
class SearchBarWithSuggestions<T> extends StatefulWidget {
  final String? hintText;
  final Future<List<T>> Function(String query) onSearch;
  final Widget Function(T item) itemBuilder;
  final void Function(T item)? onItemSelected;
  final Duration debounceTime;
  final int minSearchLength;
  final bool showLoader;
  final Widget? emptyWidget;
  final Widget? errorWidget;

  const SearchBarWithSuggestions({
    Key? key,
    this.hintText,
    required this.onSearch,
    required this.itemBuilder,
    this.onItemSelected,
    this.debounceTime = const Duration(milliseconds: 500),
    this.minSearchLength = 2,
    this.showLoader = true,
    this.emptyWidget,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<SearchBarWithSuggestions<T>> createState() =>
      _SearchBarWithSuggestionsState<T>();
}

class _SearchBarWithSuggestionsState<T>
    extends State<SearchBarWithSuggestions<T>> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  Timer? _debounce;
  bool _isLoading = false;
  List<T> _suggestions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  void _onTextChanged() {
    _debounce?.cancel();

    if (_controller.text.length < widget.minSearchLength) {
      _removeOverlay();
      return;
    }

    _debounce = Timer(widget.debounceTime, () {
      _performSearch(_controller.text);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await widget.onSearch(query);
      setState(() {
        _suggestions = results;
        _isLoading = false;
      });
      _showOverlay();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      _showOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 5),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildSuggestionsList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsList() {
    if (_isLoading && widget.showLoader) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_error != null) {
      return widget.errorWidget ??
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error: $_error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
    }

    if (_suggestions.isEmpty) {
      return widget.emptyWidget ??
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text('No results found'),
          );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final item = _suggestions[index];
        return InkWell(
          onTap: () {
            widget.onItemSelected?.call(item);
            _controller.clear();
            _removeOverlay();
            _focusNode.unfocus();
          },
          child: widget.itemBuilder(item),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: CustomSearchBar(
        controller: _controller,
        focusNode: _focusNode,
        hintText: widget.hintText,
        debounceTime: Duration.zero,
      ),
    );
  }
}

/// Expandable search bar
class ExpandableSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? hintText;
  final Duration animationDuration;

  const ExpandableSearchBar({
    Key? key,
    this.onChanged,
    this.onSubmitted,
    this.hintText,
    this.animationDuration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<ExpandableSearchBar> createState() => _ExpandableSearchBarState();
}

class _ExpandableSearchBarState extends State<ExpandableSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
        _focusNode.requestFocus();
      } else {
        _animationController.reverse();
        _focusNode.unfocus();
        _controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: _isExpanded ? 250 : 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _isExpanded ? Icons.close : Icons.search,
                  color: colorScheme.onSurface,
                ),
                onPressed: _toggleSearch,
              ),
              if (_isExpanded)
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: widget.hintText ?? 'Search...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(right: 12),
                    ),
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
