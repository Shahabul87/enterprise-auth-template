import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Bottom sheet utility class
class BottomSheetUtils {
  BottomSheetUtils._();

  /// Show standard bottom sheet
  static Future<T?> showStandardBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = false,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    Clip? clipBehavior,
    Color? barrierColor,
    bool useSafeArea = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape:
          shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
      clipBehavior: clipBehavior,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
      builder: (context) => child,
    );
  }

  /// Show action sheet
  static Future<int?> showActionSheet({
    required BuildContext context,
    required String title,
    String? message,
    required List<ActionSheetItem> actions,
    bool showCancel = true,
    String cancelText = 'Cancel',
  }) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return showCupertinoModalPopup<int>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: Text(title),
          message: message != null ? Text(message) : null,
          actions: actions
              .map(
                (action) => CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(context, action.index),
                  isDestructiveAction: action.isDestructive,
                  child: Text(action.text),
                ),
              )
              .toList(),
          cancelButton: showCancel
              ? CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(context),
                  child: Text(cancelText),
                )
              : null,
        ),
      );
    }

    return showStandardBottomSheet<int>(
      context: context,
      child: ActionSheetTemplate(
        title: title,
        message: message,
        actions: actions,
        showCancel: showCancel,
        cancelText: cancelText,
      ),
    );
  }

  /// Show menu bottom sheet
  static Future<T?> showMenuBottomSheet<T>({
    required BuildContext context,
    required List<MenuSheetItem<T>> items,
    String? title,
    Widget? header,
  }) {
    return showStandardBottomSheet<T>(
      context: context,
      child: MenuBottomSheet<T>(items: items, title: title, header: header),
    );
  }

  /// Show filter bottom sheet
  static Future<Map<String, dynamic>?> showFilterBottomSheet({
    required BuildContext context,
    required String title,
    required List<FilterOption> options,
    Map<String, dynamic>? initialValues,
  }) {
    return showStandardBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      child: FilterBottomSheet(
        title: title,
        options: options,
        initialValues: initialValues ?? {},
      ),
    );
  }
}

/// Action sheet item model
class ActionSheetItem {
  final int index;
  final String text;
  final IconData? icon;
  final bool isDestructive;
  final VoidCallback? onTap;

  const ActionSheetItem({
    required this.index,
    required this.text,
    this.icon,
    this.isDestructive = false,
    this.onTap,
  });
}

/// Action sheet template widget
class ActionSheetTemplate extends StatelessWidget {
  final String title;
  final String? message;
  final List<ActionSheetItem> actions;
  final bool showCancel;
  final String cancelText;

  const ActionSheetTemplate({
    Key? key,
    required this.title,
    this.message,
    required this.actions,
    this.showCancel = true,
    this.cancelText = 'Cancel',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    message!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          ...actions.map(
            (action) => ListTile(
              leading: action.icon != null
                  ? Icon(
                      action.icon,
                      color: action.isDestructive
                          ? colorScheme.error
                          : colorScheme.onSurface,
                    )
                  : null,
              title: Text(
                action.text,
                style: TextStyle(
                  color: action.isDestructive
                      ? colorScheme.error
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context, action.index);
                action.onTap?.call();
              },
            ),
          ),
          if (showCancel) ...[
            const Divider(height: 1),
            ListTile(
              title: Text(
                cancelText,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ],
      ),
    );
  }
}

/// Menu sheet item model
class MenuSheetItem<T> {
  final T value;
  final String text;
  final IconData? icon;
  final Widget? trailing;
  final bool enabled;

  const MenuSheetItem({
    required this.value,
    required this.text,
    this.icon,
    this.trailing,
    this.enabled = true,
  });
}

/// Menu bottom sheet widget
class MenuBottomSheet<T> extends StatelessWidget {
  final List<MenuSheetItem<T>> items;
  final String? title;
  final Widget? header;

