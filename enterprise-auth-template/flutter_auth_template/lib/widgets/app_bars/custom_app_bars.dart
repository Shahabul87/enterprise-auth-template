import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom app bar with various configurations
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;
  final double? toolbarHeight;
  final PreferredSizeWidget? bottom;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool transparent;
  final Gradient? gradient;
  final double? titleSpacing;
  final TextStyle? titleTextStyle;
  final IconThemeData? iconTheme;
  final IconThemeData? actionsIconTheme;

  const CustomAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = false,
    this.toolbarHeight,
    this.bottom,
    this.systemOverlayStyle,
    this.transparent = false,
    this.gradient,
    this.titleSpacing,
    this.titleTextStyle,
    this.iconTheme,
    this.actionsIconTheme,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(
    (toolbarHeight ?? kToolbarHeight) + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget appBar = AppBar(
      title: titleWidget ?? (title != null ? Text(title!) : null),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: transparent ? Colors.transparent : backgroundColor,
      foregroundColor: foregroundColor,
      elevation: transparent ? 0 : elevation,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      bottom: bottom,
      systemOverlayStyle: systemOverlayStyle,
      titleSpacing: titleSpacing,
      titleTextStyle: titleTextStyle,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
    );

    if (gradient != null) {
      appBar = Container(
        decoration: BoxDecoration(gradient: gradient),
        child: appBar,
      );
    }

    return appBar;
  }
}

/// Sliver app bar with advanced features
class CustomSliverAppBar extends StatelessWidget {
  final String? title;
  final Widget? flexibleSpace;
  final List<Widget>? actions;
  final Widget? leading;
  final bool floating;
  final bool pinned;
  final bool snap;
  final double expandedHeight;
  final double? collapsedHeight;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? backgroundImage;
  final Widget? background;
  final bool stretch;
  final double? stretchTriggerOffset;
  final VoidCallback? onStretchTrigger;
  final PreferredSizeWidget? bottom;

  const CustomSliverAppBar({
    Key? key,
    this.title,
    this.flexibleSpace,
    this.actions,
    this.leading,
    this.floating = false,
    this.pinned = true,
    this.snap = false,
    this.expandedHeight = 200.0,
    this.collapsedHeight,
    this.backgroundColor,
    this.foregroundColor,
    this.backgroundImage,
    this.background,
    this.stretch = false,
    this.stretchTriggerOffset,
    this.onStretchTrigger,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      title: title != null ? Text(title!) : null,
      actions: actions,
      leading: leading,
      floating: floating,
      pinned: pinned,
      snap: snap,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      stretch: stretch,
      stretchTriggerOffset: stretchTriggerOffset ?? 100.0,
      onStretchTrigger: onStretchTrigger != null
          ? () async {
              onStretchTrigger!();
            }
          : null,
      bottom: bottom,
      flexibleSpace:
          flexibleSpace ??
          (backgroundImage != null || background != null
              ? FlexibleSpaceBar(
                  title: title != null ? Text(title!) : null,
                  background:
                      background ??
                      Image.network(backgroundImage!, fit: BoxFit.cover),
                  stretchModes: stretch
                      ? const [
                          StretchMode.zoomBackground,
                          StretchMode.blurBackground,
                          StretchMode.fadeTitle,
                        ]
                      : const [],
                )
              : null),
    );
  }
}

/// Search app bar
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final String searchHint;
  final ValueChanged<String>? onSearch;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? searchBackgroundColor;
  final bool autoFocus;
  final TextEditingController? controller;

  const SearchAppBar({
    Key? key,
    this.title,
    this.searchHint = 'Search...',
    this.onSearch,
    this.onChanged,
    this.onClear,
    this.actions,
    this.backgroundColor,
    this.searchBackgroundColor,
    this.autoFocus = false,
    this.controller,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  late TextEditingController _controller;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _controller.clear();
      widget.onClear?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: widget.backgroundColor,
      title: _isSearching
          ? Container(
              height: 40,
              decoration: BoxDecoration(
                color:
                    widget.searchBackgroundColor ??
                    colorScheme.surface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _controller,
                autofocus: widget.autoFocus,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      widget.onClear?.call();
                    },
                  ),
                ),
                style: TextStyle(color: colorScheme.onSurface),
                onChanged: widget.onChanged,
                onSubmitted: widget.onSearch,
              ),
            )
          : Text(widget.title ?? 'Search'),
      actions: [
        if (!_isSearching)
          IconButton(icon: const Icon(Icons.search), onPressed: _startSearch),
        if (_isSearching)
          IconButton(icon: const Icon(Icons.close), onPressed: _stopSearch),
        ...?widget.actions,
      ],
    );
  }
}

