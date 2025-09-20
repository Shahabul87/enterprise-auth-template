import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Avatar widget with fallback support
class AvatarComponent extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final Widget? badge;
  final VoidCallback? onTap;
  final bool showInitials;
  final TextStyle? initialsTextStyle;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BoxFit imageFit;

  const AvatarComponent({
    Key? key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.border,
    this.badge,
    this.onTap,
    this.showInitials = true,
    this.initialsTextStyle,
    this.placeholder,
    this.errorWidget,
    this.imageFit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor =
        backgroundColor ??
        _generateColorFromName(name ?? '') ??
        colorScheme.primary;

    final fgColor = foregroundColor ?? _getContrastingColor(bgColor);

    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Network image with caching
      if (imageUrl!.startsWith('http')) {
        avatar = CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: imageFit,
          placeholder: (context, url) => _buildFallback(bgColor, fgColor),
          errorWidget: (context, url, error) =>
              errorWidget ?? _buildFallback(bgColor, fgColor),
        );
      } else {
        // Local asset image
        avatar = Image.asset(
          imageUrl!,
          fit: imageFit,
          errorBuilder: (context, error, stackTrace) =>
              errorWidget ?? _buildFallback(bgColor, fgColor),
        );
      }
    } else {
      avatar = _buildFallback(bgColor, fgColor);
    }

    Widget result = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
        border: border,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatar,
    );

    // Add badge if provided
    if (badge != null) {
      result = Stack(
        children: [
          result,
          Positioned(right: 0, bottom: 0, child: badge!),
        ],
      );
    }

    // Add tap handler if provided
    if (onTap != null) {
      result = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(size / 2),
        child: result,
      );
    }

    return result;
  }

  Widget _buildFallback(Color bgColor, Color fgColor) {
    if (placeholder != null) {
      return placeholder!;
    }

    if (showInitials && name != null && name!.isNotEmpty) {
      return Center(
        child: Text(
          _getInitials(name!),
          style:
              initialsTextStyle ??
              TextStyle(
                color: fgColor,
                fontSize: size * 0.4,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
    }

    return Icon(Icons.person, color: fgColor, size: size * 0.6);
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';

    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return '${parts[0].substring(0, 1)}${parts[parts.length - 1].substring(0, 1)}'
        .toUpperCase();
  }

  Color? _generateColorFromName(String name) {
    if (name.isEmpty) return null;

    final colors = [
      Colors.red.shade400,
      Colors.pink.shade400,
      Colors.purple.shade400,
      Colors.deepPurple.shade400,
      Colors.indigo.shade400,
      Colors.blue.shade400,
      Colors.lightBlue.shade400,
      Colors.cyan.shade400,
      Colors.teal.shade400,
      Colors.green.shade400,
      Colors.lightGreen.shade400,
      Colors.lime.shade600,
      Colors.amber.shade600,
      Colors.orange.shade400,
      Colors.deepOrange.shade400,
    ];

    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }

    return colors[hash.abs() % colors.length];
  }

  Color _getContrastingColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

/// Avatar group widget for showing multiple avatars
class AvatarGroup extends StatelessWidget {
  final List<String?> imageUrls;
  final List<String?> names;
  final double size;
  final double overlap;
  final int maxAvatars;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final TextStyle? overflowTextStyle;

  const AvatarGroup({
    Key? key,
    required this.imageUrls,
    this.names = const [],
    this.size = 40,
    this.overlap = 0.6,
    this.maxAvatars = 3,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2,
    this.onTap,
    this.overflowTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final displayCount = imageUrls.length > maxAvatars
        ? maxAvatars
        : imageUrls.length;
    final overflowCount = imageUrls.length - displayCount;

    List<Widget> avatars = [];

    for (int i = 0; i < displayCount; i++) {
      avatars.add(
        Positioned(
          left: i * (size * overlap),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor ?? colorScheme.surface,
                width: borderWidth,
              ),
            ),
            child: AvatarComponent(
              imageUrl: imageUrls[i],
              name: i < names.length ? names[i] : null,
              size: size,
            ),
          ),
        ),
      );
    }

    if (overflowCount > 0) {
      avatars.add(
        Positioned(
          left: displayCount * (size * overlap),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: backgroundColor ?? colorScheme.surfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(
                color: borderColor ?? colorScheme.surface,
                width: borderWidth,
              ),
            ),
            child: Center(
              child: Text(
                '+$overflowCount',
                style:
                    overflowTextStyle ??
                    TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: size * 0.35,
                    ),
              ),
            ),
          ),
        ),
      );
    }

    Widget result = SizedBox(
      width:
          (displayCount + (overflowCount > 0 ? 1 : 0)) * (size * overlap) +
          (size * (1 - overlap)),
      height: size,
      child: Stack(children: avatars.reversed.toList()),
    );

    if (onTap != null) {
      result = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: result,
      );
    }

    return result;
  }
}

/// Status indicator for avatar
class AvatarStatusIndicator extends StatelessWidget {
  final Widget child;
  final bool isOnline;
  final Color? onlineColor;
  final Color? offlineColor;
  final double indicatorSize;
  final Alignment alignment;

  const AvatarStatusIndicator({
    Key? key,
    required this.child,
    required this.isOnline,
    this.onlineColor,
    this.offlineColor,
    this.indicatorSize = 12,
    this.alignment = Alignment.bottomRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: Container(
              width: indicatorSize,
              height: indicatorSize,
              decoration: BoxDecoration(
                color: isOnline
                    ? (onlineColor ?? Colors.green)
                    : (offlineColor ?? Colors.grey),
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.surface, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Avatar with edit button
class EditableAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final VoidCallback? onEdit;
  final Widget? editIcon;
  final Color? editButtonColor;

  const EditableAvatar({
    Key? key,
    this.imageUrl,
    this.name,
    this.size = 100,
    this.onEdit,
    this.editIcon,
    this.editButtonColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        AvatarComponent(imageUrl: imageUrl, name: name, size: size),
        if (onEdit != null)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: editButtonColor ?? colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
              child: IconButton(
                icon:
                    editIcon ??
                    Icon(
                      Icons.camera_alt,
                      color: colorScheme.onPrimary,
                      size: size * 0.2,
                    ),
                onPressed: onEdit,
                padding: EdgeInsets.all(size * 0.05),
                constraints: BoxConstraints(
                  minWidth: size * 0.3,
                  minHeight: size * 0.3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