  const MenuBottomSheet({
    Key? key,
    required this.items,
    this.title,
    this.header,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (header != null) header!,
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  enabled: item.enabled,
                  leading: item.icon != null
                      ? Icon(
                          item.icon,
                          color: item.enabled
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.4),
                        )
                      : null,
                  title: Text(
                    item.text,
                    style: TextStyle(
                      color: item.enabled
                          ? colorScheme.onSurface
                          : colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  trailing: item.trailing,
                  onTap: item.enabled
                      ? () => Navigator.pop(context, item.value)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter option model
class FilterOption {
  final String key;
  final String label;
  final FilterType type;
  final dynamic defaultValue;
  final List<FilterChoice>? choices;
  final double? min;
  final double? max;

  const FilterOption({
    required this.key,
    required this.label,
    required this.type,
    this.defaultValue,
    this.choices,
    this.min,
    this.max,
  });
}

/// Filter type enum
enum FilterType { checkbox, radio, multiSelect, range, toggle }

/// Filter choice model
class FilterChoice {
  final dynamic value;
  final String label;

  const FilterChoice({required this.value, required this.label});
}

/// Filter bottom sheet widget
class FilterBottomSheet extends StatefulWidget {
  final String title;
  final List<FilterOption> options;
  final Map<String, dynamic> initialValues;

  const FilterBottomSheet({
    Key? key,
    required this.title,
    required this.options,
    required this.initialValues,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, dynamic> _values;

  @override
  void initState() {
    super.initState();
    _values = Map.from(widget.initialValues);

    // Initialize default values
    for (final option in widget.options) {
      if (!_values.containsKey(option.key) && option.defaultValue != null) {
        _values[option.key] = option.defaultValue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _values.clear();
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: widget.options.length,
                itemBuilder: (context, index) {
                  final option = widget.options[index];
                  return _buildFilterOption(option);
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, _values),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterOption(FilterOption option) {
    switch (option.type) {
      case FilterType.checkbox:
        return CheckboxListTile(
          title: Text(option.label),
          value: _values[option.key] ?? false,
          onChanged: (value) {
            setState(() {
              _values[option.key] = value;
            });
          },
        );

      case FilterType.toggle:
        return SwitchListTile(
          title: Text(option.label),
          value: _values[option.key] ?? false,
          onChanged: (value) {
            setState(() {
              _values[option.key] = value;
            });
          },
        );

      case FilterType.radio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                option.label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ...option.choices!.map(
              (choice) => RadioListTile(
                title: Text(choice.label),
                value: choice.value,
                groupValue: _values[option.key],
                onChanged: (value) {
                  setState(() {
                    _values[option.key] = value;
                  });
                },
              ),
            ),
          ],
        );

      case FilterType.multiSelect:
        final selectedValues = (_values[option.key] as List<dynamic>?) ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                option.label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Wrap(
              spacing: 8,
              children: option.choices!
                  .map(
                    (choice) => FilterChip(
                      label: Text(choice.label),
                      selected: selectedValues.contains(choice.value),
                      onSelected: (selected) {
                        setState(() {
                          final list = List<dynamic>.from(selectedValues);
                          if (selected) {
                            list.add(choice.value);
                          } else {
                            list.remove(choice.value);
                          }
                          _values[option.key] = list;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        );

      case FilterType.range:
        final value =
            (_values[option.key] as RangeValues?) ??
            RangeValues(option.min ?? 0, option.max ?? 100);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${option.label}: ${value.start.toInt()} - ${value.end.toInt()}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            RangeSlider(
              values: value,
              min: option.min ?? 0,
              max: option.max ?? 100,
              divisions: 20,
              labels: RangeLabels(
                value.start.toInt().toString(),
                value.end.toInt().toString(),
              ),
              onChanged: (values) {
                setState(() {
                  _values[option.key] = values;
                });
              },
            ),
          ],
        );
    }
  }
}