/// Profile app bar with user info
class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? userName;
  final String? userEmail;
  final String? avatarUrl;
  final Widget? avatar;
  final VoidCallback? onProfileTap;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? elevation;
  final Widget? subtitle;

  const ProfileAppBar({
    Key? key,
    this.userName,
    this.userEmail,
    this.avatarUrl,
    this.avatar,
    this.onProfileTap,
    this.actions,
    this.backgroundColor,
    this.elevation,
    this.subtitle,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      toolbarHeight: kToolbarHeight + 20,
      title: InkWell(
        onTap: onProfileTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              avatar ??
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl!)
                        : null,
                    backgroundColor: colorScheme.primary,
                    child: avatarUrl == null
                        ? Text(
                            userName?.substring(0, 1).toUpperCase() ?? 'U',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (userName != null)
                      Text(
                        userName!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (subtitle != null)
                      subtitle!
                    else if (userEmail != null)
                      Text(
                        userEmail!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (onProfileTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
      actions: actions,
    );
  }
}

/// Tabbed app bar
class TabbedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Tab> tabs;
  final TabController? controller;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final bool isScrollable;
  final EdgeInsetsGeometry? indicatorPadding;
  final TabBarIndicatorSize? indicatorSize;

  const TabbedAppBar({
    Key? key,
    this.title,
    required this.tabs,
    this.controller,
    this.actions,
    this.backgroundColor,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.isScrollable = false,
    this.indicatorPadding,
    this.indicatorSize,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (tabs.isNotEmpty ? 46.0 : 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: title != null ? Text(title!) : null,
      actions: actions,
      backgroundColor: backgroundColor,
      bottom: tabs.isNotEmpty
          ? TabBar(
              controller: controller,
              tabs: tabs,
              isScrollable: isScrollable,
              indicatorColor: indicatorColor ?? colorScheme.primary,
              labelColor: labelColor ?? colorScheme.primary,
              unselectedLabelColor:
                  unselectedLabelColor ??
                  colorScheme.onSurface.withValues(alpha: 0.6),
              indicatorPadding: indicatorPadding ?? EdgeInsets.zero,
              indicatorSize: indicatorSize,
            )
          : null,
    );
  }
}

/// Collapsible app bar with animation
class CollapsibleAppBar extends StatefulWidget {
  final String title;
  final String? collapsedTitle;
  final Widget? expandedContent;
  final List<Widget>? actions;
  final double expandedHeight;
  final Color? backgroundColor;
  final Color? expandedBackgroundColor;
  final Widget? background;

  const CollapsibleAppBar({
    Key? key,
    required this.title,
    this.collapsedTitle,
    this.expandedContent,
    this.actions,
    this.expandedHeight = 200.0,
    this.backgroundColor,
    this.expandedBackgroundColor,
    this.background,
  }) : super(key: key);

  @override
  State<CollapsibleAppBar> createState() => _CollapsibleAppBarState();
}

class _CollapsibleAppBarState extends State<CollapsibleAppBar> {
  ScrollController? _scrollController;
  double _scrollOffset = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController = PrimaryScrollController.of(context);
    _scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController?.offset ?? 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final collapsed = _scrollOffset > widget.expandedHeight - kToolbarHeight;

    return SliverAppBar(
      expandedHeight: widget.expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: collapsed
          ? widget.backgroundColor
          : widget.expandedBackgroundColor ?? Colors.transparent,
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: collapsed ? 1.0 : 0.0,
        child: Text(widget.collapsedTitle ?? widget.title),
      ),
      actions: widget.actions,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.background != null) widget.background!,
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: collapsed ? 0.0 : 1.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.expandedContent != null) widget.expandedContent!,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
