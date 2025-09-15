// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NotificationMessage _$NotificationMessageFromJson(Map<String, dynamic> json) {
  return _NotificationMessage.fromJson(json);
}

/// @nodoc
mixin _$NotificationMessage {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  NotificationPriority get priority => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get readAt => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  List<NotificationAction>? get actions => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get deepLink => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  bool get isPersistent => throw _privateConstructorUsedError;

  /// Serializes this NotificationMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationMessageCopyWith<NotificationMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationMessageCopyWith<$Res> {
  factory $NotificationMessageCopyWith(
    NotificationMessage value,
    $Res Function(NotificationMessage) then,
  ) = _$NotificationMessageCopyWithImpl<$Res, NotificationMessage>;
  @useResult
  $Res call({
    String id,
    String title,
    String content,
    NotificationType type,
    NotificationPriority priority,
    DateTime createdAt,
    DateTime? readAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
    List<NotificationAction>? actions,
    String? imageUrl,
    String? deepLink,
    bool isRead,
    bool isPersistent,
  });
}

/// @nodoc
class _$NotificationMessageCopyWithImpl<$Res, $Val extends NotificationMessage>
    implements $NotificationMessageCopyWith<$Res> {
  _$NotificationMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? type = null,
    Object? priority = null,
    Object? createdAt = null,
    Object? readAt = freezed,
    Object? expiresAt = freezed,
    Object? metadata = freezed,
    Object? actions = freezed,
    Object? imageUrl = freezed,
    Object? deepLink = freezed,
    Object? isRead = null,
    Object? isPersistent = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NotificationType,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as NotificationPriority,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            readAt: freezed == readAt
                ? _value.readAt
                : readAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            actions: freezed == actions
                ? _value.actions
                : actions // ignore: cast_nullable_to_non_nullable
                      as List<NotificationAction>?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            deepLink: freezed == deepLink
                ? _value.deepLink
                : deepLink // ignore: cast_nullable_to_non_nullable
                      as String?,
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            isPersistent: null == isPersistent
                ? _value.isPersistent
                : isPersistent // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationMessageImplCopyWith<$Res>
    implements $NotificationMessageCopyWith<$Res> {
  factory _$$NotificationMessageImplCopyWith(
    _$NotificationMessageImpl value,
    $Res Function(_$NotificationMessageImpl) then,
  ) = __$$NotificationMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String content,
    NotificationType type,
    NotificationPriority priority,
    DateTime createdAt,
    DateTime? readAt,
    DateTime? expiresAt,
    Map<String, dynamic>? metadata,
    List<NotificationAction>? actions,
    String? imageUrl,
    String? deepLink,
    bool isRead,
    bool isPersistent,
  });
}

/// @nodoc
class __$$NotificationMessageImplCopyWithImpl<$Res>
    extends _$NotificationMessageCopyWithImpl<$Res, _$NotificationMessageImpl>
    implements _$$NotificationMessageImplCopyWith<$Res> {
  __$$NotificationMessageImplCopyWithImpl(
    _$NotificationMessageImpl _value,
    $Res Function(_$NotificationMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? type = null,
    Object? priority = null,
    Object? createdAt = null,
    Object? readAt = freezed,
    Object? expiresAt = freezed,
    Object? metadata = freezed,
    Object? actions = freezed,
    Object? imageUrl = freezed,
    Object? deepLink = freezed,
    Object? isRead = null,
    Object? isPersistent = null,
  }) {
    return _then(
      _$NotificationMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NotificationType,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as NotificationPriority,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        readAt: freezed == readAt
            ? _value.readAt
            : readAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        actions: freezed == actions
            ? _value._actions
            : actions // ignore: cast_nullable_to_non_nullable
                  as List<NotificationAction>?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        deepLink: freezed == deepLink
            ? _value.deepLink
            : deepLink // ignore: cast_nullable_to_non_nullable
                  as String?,
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        isPersistent: null == isPersistent
            ? _value.isPersistent
            : isPersistent // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationMessageImpl implements _NotificationMessage {
  const _$NotificationMessageImpl({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.readAt,
    this.expiresAt,
    final Map<String, dynamic>? metadata,
    final List<NotificationAction>? actions,
    this.imageUrl,
    this.deepLink,
    this.isRead = false,
    this.isPersistent = false,
  }) : _metadata = metadata,
       _actions = actions;

  factory _$NotificationMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationMessageImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String content;
  @override
  final NotificationType type;
  @override
  final NotificationPriority priority;
  @override
  final DateTime createdAt;
  @override
  final DateTime? readAt;
  @override
  final DateTime? expiresAt;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<NotificationAction>? _actions;
  @override
  List<NotificationAction>? get actions {
    final value = _actions;
    if (value == null) return null;
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? imageUrl;
  @override
  final String? deepLink;
  @override
  @JsonKey()
  final bool isRead;
  @override
  @JsonKey()
  final bool isPersistent;

  @override
  String toString() {
    return 'NotificationMessage(id: $id, title: $title, content: $content, type: $type, priority: $priority, createdAt: $createdAt, readAt: $readAt, expiresAt: $expiresAt, metadata: $metadata, actions: $actions, imageUrl: $imageUrl, deepLink: $deepLink, isRead: $isRead, isPersistent: $isPersistent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.deepLink, deepLink) ||
                other.deepLink == deepLink) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.isPersistent, isPersistent) ||
                other.isPersistent == isPersistent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    content,
    type,
    priority,
    createdAt,
    readAt,
    expiresAt,
    const DeepCollectionEquality().hash(_metadata),
    const DeepCollectionEquality().hash(_actions),
    imageUrl,
    deepLink,
    isRead,
    isPersistent,
  );

  /// Create a copy of NotificationMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationMessageImplCopyWith<_$NotificationMessageImpl> get copyWith =>
      __$$NotificationMessageImplCopyWithImpl<_$NotificationMessageImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationMessageImplToJson(this);
  }
}

abstract class _NotificationMessage implements NotificationMessage {
  const factory _NotificationMessage({
    required final String id,
    required final String title,
    required final String content,
    required final NotificationType type,
    required final NotificationPriority priority,
    required final DateTime createdAt,
    final DateTime? readAt,
    final DateTime? expiresAt,
    final Map<String, dynamic>? metadata,
    final List<NotificationAction>? actions,
    final String? imageUrl,
    final String? deepLink,
    final bool isRead,
    final bool isPersistent,
  }) = _$NotificationMessageImpl;

  factory _NotificationMessage.fromJson(Map<String, dynamic> json) =
      _$NotificationMessageImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get content;
  @override
  NotificationType get type;
  @override
  NotificationPriority get priority;
  @override
  DateTime get createdAt;
  @override
  DateTime? get readAt;
  @override
  DateTime? get expiresAt;
  @override
  Map<String, dynamic>? get metadata;
  @override
  List<NotificationAction>? get actions;
  @override
  String? get imageUrl;
  @override
  String? get deepLink;
  @override
  bool get isRead;
  @override
  bool get isPersistent;

  /// Create a copy of NotificationMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationMessageImplCopyWith<_$NotificationMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationAction _$NotificationActionFromJson(Map<String, dynamic> json) {
  return _NotificationAction.fromJson(json);
}

/// @nodoc
mixin _$NotificationAction {
  String get id => throw _privateConstructorUsedError;
  String get label => throw _privateConstructorUsedError;
  NotificationActionType get type => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  Map<String, dynamic>? get payload => throw _privateConstructorUsedError;

  /// Serializes this NotificationAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationActionCopyWith<NotificationAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationActionCopyWith<$Res> {
  factory $NotificationActionCopyWith(
    NotificationAction value,
    $Res Function(NotificationAction) then,
  ) = _$NotificationActionCopyWithImpl<$Res, NotificationAction>;
  @useResult
  $Res call({
    String id,
    String label,
    NotificationActionType type,
    String? url,
    Map<String, dynamic>? payload,
  });
}

/// @nodoc
class _$NotificationActionCopyWithImpl<$Res, $Val extends NotificationAction>
    implements $NotificationActionCopyWith<$Res> {
  _$NotificationActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? type = null,
    Object? url = freezed,
    Object? payload = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            label: null == label
                ? _value.label
                : label // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NotificationActionType,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
            payload: freezed == payload
                ? _value.payload
                : payload // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationActionImplCopyWith<$Res>
    implements $NotificationActionCopyWith<$Res> {
  factory _$$NotificationActionImplCopyWith(
    _$NotificationActionImpl value,
    $Res Function(_$NotificationActionImpl) then,
  ) = __$$NotificationActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String label,
    NotificationActionType type,
    String? url,
    Map<String, dynamic>? payload,
  });
}

/// @nodoc
class __$$NotificationActionImplCopyWithImpl<$Res>
    extends _$NotificationActionCopyWithImpl<$Res, _$NotificationActionImpl>
    implements _$$NotificationActionImplCopyWith<$Res> {
  __$$NotificationActionImplCopyWithImpl(
    _$NotificationActionImpl _value,
    $Res Function(_$NotificationActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? label = null,
    Object? type = null,
    Object? url = freezed,
    Object? payload = freezed,
  }) {
    return _then(
      _$NotificationActionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        label: null == label
            ? _value.label
            : label // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NotificationActionType,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
        payload: freezed == payload
            ? _value._payload
            : payload // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationActionImpl implements _NotificationAction {
  const _$NotificationActionImpl({
    required this.id,
    required this.label,
    required this.type,
    this.url,
    final Map<String, dynamic>? payload,
  }) : _payload = payload;

  factory _$NotificationActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationActionImplFromJson(json);

  @override
  final String id;
  @override
  final String label;
  @override
  final NotificationActionType type;
  @override
  final String? url;
  final Map<String, dynamic>? _payload;
  @override
  Map<String, dynamic>? get payload {
    final value = _payload;
    if (value == null) return null;
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'NotificationAction(id: $id, label: $label, type: $type, url: $url, payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.url, url) || other.url == url) &&
            const DeepCollectionEquality().equals(other._payload, _payload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    label,
    type,
    url,
    const DeepCollectionEquality().hash(_payload),
  );

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationActionImplCopyWith<_$NotificationActionImpl> get copyWith =>
      __$$NotificationActionImplCopyWithImpl<_$NotificationActionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationActionImplToJson(this);
  }
}

abstract class _NotificationAction implements NotificationAction {
  const factory _NotificationAction({
    required final String id,
    required final String label,
    required final NotificationActionType type,
    final String? url,
    final Map<String, dynamic>? payload,
  }) = _$NotificationActionImpl;

  factory _NotificationAction.fromJson(Map<String, dynamic> json) =
      _$NotificationActionImpl.fromJson;

  @override
  String get id;
  @override
  String get label;
  @override
  NotificationActionType get type;
  @override
  String? get url;
  @override
  Map<String, dynamic>? get payload;

  /// Create a copy of NotificationAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationActionImplCopyWith<_$NotificationActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationTemplate _$NotificationTemplateFromJson(Map<String, dynamic> json) {
  return _NotificationTemplate.fromJson(json);
}

/// @nodoc
mixin _$NotificationTemplate {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  String get titleTemplate => throw _privateConstructorUsedError;
  String get contentTemplate => throw _privateConstructorUsedError;
  NotificationPriority? get defaultPriority =>
      throw _privateConstructorUsedError;
  List<NotificationAction>? get defaultActions =>
      throw _privateConstructorUsedError;
  Map<String, String>? get variables => throw _privateConstructorUsedError;
  NotificationChannelSettings? get channelSettings =>
      throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationTemplateCopyWith<NotificationTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationTemplateCopyWith<$Res> {
  factory $NotificationTemplateCopyWith(
    NotificationTemplate value,
    $Res Function(NotificationTemplate) then,
  ) = _$NotificationTemplateCopyWithImpl<$Res, NotificationTemplate>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    NotificationType type,
    String titleTemplate,
    String contentTemplate,
    NotificationPriority? defaultPriority,
    List<NotificationAction>? defaultActions,
    Map<String, String>? variables,
    NotificationChannelSettings? channelSettings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  $NotificationChannelSettingsCopyWith<$Res>? get channelSettings;
}

/// @nodoc
class _$NotificationTemplateCopyWithImpl<
  $Res,
  $Val extends NotificationTemplate
>
    implements $NotificationTemplateCopyWith<$Res> {
  _$NotificationTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? titleTemplate = null,
    Object? contentTemplate = null,
    Object? defaultPriority = freezed,
    Object? defaultActions = freezed,
    Object? variables = freezed,
    Object? channelSettings = freezed,
    Object? isActive = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NotificationType,
            titleTemplate: null == titleTemplate
                ? _value.titleTemplate
                : titleTemplate // ignore: cast_nullable_to_non_nullable
                      as String,
            contentTemplate: null == contentTemplate
                ? _value.contentTemplate
                : contentTemplate // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultPriority: freezed == defaultPriority
                ? _value.defaultPriority
                : defaultPriority // ignore: cast_nullable_to_non_nullable
                      as NotificationPriority?,
            defaultActions: freezed == defaultActions
                ? _value.defaultActions
                : defaultActions // ignore: cast_nullable_to_non_nullable
                      as List<NotificationAction>?,
            variables: freezed == variables
                ? _value.variables
                : variables // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>?,
            channelSettings: freezed == channelSettings
                ? _value.channelSettings
                : channelSettings // ignore: cast_nullable_to_non_nullable
                      as NotificationChannelSettings?,
            isActive: freezed == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of NotificationTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NotificationChannelSettingsCopyWith<$Res>? get channelSettings {
    if (_value.channelSettings == null) {
      return null;
    }

    return $NotificationChannelSettingsCopyWith<$Res>(_value.channelSettings!, (
      value,
    ) {
      return _then(_value.copyWith(channelSettings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NotificationTemplateImplCopyWith<$Res>
    implements $NotificationTemplateCopyWith<$Res> {
  factory _$$NotificationTemplateImplCopyWith(
    _$NotificationTemplateImpl value,
    $Res Function(_$NotificationTemplateImpl) then,
  ) = __$$NotificationTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    NotificationType type,
    String titleTemplate,
    String contentTemplate,
    NotificationPriority? defaultPriority,
    List<NotificationAction>? defaultActions,
    Map<String, String>? variables,
    NotificationChannelSettings? channelSettings,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  @override
  $NotificationChannelSettingsCopyWith<$Res>? get channelSettings;
}

/// @nodoc
class __$$NotificationTemplateImplCopyWithImpl<$Res>
    extends _$NotificationTemplateCopyWithImpl<$Res, _$NotificationTemplateImpl>
    implements _$$NotificationTemplateImplCopyWith<$Res> {
  __$$NotificationTemplateImplCopyWithImpl(
    _$NotificationTemplateImpl _value,
    $Res Function(_$NotificationTemplateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? type = null,
    Object? titleTemplate = null,
    Object? contentTemplate = null,
    Object? defaultPriority = freezed,
    Object? defaultActions = freezed,
    Object? variables = freezed,
    Object? channelSettings = freezed,
    Object? isActive = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$NotificationTemplateImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NotificationType,
        titleTemplate: null == titleTemplate
            ? _value.titleTemplate
            : titleTemplate // ignore: cast_nullable_to_non_nullable
                  as String,
        contentTemplate: null == contentTemplate
            ? _value.contentTemplate
            : contentTemplate // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultPriority: freezed == defaultPriority
            ? _value.defaultPriority
            : defaultPriority // ignore: cast_nullable_to_non_nullable
                  as NotificationPriority?,
        defaultActions: freezed == defaultActions
            ? _value._defaultActions
            : defaultActions // ignore: cast_nullable_to_non_nullable
                  as List<NotificationAction>?,
        variables: freezed == variables
            ? _value._variables
            : variables // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>?,
        channelSettings: freezed == channelSettings
            ? _value.channelSettings
            : channelSettings // ignore: cast_nullable_to_non_nullable
                  as NotificationChannelSettings?,
        isActive: freezed == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationTemplateImpl implements _NotificationTemplate {
  const _$NotificationTemplateImpl({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.titleTemplate,
    required this.contentTemplate,
    this.defaultPriority,
    final List<NotificationAction>? defaultActions,
    final Map<String, String>? variables,
    this.channelSettings,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  }) : _defaultActions = defaultActions,
       _variables = variables;

  factory _$NotificationTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationTemplateImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final NotificationType type;
  @override
  final String titleTemplate;
  @override
  final String contentTemplate;
  @override
  final NotificationPriority? defaultPriority;
  final List<NotificationAction>? _defaultActions;
  @override
  List<NotificationAction>? get defaultActions {
    final value = _defaultActions;
    if (value == null) return null;
    if (_defaultActions is EqualUnmodifiableListView) return _defaultActions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final Map<String, String>? _variables;
  @override
  Map<String, String>? get variables {
    final value = _variables;
    if (value == null) return null;
    if (_variables is EqualUnmodifiableMapView) return _variables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final NotificationChannelSettings? channelSettings;
  @override
  final bool? isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'NotificationTemplate(id: $id, name: $name, description: $description, type: $type, titleTemplate: $titleTemplate, contentTemplate: $contentTemplate, defaultPriority: $defaultPriority, defaultActions: $defaultActions, variables: $variables, channelSettings: $channelSettings, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.titleTemplate, titleTemplate) ||
                other.titleTemplate == titleTemplate) &&
            (identical(other.contentTemplate, contentTemplate) ||
                other.contentTemplate == contentTemplate) &&
            (identical(other.defaultPriority, defaultPriority) ||
                other.defaultPriority == defaultPriority) &&
            const DeepCollectionEquality().equals(
              other._defaultActions,
              _defaultActions,
            ) &&
            const DeepCollectionEquality().equals(
              other._variables,
              _variables,
            ) &&
            (identical(other.channelSettings, channelSettings) ||
                other.channelSettings == channelSettings) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    type,
    titleTemplate,
    contentTemplate,
    defaultPriority,
    const DeepCollectionEquality().hash(_defaultActions),
    const DeepCollectionEquality().hash(_variables),
    channelSettings,
    isActive,
    createdAt,
    updatedAt,
  );

  /// Create a copy of NotificationTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationTemplateImplCopyWith<_$NotificationTemplateImpl>
  get copyWith =>
      __$$NotificationTemplateImplCopyWithImpl<_$NotificationTemplateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationTemplateImplToJson(this);
  }
}

abstract class _NotificationTemplate implements NotificationTemplate {
  const factory _NotificationTemplate({
    required final String id,
    required final String name,
    required final String description,
    required final NotificationType type,
    required final String titleTemplate,
    required final String contentTemplate,
    final NotificationPriority? defaultPriority,
    final List<NotificationAction>? defaultActions,
    final Map<String, String>? variables,
    final NotificationChannelSettings? channelSettings,
    final bool? isActive,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$NotificationTemplateImpl;

  factory _NotificationTemplate.fromJson(Map<String, dynamic> json) =
      _$NotificationTemplateImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  NotificationType get type;
  @override
  String get titleTemplate;
  @override
  String get contentTemplate;
  @override
  NotificationPriority? get defaultPriority;
  @override
  List<NotificationAction>? get defaultActions;
  @override
  Map<String, String>? get variables;
  @override
  NotificationChannelSettings? get channelSettings;
  @override
  bool? get isActive;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of NotificationTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationTemplateImplCopyWith<_$NotificationTemplateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

NotificationChannelSettings _$NotificationChannelSettingsFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationChannelSettings.fromJson(json);
}

/// @nodoc
mixin _$NotificationChannelSettings {
  bool get inApp => throw _privateConstructorUsedError;
  bool get email => throw _privateConstructorUsedError;
  bool get sms => throw _privateConstructorUsedError;
  bool get push => throw _privateConstructorUsedError;
  bool get webhook => throw _privateConstructorUsedError;
  String? get webhookUrl => throw _privateConstructorUsedError;
  Map<String, dynamic>? get emailSettings => throw _privateConstructorUsedError;
  Map<String, dynamic>? get smsSettings => throw _privateConstructorUsedError;
  Map<String, dynamic>? get pushSettings => throw _privateConstructorUsedError;

  /// Serializes this NotificationChannelSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationChannelSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationChannelSettingsCopyWith<NotificationChannelSettings>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationChannelSettingsCopyWith<$Res> {
  factory $NotificationChannelSettingsCopyWith(
    NotificationChannelSettings value,
    $Res Function(NotificationChannelSettings) then,
  ) =
      _$NotificationChannelSettingsCopyWithImpl<
        $Res,
        NotificationChannelSettings
      >;
  @useResult
  $Res call({
    bool inApp,
    bool email,
    bool sms,
    bool push,
    bool webhook,
    String? webhookUrl,
    Map<String, dynamic>? emailSettings,
    Map<String, dynamic>? smsSettings,
    Map<String, dynamic>? pushSettings,
  });
}

/// @nodoc
class _$NotificationChannelSettingsCopyWithImpl<
  $Res,
  $Val extends NotificationChannelSettings
>
    implements $NotificationChannelSettingsCopyWith<$Res> {
  _$NotificationChannelSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationChannelSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inApp = null,
    Object? email = null,
    Object? sms = null,
    Object? push = null,
    Object? webhook = null,
    Object? webhookUrl = freezed,
    Object? emailSettings = freezed,
    Object? smsSettings = freezed,
    Object? pushSettings = freezed,
  }) {
    return _then(
      _value.copyWith(
            inApp: null == inApp
                ? _value.inApp
                : inApp // ignore: cast_nullable_to_non_nullable
                      as bool,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as bool,
            sms: null == sms
                ? _value.sms
                : sms // ignore: cast_nullable_to_non_nullable
                      as bool,
            push: null == push
                ? _value.push
                : push // ignore: cast_nullable_to_non_nullable
                      as bool,
            webhook: null == webhook
                ? _value.webhook
                : webhook // ignore: cast_nullable_to_non_nullable
                      as bool,
            webhookUrl: freezed == webhookUrl
                ? _value.webhookUrl
                : webhookUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            emailSettings: freezed == emailSettings
                ? _value.emailSettings
                : emailSettings // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            smsSettings: freezed == smsSettings
                ? _value.smsSettings
                : smsSettings // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            pushSettings: freezed == pushSettings
                ? _value.pushSettings
                : pushSettings // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationChannelSettingsImplCopyWith<$Res>
    implements $NotificationChannelSettingsCopyWith<$Res> {
  factory _$$NotificationChannelSettingsImplCopyWith(
    _$NotificationChannelSettingsImpl value,
    $Res Function(_$NotificationChannelSettingsImpl) then,
  ) = __$$NotificationChannelSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool inApp,
    bool email,
    bool sms,
    bool push,
    bool webhook,
    String? webhookUrl,
    Map<String, dynamic>? emailSettings,
    Map<String, dynamic>? smsSettings,
    Map<String, dynamic>? pushSettings,
  });
}

/// @nodoc
class __$$NotificationChannelSettingsImplCopyWithImpl<$Res>
    extends
        _$NotificationChannelSettingsCopyWithImpl<
          $Res,
          _$NotificationChannelSettingsImpl
        >
    implements _$$NotificationChannelSettingsImplCopyWith<$Res> {
  __$$NotificationChannelSettingsImplCopyWithImpl(
    _$NotificationChannelSettingsImpl _value,
    $Res Function(_$NotificationChannelSettingsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationChannelSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? inApp = null,
    Object? email = null,
    Object? sms = null,
    Object? push = null,
    Object? webhook = null,
    Object? webhookUrl = freezed,
    Object? emailSettings = freezed,
    Object? smsSettings = freezed,
    Object? pushSettings = freezed,
  }) {
    return _then(
      _$NotificationChannelSettingsImpl(
        inApp: null == inApp
            ? _value.inApp
            : inApp // ignore: cast_nullable_to_non_nullable
                  as bool,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as bool,
        sms: null == sms
            ? _value.sms
            : sms // ignore: cast_nullable_to_non_nullable
                  as bool,
        push: null == push
            ? _value.push
            : push // ignore: cast_nullable_to_non_nullable
                  as bool,
        webhook: null == webhook
            ? _value.webhook
            : webhook // ignore: cast_nullable_to_non_nullable
                  as bool,
        webhookUrl: freezed == webhookUrl
            ? _value.webhookUrl
            : webhookUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        emailSettings: freezed == emailSettings
            ? _value._emailSettings
            : emailSettings // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        smsSettings: freezed == smsSettings
            ? _value._smsSettings
            : smsSettings // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        pushSettings: freezed == pushSettings
            ? _value._pushSettings
            : pushSettings // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationChannelSettingsImpl
    implements _NotificationChannelSettings {
  const _$NotificationChannelSettingsImpl({
    this.inApp = true,
    this.email = false,
    this.sms = false,
    this.push = false,
    this.webhook = false,
    this.webhookUrl,
    final Map<String, dynamic>? emailSettings,
    final Map<String, dynamic>? smsSettings,
    final Map<String, dynamic>? pushSettings,
  }) : _emailSettings = emailSettings,
       _smsSettings = smsSettings,
       _pushSettings = pushSettings;

  factory _$NotificationChannelSettingsImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$NotificationChannelSettingsImplFromJson(json);

  @override
  @JsonKey()
  final bool inApp;
  @override
  @JsonKey()
  final bool email;
  @override
  @JsonKey()
  final bool sms;
  @override
  @JsonKey()
  final bool push;
  @override
  @JsonKey()
  final bool webhook;
  @override
  final String? webhookUrl;
  final Map<String, dynamic>? _emailSettings;
  @override
  Map<String, dynamic>? get emailSettings {
    final value = _emailSettings;
    if (value == null) return null;
    if (_emailSettings is EqualUnmodifiableMapView) return _emailSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _smsSettings;
  @override
  Map<String, dynamic>? get smsSettings {
    final value = _smsSettings;
    if (value == null) return null;
    if (_smsSettings is EqualUnmodifiableMapView) return _smsSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _pushSettings;
  @override
  Map<String, dynamic>? get pushSettings {
    final value = _pushSettings;
    if (value == null) return null;
    if (_pushSettings is EqualUnmodifiableMapView) return _pushSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'NotificationChannelSettings(inApp: $inApp, email: $email, sms: $sms, push: $push, webhook: $webhook, webhookUrl: $webhookUrl, emailSettings: $emailSettings, smsSettings: $smsSettings, pushSettings: $pushSettings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationChannelSettingsImpl &&
            (identical(other.inApp, inApp) || other.inApp == inApp) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.sms, sms) || other.sms == sms) &&
            (identical(other.push, push) || other.push == push) &&
            (identical(other.webhook, webhook) || other.webhook == webhook) &&
            (identical(other.webhookUrl, webhookUrl) ||
                other.webhookUrl == webhookUrl) &&
            const DeepCollectionEquality().equals(
              other._emailSettings,
              _emailSettings,
            ) &&
            const DeepCollectionEquality().equals(
              other._smsSettings,
              _smsSettings,
            ) &&
            const DeepCollectionEquality().equals(
              other._pushSettings,
              _pushSettings,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    inApp,
    email,
    sms,
    push,
    webhook,
    webhookUrl,
    const DeepCollectionEquality().hash(_emailSettings),
    const DeepCollectionEquality().hash(_smsSettings),
    const DeepCollectionEquality().hash(_pushSettings),
  );

  /// Create a copy of NotificationChannelSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationChannelSettingsImplCopyWith<_$NotificationChannelSettingsImpl>
  get copyWith =>
      __$$NotificationChannelSettingsImplCopyWithImpl<
        _$NotificationChannelSettingsImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationChannelSettingsImplToJson(this);
  }
}

abstract class _NotificationChannelSettings
    implements NotificationChannelSettings {
  const factory _NotificationChannelSettings({
    final bool inApp,
    final bool email,
    final bool sms,
    final bool push,
    final bool webhook,
    final String? webhookUrl,
    final Map<String, dynamic>? emailSettings,
    final Map<String, dynamic>? smsSettings,
    final Map<String, dynamic>? pushSettings,
  }) = _$NotificationChannelSettingsImpl;

  factory _NotificationChannelSettings.fromJson(Map<String, dynamic> json) =
      _$NotificationChannelSettingsImpl.fromJson;

  @override
  bool get inApp;
  @override
  bool get email;
  @override
  bool get sms;
  @override
  bool get push;
  @override
  bool get webhook;
  @override
  String? get webhookUrl;
  @override
  Map<String, dynamic>? get emailSettings;
  @override
  Map<String, dynamic>? get smsSettings;
  @override
  Map<String, dynamic>? get pushSettings;

  /// Create a copy of NotificationChannelSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationChannelSettingsImplCopyWith<_$NotificationChannelSettingsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationPreferences.fromJson(json);
}

/// @nodoc
mixin _$NotificationPreferences {
  String get userId => throw _privateConstructorUsedError;
  bool get globalEnabled => throw _privateConstructorUsedError;
  Map<NotificationType, NotificationChannelSettings>? get typeSettings =>
      throw _privateConstructorUsedError;
  Map<NotificationPriority, bool>? get prioritySettings =>
      throw _privateConstructorUsedError;
  List<String>? get mutedCategories => throw _privateConstructorUsedError;
  bool get soundEnabled => throw _privateConstructorUsedError;
  bool get vibrationEnabled => throw _privateConstructorUsedError;
  String get quietHoursStart => throw _privateConstructorUsedError;
  String get quietHoursEnd => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPreferencesCopyWith<NotificationPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPreferencesCopyWith<$Res> {
  factory $NotificationPreferencesCopyWith(
    NotificationPreferences value,
    $Res Function(NotificationPreferences) then,
  ) = _$NotificationPreferencesCopyWithImpl<$Res, NotificationPreferences>;
  @useResult
  $Res call({
    String userId,
    bool globalEnabled,
    Map<NotificationType, NotificationChannelSettings>? typeSettings,
    Map<NotificationPriority, bool>? prioritySettings,
    List<String>? mutedCategories,
    bool soundEnabled,
    bool vibrationEnabled,
    String quietHoursStart,
    String quietHoursEnd,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$NotificationPreferencesCopyWithImpl<
  $Res,
  $Val extends NotificationPreferences
>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? globalEnabled = null,
    Object? typeSettings = freezed,
    Object? prioritySettings = freezed,
    Object? mutedCategories = freezed,
    Object? soundEnabled = null,
    Object? vibrationEnabled = null,
    Object? quietHoursStart = null,
    Object? quietHoursEnd = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            globalEnabled: null == globalEnabled
                ? _value.globalEnabled
                : globalEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            typeSettings: freezed == typeSettings
                ? _value.typeSettings
                : typeSettings // ignore: cast_nullable_to_non_nullable
                      as Map<NotificationType, NotificationChannelSettings>?,
            prioritySettings: freezed == prioritySettings
                ? _value.prioritySettings
                : prioritySettings // ignore: cast_nullable_to_non_nullable
                      as Map<NotificationPriority, bool>?,
            mutedCategories: freezed == mutedCategories
                ? _value.mutedCategories
                : mutedCategories // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            soundEnabled: null == soundEnabled
                ? _value.soundEnabled
                : soundEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            vibrationEnabled: null == vibrationEnabled
                ? _value.vibrationEnabled
                : vibrationEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            quietHoursStart: null == quietHoursStart
                ? _value.quietHoursStart
                : quietHoursStart // ignore: cast_nullable_to_non_nullable
                      as String,
            quietHoursEnd: null == quietHoursEnd
                ? _value.quietHoursEnd
                : quietHoursEnd // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationPreferencesImplCopyWith<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  factory _$$NotificationPreferencesImplCopyWith(
    _$NotificationPreferencesImpl value,
    $Res Function(_$NotificationPreferencesImpl) then,
  ) = __$$NotificationPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    bool globalEnabled,
    Map<NotificationType, NotificationChannelSettings>? typeSettings,
    Map<NotificationPriority, bool>? prioritySettings,
    List<String>? mutedCategories,
    bool soundEnabled,
    bool vibrationEnabled,
    String quietHoursStart,
    String quietHoursEnd,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$NotificationPreferencesImplCopyWithImpl<$Res>
    extends
        _$NotificationPreferencesCopyWithImpl<
          $Res,
          _$NotificationPreferencesImpl
        >
    implements _$$NotificationPreferencesImplCopyWith<$Res> {
  __$$NotificationPreferencesImplCopyWithImpl(
    _$NotificationPreferencesImpl _value,
    $Res Function(_$NotificationPreferencesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? globalEnabled = null,
    Object? typeSettings = freezed,
    Object? prioritySettings = freezed,
    Object? mutedCategories = freezed,
    Object? soundEnabled = null,
    Object? vibrationEnabled = null,
    Object? quietHoursStart = null,
    Object? quietHoursEnd = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$NotificationPreferencesImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        globalEnabled: null == globalEnabled
            ? _value.globalEnabled
            : globalEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        typeSettings: freezed == typeSettings
            ? _value._typeSettings
            : typeSettings // ignore: cast_nullable_to_non_nullable
                  as Map<NotificationType, NotificationChannelSettings>?,
        prioritySettings: freezed == prioritySettings
            ? _value._prioritySettings
            : prioritySettings // ignore: cast_nullable_to_non_nullable
                  as Map<NotificationPriority, bool>?,
        mutedCategories: freezed == mutedCategories
            ? _value._mutedCategories
            : mutedCategories // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        soundEnabled: null == soundEnabled
            ? _value.soundEnabled
            : soundEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        vibrationEnabled: null == vibrationEnabled
            ? _value.vibrationEnabled
            : vibrationEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        quietHoursStart: null == quietHoursStart
            ? _value.quietHoursStart
            : quietHoursStart // ignore: cast_nullable_to_non_nullable
                  as String,
        quietHoursEnd: null == quietHoursEnd
            ? _value.quietHoursEnd
            : quietHoursEnd // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPreferencesImpl implements _NotificationPreferences {
  const _$NotificationPreferencesImpl({
    required this.userId,
    this.globalEnabled = true,
    final Map<NotificationType, NotificationChannelSettings>? typeSettings,
    final Map<NotificationPriority, bool>? prioritySettings,
    final List<String>? mutedCategories,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.quietHoursStart = '08:00',
    this.quietHoursEnd = '22:00',
    this.updatedAt,
  }) : _typeSettings = typeSettings,
       _prioritySettings = prioritySettings,
       _mutedCategories = mutedCategories;

  factory _$NotificationPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationPreferencesImplFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final bool globalEnabled;
  final Map<NotificationType, NotificationChannelSettings>? _typeSettings;
  @override
  Map<NotificationType, NotificationChannelSettings>? get typeSettings {
    final value = _typeSettings;
    if (value == null) return null;
    if (_typeSettings is EqualUnmodifiableMapView) return _typeSettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<NotificationPriority, bool>? _prioritySettings;
  @override
  Map<NotificationPriority, bool>? get prioritySettings {
    final value = _prioritySettings;
    if (value == null) return null;
    if (_prioritySettings is EqualUnmodifiableMapView) return _prioritySettings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String>? _mutedCategories;
  @override
  List<String>? get mutedCategories {
    final value = _mutedCategories;
    if (value == null) return null;
    if (_mutedCategories is EqualUnmodifiableListView) return _mutedCategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool soundEnabled;
  @override
  @JsonKey()
  final bool vibrationEnabled;
  @override
  @JsonKey()
  final String quietHoursStart;
  @override
  @JsonKey()
  final String quietHoursEnd;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'NotificationPreferences(userId: $userId, globalEnabled: $globalEnabled, typeSettings: $typeSettings, prioritySettings: $prioritySettings, mutedCategories: $mutedCategories, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled, quietHoursStart: $quietHoursStart, quietHoursEnd: $quietHoursEnd, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPreferencesImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.globalEnabled, globalEnabled) ||
                other.globalEnabled == globalEnabled) &&
            const DeepCollectionEquality().equals(
              other._typeSettings,
              _typeSettings,
            ) &&
            const DeepCollectionEquality().equals(
              other._prioritySettings,
              _prioritySettings,
            ) &&
            const DeepCollectionEquality().equals(
              other._mutedCategories,
              _mutedCategories,
            ) &&
            (identical(other.soundEnabled, soundEnabled) ||
                other.soundEnabled == soundEnabled) &&
            (identical(other.vibrationEnabled, vibrationEnabled) ||
                other.vibrationEnabled == vibrationEnabled) &&
            (identical(other.quietHoursStart, quietHoursStart) ||
                other.quietHoursStart == quietHoursStart) &&
            (identical(other.quietHoursEnd, quietHoursEnd) ||
                other.quietHoursEnd == quietHoursEnd) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    globalEnabled,
    const DeepCollectionEquality().hash(_typeSettings),
    const DeepCollectionEquality().hash(_prioritySettings),
    const DeepCollectionEquality().hash(_mutedCategories),
    soundEnabled,
    vibrationEnabled,
    quietHoursStart,
    quietHoursEnd,
    updatedAt,
  );

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPreferencesImplCopyWith<_$NotificationPreferencesImpl>
  get copyWith =>
      __$$NotificationPreferencesImplCopyWithImpl<
        _$NotificationPreferencesImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPreferencesImplToJson(this);
  }
}

abstract class _NotificationPreferences implements NotificationPreferences {
  const factory _NotificationPreferences({
    required final String userId,
    final bool globalEnabled,
    final Map<NotificationType, NotificationChannelSettings>? typeSettings,
    final Map<NotificationPriority, bool>? prioritySettings,
    final List<String>? mutedCategories,
    final bool soundEnabled,
    final bool vibrationEnabled,
    final String quietHoursStart,
    final String quietHoursEnd,
    final DateTime? updatedAt,
  }) = _$NotificationPreferencesImpl;

  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) =
      _$NotificationPreferencesImpl.fromJson;

  @override
  String get userId;
  @override
  bool get globalEnabled;
  @override
  Map<NotificationType, NotificationChannelSettings>? get typeSettings;
  @override
  Map<NotificationPriority, bool>? get prioritySettings;
  @override
  List<String>? get mutedCategories;
  @override
  bool get soundEnabled;
  @override
  bool get vibrationEnabled;
  @override
  String get quietHoursStart;
  @override
  String get quietHoursEnd;
  @override
  DateTime? get updatedAt;

  /// Create a copy of NotificationPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPreferencesImplCopyWith<_$NotificationPreferencesImpl>
  get copyWith => throw _privateConstructorUsedError;
}

NotificationBatch _$NotificationBatchFromJson(Map<String, dynamic> json) {
  return _NotificationBatch.fromJson(json);
}

/// @nodoc
mixin _$NotificationBatch {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  List<String> get recipients => throw _privateConstructorUsedError;
  NotificationTemplate get template => throw _privateConstructorUsedError;
  Map<String, dynamic> get variables => throw _privateConstructorUsedError;
  NotificationBatchStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;
  int get successCount => throw _privateConstructorUsedError;
  int get failureCount => throw _privateConstructorUsedError;
  List<NotificationDeliveryResult>? get results =>
      throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this NotificationBatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationBatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationBatchCopyWith<NotificationBatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationBatchCopyWith<$Res> {
  factory $NotificationBatchCopyWith(
    NotificationBatch value,
    $Res Function(NotificationBatch) then,
  ) = _$NotificationBatchCopyWithImpl<$Res, NotificationBatch>;
  @useResult
  $Res call({
    String id,
    String title,
    List<String> recipients,
    NotificationTemplate template,
    Map<String, dynamic> variables,
    NotificationBatchStatus status,
    DateTime createdAt,
    DateTime? scheduledAt,
    DateTime? completedAt,
    int totalCount,
    int successCount,
    int failureCount,
    List<NotificationDeliveryResult>? results,
    String? errorMessage,
  });

  $NotificationTemplateCopyWith<$Res> get template;
}

/// @nodoc
class _$NotificationBatchCopyWithImpl<$Res, $Val extends NotificationBatch>
    implements $NotificationBatchCopyWith<$Res> {
  _$NotificationBatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationBatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? recipients = null,
    Object? template = null,
    Object? variables = null,
    Object? status = null,
    Object? createdAt = null,
    Object? scheduledAt = freezed,
    Object? completedAt = freezed,
    Object? totalCount = null,
    Object? successCount = null,
    Object? failureCount = null,
    Object? results = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            recipients: null == recipients
                ? _value.recipients
                : recipients // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            template: null == template
                ? _value.template
                : template // ignore: cast_nullable_to_non_nullable
                      as NotificationTemplate,
            variables: null == variables
                ? _value.variables
                : variables // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as NotificationBatchStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            scheduledAt: freezed == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
            successCount: null == successCount
                ? _value.successCount
                : successCount // ignore: cast_nullable_to_non_nullable
                      as int,
            failureCount: null == failureCount
                ? _value.failureCount
                : failureCount // ignore: cast_nullable_to_non_nullable
                      as int,
            results: freezed == results
                ? _value.results
                : results // ignore: cast_nullable_to_non_nullable
                      as List<NotificationDeliveryResult>?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of NotificationBatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NotificationTemplateCopyWith<$Res> get template {
    return $NotificationTemplateCopyWith<$Res>(_value.template, (value) {
      return _then(_value.copyWith(template: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NotificationBatchImplCopyWith<$Res>
    implements $NotificationBatchCopyWith<$Res> {
  factory _$$NotificationBatchImplCopyWith(
    _$NotificationBatchImpl value,
    $Res Function(_$NotificationBatchImpl) then,
  ) = __$$NotificationBatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    List<String> recipients,
    NotificationTemplate template,
    Map<String, dynamic> variables,
    NotificationBatchStatus status,
    DateTime createdAt,
    DateTime? scheduledAt,
    DateTime? completedAt,
    int totalCount,
    int successCount,
    int failureCount,
    List<NotificationDeliveryResult>? results,
    String? errorMessage,
  });

  @override
  $NotificationTemplateCopyWith<$Res> get template;
}

/// @nodoc
class __$$NotificationBatchImplCopyWithImpl<$Res>
    extends _$NotificationBatchCopyWithImpl<$Res, _$NotificationBatchImpl>
    implements _$$NotificationBatchImplCopyWith<$Res> {
  __$$NotificationBatchImplCopyWithImpl(
    _$NotificationBatchImpl _value,
    $Res Function(_$NotificationBatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationBatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? recipients = null,
    Object? template = null,
    Object? variables = null,
    Object? status = null,
    Object? createdAt = null,
    Object? scheduledAt = freezed,
    Object? completedAt = freezed,
    Object? totalCount = null,
    Object? successCount = null,
    Object? failureCount = null,
    Object? results = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$NotificationBatchImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        recipients: null == recipients
            ? _value._recipients
            : recipients // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        template: null == template
            ? _value.template
            : template // ignore: cast_nullable_to_non_nullable
                  as NotificationTemplate,
        variables: null == variables
            ? _value._variables
            : variables // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as NotificationBatchStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        scheduledAt: freezed == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
        successCount: null == successCount
            ? _value.successCount
            : successCount // ignore: cast_nullable_to_non_nullable
                  as int,
        failureCount: null == failureCount
            ? _value.failureCount
            : failureCount // ignore: cast_nullable_to_non_nullable
                  as int,
        results: freezed == results
            ? _value._results
            : results // ignore: cast_nullable_to_non_nullable
                  as List<NotificationDeliveryResult>?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationBatchImpl implements _NotificationBatch {
  const _$NotificationBatchImpl({
    required this.id,
    required this.title,
    required final List<String> recipients,
    required this.template,
    required final Map<String, dynamic> variables,
    required this.status,
    required this.createdAt,
    this.scheduledAt,
    this.completedAt,
    this.totalCount = 0,
    this.successCount = 0,
    this.failureCount = 0,
    final List<NotificationDeliveryResult>? results,
    this.errorMessage,
  }) : _recipients = recipients,
       _variables = variables,
       _results = results;

  factory _$NotificationBatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationBatchImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  final List<String> _recipients;
  @override
  List<String> get recipients {
    if (_recipients is EqualUnmodifiableListView) return _recipients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recipients);
  }

  @override
  final NotificationTemplate template;
  final Map<String, dynamic> _variables;
  @override
  Map<String, dynamic> get variables {
    if (_variables is EqualUnmodifiableMapView) return _variables;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_variables);
  }

  @override
  final NotificationBatchStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime? scheduledAt;
  @override
  final DateTime? completedAt;
  @override
  @JsonKey()
  final int totalCount;
  @override
  @JsonKey()
  final int successCount;
  @override
  @JsonKey()
  final int failureCount;
  final List<NotificationDeliveryResult>? _results;
  @override
  List<NotificationDeliveryResult>? get results {
    final value = _results;
    if (value == null) return null;
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'NotificationBatch(id: $id, title: $title, recipients: $recipients, template: $template, variables: $variables, status: $status, createdAt: $createdAt, scheduledAt: $scheduledAt, completedAt: $completedAt, totalCount: $totalCount, successCount: $successCount, failureCount: $failureCount, results: $results, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationBatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            const DeepCollectionEquality().equals(
              other._recipients,
              _recipients,
            ) &&
            (identical(other.template, template) ||
                other.template == template) &&
            const DeepCollectionEquality().equals(
              other._variables,
              _variables,
            ) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.successCount, successCount) ||
                other.successCount == successCount) &&
            (identical(other.failureCount, failureCount) ||
                other.failureCount == failureCount) &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    const DeepCollectionEquality().hash(_recipients),
    template,
    const DeepCollectionEquality().hash(_variables),
    status,
    createdAt,
    scheduledAt,
    completedAt,
    totalCount,
    successCount,
    failureCount,
    const DeepCollectionEquality().hash(_results),
    errorMessage,
  );

  /// Create a copy of NotificationBatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationBatchImplCopyWith<_$NotificationBatchImpl> get copyWith =>
      __$$NotificationBatchImplCopyWithImpl<_$NotificationBatchImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationBatchImplToJson(this);
  }
}

abstract class _NotificationBatch implements NotificationBatch {
  const factory _NotificationBatch({
    required final String id,
    required final String title,
    required final List<String> recipients,
    required final NotificationTemplate template,
    required final Map<String, dynamic> variables,
    required final NotificationBatchStatus status,
    required final DateTime createdAt,
    final DateTime? scheduledAt,
    final DateTime? completedAt,
    final int totalCount,
    final int successCount,
    final int failureCount,
    final List<NotificationDeliveryResult>? results,
    final String? errorMessage,
  }) = _$NotificationBatchImpl;

  factory _NotificationBatch.fromJson(Map<String, dynamic> json) =
      _$NotificationBatchImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  List<String> get recipients;
  @override
  NotificationTemplate get template;
  @override
  Map<String, dynamic> get variables;
  @override
  NotificationBatchStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime? get scheduledAt;
  @override
  DateTime? get completedAt;
  @override
  int get totalCount;
  @override
  int get successCount;
  @override
  int get failureCount;
  @override
  List<NotificationDeliveryResult>? get results;
  @override
  String? get errorMessage;

  /// Create a copy of NotificationBatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationBatchImplCopyWith<_$NotificationBatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NotificationDeliveryResult _$NotificationDeliveryResultFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationDeliveryResult.fromJson(json);
}

/// @nodoc
mixin _$NotificationDeliveryResult {
  String get recipientId => throw _privateConstructorUsedError;
  List<NotificationChannelResult> get channelResults =>
      throw _privateConstructorUsedError;
  NotificationDeliveryStatus get overallStatus =>
      throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Serializes this NotificationDeliveryResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationDeliveryResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationDeliveryResultCopyWith<NotificationDeliveryResult>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationDeliveryResultCopyWith<$Res> {
  factory $NotificationDeliveryResultCopyWith(
    NotificationDeliveryResult value,
    $Res Function(NotificationDeliveryResult) then,
  ) =
      _$NotificationDeliveryResultCopyWithImpl<
        $Res,
        NotificationDeliveryResult
      >;
  @useResult
  $Res call({
    String recipientId,
    List<NotificationChannelResult> channelResults,
    NotificationDeliveryStatus overallStatus,
    DateTime? deliveredAt,
    String? errorMessage,
  });
}

/// @nodoc
class _$NotificationDeliveryResultCopyWithImpl<
  $Res,
  $Val extends NotificationDeliveryResult
>
    implements $NotificationDeliveryResultCopyWith<$Res> {
  _$NotificationDeliveryResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationDeliveryResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipientId = null,
    Object? channelResults = null,
    Object? overallStatus = null,
    Object? deliveredAt = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            recipientId: null == recipientId
                ? _value.recipientId
                : recipientId // ignore: cast_nullable_to_non_nullable
                      as String,
            channelResults: null == channelResults
                ? _value.channelResults
                : channelResults // ignore: cast_nullable_to_non_nullable
                      as List<NotificationChannelResult>,
            overallStatus: null == overallStatus
                ? _value.overallStatus
                : overallStatus // ignore: cast_nullable_to_non_nullable
                      as NotificationDeliveryStatus,
            deliveredAt: freezed == deliveredAt
                ? _value.deliveredAt
                : deliveredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationDeliveryResultImplCopyWith<$Res>
    implements $NotificationDeliveryResultCopyWith<$Res> {
  factory _$$NotificationDeliveryResultImplCopyWith(
    _$NotificationDeliveryResultImpl value,
    $Res Function(_$NotificationDeliveryResultImpl) then,
  ) = __$$NotificationDeliveryResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String recipientId,
    List<NotificationChannelResult> channelResults,
    NotificationDeliveryStatus overallStatus,
    DateTime? deliveredAt,
    String? errorMessage,
  });
}

/// @nodoc
class __$$NotificationDeliveryResultImplCopyWithImpl<$Res>
    extends
        _$NotificationDeliveryResultCopyWithImpl<
          $Res,
          _$NotificationDeliveryResultImpl
        >
    implements _$$NotificationDeliveryResultImplCopyWith<$Res> {
  __$$NotificationDeliveryResultImplCopyWithImpl(
    _$NotificationDeliveryResultImpl _value,
    $Res Function(_$NotificationDeliveryResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationDeliveryResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipientId = null,
    Object? channelResults = null,
    Object? overallStatus = null,
    Object? deliveredAt = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$NotificationDeliveryResultImpl(
        recipientId: null == recipientId
            ? _value.recipientId
            : recipientId // ignore: cast_nullable_to_non_nullable
                  as String,
        channelResults: null == channelResults
            ? _value._channelResults
            : channelResults // ignore: cast_nullable_to_non_nullable
                  as List<NotificationChannelResult>,
        overallStatus: null == overallStatus
            ? _value.overallStatus
            : overallStatus // ignore: cast_nullable_to_non_nullable
                  as NotificationDeliveryStatus,
        deliveredAt: freezed == deliveredAt
            ? _value.deliveredAt
            : deliveredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationDeliveryResultImpl implements _NotificationDeliveryResult {
  const _$NotificationDeliveryResultImpl({
    required this.recipientId,
    required final List<NotificationChannelResult> channelResults,
    required this.overallStatus,
    this.deliveredAt,
    this.errorMessage,
  }) : _channelResults = channelResults;

  factory _$NotificationDeliveryResultImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$NotificationDeliveryResultImplFromJson(json);

  @override
  final String recipientId;
  final List<NotificationChannelResult> _channelResults;
  @override
  List<NotificationChannelResult> get channelResults {
    if (_channelResults is EqualUnmodifiableListView) return _channelResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_channelResults);
  }

  @override
  final NotificationDeliveryStatus overallStatus;
  @override
  final DateTime? deliveredAt;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'NotificationDeliveryResult(recipientId: $recipientId, channelResults: $channelResults, overallStatus: $overallStatus, deliveredAt: $deliveredAt, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationDeliveryResultImpl &&
            (identical(other.recipientId, recipientId) ||
                other.recipientId == recipientId) &&
            const DeepCollectionEquality().equals(
              other._channelResults,
              _channelResults,
            ) &&
            (identical(other.overallStatus, overallStatus) ||
                other.overallStatus == overallStatus) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    recipientId,
    const DeepCollectionEquality().hash(_channelResults),
    overallStatus,
    deliveredAt,
    errorMessage,
  );

  /// Create a copy of NotificationDeliveryResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationDeliveryResultImplCopyWith<_$NotificationDeliveryResultImpl>
  get copyWith =>
      __$$NotificationDeliveryResultImplCopyWithImpl<
        _$NotificationDeliveryResultImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationDeliveryResultImplToJson(this);
  }
}

abstract class _NotificationDeliveryResult
    implements NotificationDeliveryResult {
  const factory _NotificationDeliveryResult({
    required final String recipientId,
    required final List<NotificationChannelResult> channelResults,
    required final NotificationDeliveryStatus overallStatus,
    final DateTime? deliveredAt,
    final String? errorMessage,
  }) = _$NotificationDeliveryResultImpl;

  factory _NotificationDeliveryResult.fromJson(Map<String, dynamic> json) =
      _$NotificationDeliveryResultImpl.fromJson;

  @override
  String get recipientId;
  @override
  List<NotificationChannelResult> get channelResults;
  @override
  NotificationDeliveryStatus get overallStatus;
  @override
  DateTime? get deliveredAt;
  @override
  String? get errorMessage;

  /// Create a copy of NotificationDeliveryResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationDeliveryResultImplCopyWith<_$NotificationDeliveryResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}

NotificationChannelResult _$NotificationChannelResultFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationChannelResult.fromJson(json);
}

/// @nodoc
mixin _$NotificationChannelResult {
  NotificationChannel get channel => throw _privateConstructorUsedError;
  NotificationDeliveryStatus get status => throw _privateConstructorUsedError;
  DateTime? get attemptedAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this NotificationChannelResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationChannelResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationChannelResultCopyWith<NotificationChannelResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationChannelResultCopyWith<$Res> {
  factory $NotificationChannelResultCopyWith(
    NotificationChannelResult value,
    $Res Function(NotificationChannelResult) then,
  ) = _$NotificationChannelResultCopyWithImpl<$Res, NotificationChannelResult>;
  @useResult
  $Res call({
    NotificationChannel channel,
    NotificationDeliveryStatus status,
    DateTime? attemptedAt,
    DateTime? deliveredAt,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class _$NotificationChannelResultCopyWithImpl<
  $Res,
  $Val extends NotificationChannelResult
>
    implements $NotificationChannelResultCopyWith<$Res> {
  _$NotificationChannelResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationChannelResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? channel = null,
    Object? status = null,
    Object? attemptedAt = freezed,
    Object? deliveredAt = freezed,
    Object? errorMessage = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            channel: null == channel
                ? _value.channel
                : channel // ignore: cast_nullable_to_non_nullable
                      as NotificationChannel,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as NotificationDeliveryStatus,
            attemptedAt: freezed == attemptedAt
                ? _value.attemptedAt
                : attemptedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deliveredAt: freezed == deliveredAt
                ? _value.deliveredAt
                : deliveredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationChannelResultImplCopyWith<$Res>
    implements $NotificationChannelResultCopyWith<$Res> {
  factory _$$NotificationChannelResultImplCopyWith(
    _$NotificationChannelResultImpl value,
    $Res Function(_$NotificationChannelResultImpl) then,
  ) = __$$NotificationChannelResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    NotificationChannel channel,
    NotificationDeliveryStatus status,
    DateTime? attemptedAt,
    DateTime? deliveredAt,
    String? errorMessage,
    Map<String, dynamic>? metadata,
  });
}

/// @nodoc
class __$$NotificationChannelResultImplCopyWithImpl<$Res>
    extends
        _$NotificationChannelResultCopyWithImpl<
          $Res,
          _$NotificationChannelResultImpl
        >
    implements _$$NotificationChannelResultImplCopyWith<$Res> {
  __$$NotificationChannelResultImplCopyWithImpl(
    _$NotificationChannelResultImpl _value,
    $Res Function(_$NotificationChannelResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationChannelResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? channel = null,
    Object? status = null,
    Object? attemptedAt = freezed,
    Object? deliveredAt = freezed,
    Object? errorMessage = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$NotificationChannelResultImpl(
        channel: null == channel
            ? _value.channel
            : channel // ignore: cast_nullable_to_non_nullable
                  as NotificationChannel,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as NotificationDeliveryStatus,
        attemptedAt: freezed == attemptedAt
            ? _value.attemptedAt
            : attemptedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deliveredAt: freezed == deliveredAt
            ? _value.deliveredAt
            : deliveredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationChannelResultImpl implements _NotificationChannelResult {
  const _$NotificationChannelResultImpl({
    required this.channel,
    required this.status,
    this.attemptedAt,
    this.deliveredAt,
    this.errorMessage,
    final Map<String, dynamic>? metadata,
  }) : _metadata = metadata;

  factory _$NotificationChannelResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationChannelResultImplFromJson(json);

  @override
  final NotificationChannel channel;
  @override
  final NotificationDeliveryStatus status;
  @override
  final DateTime? attemptedAt;
  @override
  final DateTime? deliveredAt;
  @override
  final String? errorMessage;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'NotificationChannelResult(channel: $channel, status: $status, attemptedAt: $attemptedAt, deliveredAt: $deliveredAt, errorMessage: $errorMessage, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationChannelResultImpl &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.attemptedAt, attemptedAt) ||
                other.attemptedAt == attemptedAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    channel,
    status,
    attemptedAt,
    deliveredAt,
    errorMessage,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of NotificationChannelResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationChannelResultImplCopyWith<_$NotificationChannelResultImpl>
  get copyWith =>
      __$$NotificationChannelResultImplCopyWithImpl<
        _$NotificationChannelResultImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationChannelResultImplToJson(this);
  }
}

abstract class _NotificationChannelResult implements NotificationChannelResult {
  const factory _NotificationChannelResult({
    required final NotificationChannel channel,
    required final NotificationDeliveryStatus status,
    final DateTime? attemptedAt,
    final DateTime? deliveredAt,
    final String? errorMessage,
    final Map<String, dynamic>? metadata,
  }) = _$NotificationChannelResultImpl;

  factory _NotificationChannelResult.fromJson(Map<String, dynamic> json) =
      _$NotificationChannelResultImpl.fromJson;

  @override
  NotificationChannel get channel;
  @override
  NotificationDeliveryStatus get status;
  @override
  DateTime? get attemptedAt;
  @override
  DateTime? get deliveredAt;
  @override
  String? get errorMessage;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of NotificationChannelResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationChannelResultImplCopyWith<_$NotificationChannelResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}

NotificationSubscription _$NotificationSubscriptionFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationSubscription.fromJson(json);
}

/// @nodoc
mixin _$NotificationSubscription {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  NotificationChannel get channel => throw _privateConstructorUsedError;
  String get endpoint => throw _privateConstructorUsedError;
  Map<String, dynamic>? get credentials => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastUsedAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationSubscription to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationSubscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationSubscriptionCopyWith<NotificationSubscription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationSubscriptionCopyWith<$Res> {
  factory $NotificationSubscriptionCopyWith(
    NotificationSubscription value,
    $Res Function(NotificationSubscription) then,
  ) = _$NotificationSubscriptionCopyWithImpl<$Res, NotificationSubscription>;
  @useResult
  $Res call({
    String id,
    String userId,
    NotificationChannel channel,
    String endpoint,
    Map<String, dynamic>? credentials,
    bool isActive,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  });
}

/// @nodoc
class _$NotificationSubscriptionCopyWithImpl<
  $Res,
  $Val extends NotificationSubscription
>
    implements $NotificationSubscriptionCopyWith<$Res> {
  _$NotificationSubscriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationSubscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? channel = null,
    Object? endpoint = null,
    Object? credentials = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? lastUsedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            channel: null == channel
                ? _value.channel
                : channel // ignore: cast_nullable_to_non_nullable
                      as NotificationChannel,
            endpoint: null == endpoint
                ? _value.endpoint
                : endpoint // ignore: cast_nullable_to_non_nullable
                      as String,
            credentials: freezed == credentials
                ? _value.credentials
                : credentials // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastUsedAt: freezed == lastUsedAt
                ? _value.lastUsedAt
                : lastUsedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationSubscriptionImplCopyWith<$Res>
    implements $NotificationSubscriptionCopyWith<$Res> {
  factory _$$NotificationSubscriptionImplCopyWith(
    _$NotificationSubscriptionImpl value,
    $Res Function(_$NotificationSubscriptionImpl) then,
  ) = __$$NotificationSubscriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    NotificationChannel channel,
    String endpoint,
    Map<String, dynamic>? credentials,
    bool isActive,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  });
}

/// @nodoc
class __$$NotificationSubscriptionImplCopyWithImpl<$Res>
    extends
        _$NotificationSubscriptionCopyWithImpl<
          $Res,
          _$NotificationSubscriptionImpl
        >
    implements _$$NotificationSubscriptionImplCopyWith<$Res> {
  __$$NotificationSubscriptionImplCopyWithImpl(
    _$NotificationSubscriptionImpl _value,
    $Res Function(_$NotificationSubscriptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationSubscription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? channel = null,
    Object? endpoint = null,
    Object? credentials = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? lastUsedAt = freezed,
  }) {
    return _then(
      _$NotificationSubscriptionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        channel: null == channel
            ? _value.channel
            : channel // ignore: cast_nullable_to_non_nullable
                  as NotificationChannel,
        endpoint: null == endpoint
            ? _value.endpoint
            : endpoint // ignore: cast_nullable_to_non_nullable
                  as String,
        credentials: freezed == credentials
            ? _value._credentials
            : credentials // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastUsedAt: freezed == lastUsedAt
            ? _value.lastUsedAt
            : lastUsedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationSubscriptionImpl implements _NotificationSubscription {
  const _$NotificationSubscriptionImpl({
    required this.id,
    required this.userId,
    required this.channel,
    required this.endpoint,
    final Map<String, dynamic>? credentials,
    this.isActive = true,
    this.createdAt,
    this.lastUsedAt,
  }) : _credentials = credentials;

  factory _$NotificationSubscriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationSubscriptionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final NotificationChannel channel;
  @override
  final String endpoint;
  final Map<String, dynamic>? _credentials;
  @override
  Map<String, dynamic>? get credentials {
    final value = _credentials;
    if (value == null) return null;
    if (_credentials is EqualUnmodifiableMapView) return _credentials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? lastUsedAt;

  @override
  String toString() {
    return 'NotificationSubscription(id: $id, userId: $userId, channel: $channel, endpoint: $endpoint, credentials: $credentials, isActive: $isActive, createdAt: $createdAt, lastUsedAt: $lastUsedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationSubscriptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.endpoint, endpoint) ||
                other.endpoint == endpoint) &&
            const DeepCollectionEquality().equals(
              other._credentials,
              _credentials,
            ) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastUsedAt, lastUsedAt) ||
                other.lastUsedAt == lastUsedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    channel,
    endpoint,
    const DeepCollectionEquality().hash(_credentials),
    isActive,
    createdAt,
    lastUsedAt,
  );

  /// Create a copy of NotificationSubscription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationSubscriptionImplCopyWith<_$NotificationSubscriptionImpl>
  get copyWith =>
      __$$NotificationSubscriptionImplCopyWithImpl<
        _$NotificationSubscriptionImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationSubscriptionImplToJson(this);
  }
}

abstract class _NotificationSubscription implements NotificationSubscription {
  const factory _NotificationSubscription({
    required final String id,
    required final String userId,
    required final NotificationChannel channel,
    required final String endpoint,
    final Map<String, dynamic>? credentials,
    final bool isActive,
    final DateTime? createdAt,
    final DateTime? lastUsedAt,
  }) = _$NotificationSubscriptionImpl;

  factory _NotificationSubscription.fromJson(Map<String, dynamic> json) =
      _$NotificationSubscriptionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  NotificationChannel get channel;
  @override
  String get endpoint;
  @override
  Map<String, dynamic>? get credentials;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get lastUsedAt;

  /// Create a copy of NotificationSubscription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationSubscriptionImplCopyWith<_$NotificationSubscriptionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

NotificationAnalytics _$NotificationAnalyticsFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationAnalytics.fromJson(json);
}

/// @nodoc
mixin _$NotificationAnalytics {
  NotificationDeliveryStats get deliveryStats =>
      throw _privateConstructorUsedError;
  List<NotificationTypeMetric> get typeMetrics =>
      throw _privateConstructorUsedError;
  List<NotificationChannelMetric> get channelMetrics =>
      throw _privateConstructorUsedError;
  NotificationEngagementMetrics get engagement =>
      throw _privateConstructorUsedError;

  /// Serializes this NotificationAnalytics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationAnalyticsCopyWith<NotificationAnalytics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationAnalyticsCopyWith<$Res> {
  factory $NotificationAnalyticsCopyWith(
    NotificationAnalytics value,
    $Res Function(NotificationAnalytics) then,
  ) = _$NotificationAnalyticsCopyWithImpl<$Res, NotificationAnalytics>;
  @useResult
  $Res call({
    NotificationDeliveryStats deliveryStats,
    List<NotificationTypeMetric> typeMetrics,
    List<NotificationChannelMetric> channelMetrics,
    NotificationEngagementMetrics engagement,
  });

  $NotificationDeliveryStatsCopyWith<$Res> get deliveryStats;
  $NotificationEngagementMetricsCopyWith<$Res> get engagement;
}

/// @nodoc
class _$NotificationAnalyticsCopyWithImpl<
  $Res,
  $Val extends NotificationAnalytics
>
    implements $NotificationAnalyticsCopyWith<$Res> {
  _$NotificationAnalyticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deliveryStats = null,
    Object? typeMetrics = null,
    Object? channelMetrics = null,
    Object? engagement = null,
  }) {
    return _then(
      _value.copyWith(
            deliveryStats: null == deliveryStats
                ? _value.deliveryStats
                : deliveryStats // ignore: cast_nullable_to_non_nullable
                      as NotificationDeliveryStats,
            typeMetrics: null == typeMetrics
                ? _value.typeMetrics
                : typeMetrics // ignore: cast_nullable_to_non_nullable
                      as List<NotificationTypeMetric>,
            channelMetrics: null == channelMetrics
                ? _value.channelMetrics
                : channelMetrics // ignore: cast_nullable_to_non_nullable
                      as List<NotificationChannelMetric>,
            engagement: null == engagement
                ? _value.engagement
                : engagement // ignore: cast_nullable_to_non_nullable
                      as NotificationEngagementMetrics,
          )
          as $Val,
    );
  }

  /// Create a copy of NotificationAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NotificationDeliveryStatsCopyWith<$Res> get deliveryStats {
    return $NotificationDeliveryStatsCopyWith<$Res>(_value.deliveryStats, (
      value,
    ) {
      return _then(_value.copyWith(deliveryStats: value) as $Val);
    });
  }

  /// Create a copy of NotificationAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NotificationEngagementMetricsCopyWith<$Res> get engagement {
    return $NotificationEngagementMetricsCopyWith<$Res>(_value.engagement, (
      value,
    ) {
      return _then(_value.copyWith(engagement: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NotificationAnalyticsImplCopyWith<$Res>
    implements $NotificationAnalyticsCopyWith<$Res> {
  factory _$$NotificationAnalyticsImplCopyWith(
    _$NotificationAnalyticsImpl value,
    $Res Function(_$NotificationAnalyticsImpl) then,
  ) = __$$NotificationAnalyticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    NotificationDeliveryStats deliveryStats,
    List<NotificationTypeMetric> typeMetrics,
    List<NotificationChannelMetric> channelMetrics,
    NotificationEngagementMetrics engagement,
  });

  @override
  $NotificationDeliveryStatsCopyWith<$Res> get deliveryStats;
  @override
  $NotificationEngagementMetricsCopyWith<$Res> get engagement;
}

/// @nodoc
class __$$NotificationAnalyticsImplCopyWithImpl<$Res>
    extends
        _$NotificationAnalyticsCopyWithImpl<$Res, _$NotificationAnalyticsImpl>
    implements _$$NotificationAnalyticsImplCopyWith<$Res> {
  __$$NotificationAnalyticsImplCopyWithImpl(
    _$NotificationAnalyticsImpl _value,
    $Res Function(_$NotificationAnalyticsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deliveryStats = null,
    Object? typeMetrics = null,
    Object? channelMetrics = null,
    Object? engagement = null,
  }) {
    return _then(
      _$NotificationAnalyticsImpl(
        deliveryStats: null == deliveryStats
            ? _value.deliveryStats
            : deliveryStats // ignore: cast_nullable_to_non_nullable
                  as NotificationDeliveryStats,
        typeMetrics: null == typeMetrics
            ? _value._typeMetrics
            : typeMetrics // ignore: cast_nullable_to_non_nullable
                  as List<NotificationTypeMetric>,
        channelMetrics: null == channelMetrics
            ? _value._channelMetrics
            : channelMetrics // ignore: cast_nullable_to_non_nullable
                  as List<NotificationChannelMetric>,
        engagement: null == engagement
            ? _value.engagement
            : engagement // ignore: cast_nullable_to_non_nullable
                  as NotificationEngagementMetrics,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationAnalyticsImpl implements _NotificationAnalytics {
  const _$NotificationAnalyticsImpl({
    required this.deliveryStats,
    required final List<NotificationTypeMetric> typeMetrics,
    required final List<NotificationChannelMetric> channelMetrics,
    required this.engagement,
  }) : _typeMetrics = typeMetrics,
       _channelMetrics = channelMetrics;

  factory _$NotificationAnalyticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationAnalyticsImplFromJson(json);

  @override
  final NotificationDeliveryStats deliveryStats;
  final List<NotificationTypeMetric> _typeMetrics;
  @override
  List<NotificationTypeMetric> get typeMetrics {
    if (_typeMetrics is EqualUnmodifiableListView) return _typeMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_typeMetrics);
  }

  final List<NotificationChannelMetric> _channelMetrics;
  @override
  List<NotificationChannelMetric> get channelMetrics {
    if (_channelMetrics is EqualUnmodifiableListView) return _channelMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_channelMetrics);
  }

  @override
  final NotificationEngagementMetrics engagement;

  @override
  String toString() {
    return 'NotificationAnalytics(deliveryStats: $deliveryStats, typeMetrics: $typeMetrics, channelMetrics: $channelMetrics, engagement: $engagement)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationAnalyticsImpl &&
            (identical(other.deliveryStats, deliveryStats) ||
                other.deliveryStats == deliveryStats) &&
            const DeepCollectionEquality().equals(
              other._typeMetrics,
              _typeMetrics,
            ) &&
            const DeepCollectionEquality().equals(
              other._channelMetrics,
              _channelMetrics,
            ) &&
            (identical(other.engagement, engagement) ||
                other.engagement == engagement));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    deliveryStats,
    const DeepCollectionEquality().hash(_typeMetrics),
    const DeepCollectionEquality().hash(_channelMetrics),
    engagement,
  );

  /// Create a copy of NotificationAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationAnalyticsImplCopyWith<_$NotificationAnalyticsImpl>
  get copyWith =>
      __$$NotificationAnalyticsImplCopyWithImpl<_$NotificationAnalyticsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationAnalyticsImplToJson(this);
  }
}

abstract class _NotificationAnalytics implements NotificationAnalytics {
  const factory _NotificationAnalytics({
    required final NotificationDeliveryStats deliveryStats,
    required final List<NotificationTypeMetric> typeMetrics,
    required final List<NotificationChannelMetric> channelMetrics,
    required final NotificationEngagementMetrics engagement,
  }) = _$NotificationAnalyticsImpl;

  factory _NotificationAnalytics.fromJson(Map<String, dynamic> json) =
      _$NotificationAnalyticsImpl.fromJson;

  @override
  NotificationDeliveryStats get deliveryStats;
  @override
  List<NotificationTypeMetric> get typeMetrics;
  @override
  List<NotificationChannelMetric> get channelMetrics;
  @override
  NotificationEngagementMetrics get engagement;

  /// Create a copy of NotificationAnalytics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationAnalyticsImplCopyWith<_$NotificationAnalyticsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

NotificationDeliveryStats _$NotificationDeliveryStatsFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationDeliveryStats.fromJson(json);
}

/// @nodoc
mixin _$NotificationDeliveryStats {
  int get totalSent => throw _privateConstructorUsedError;
  int get totalDelivered => throw _privateConstructorUsedError;
  int get totalFailed => throw _privateConstructorUsedError;
  int get totalRead => throw _privateConstructorUsedError;
  double get deliveryRate => throw _privateConstructorUsedError;
  double get readRate => throw _privateConstructorUsedError;
  double get averageDeliveryTime => throw _privateConstructorUsedError;

  /// Serializes this NotificationDeliveryStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationDeliveryStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationDeliveryStatsCopyWith<NotificationDeliveryStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationDeliveryStatsCopyWith<$Res> {
  factory $NotificationDeliveryStatsCopyWith(
    NotificationDeliveryStats value,
    $Res Function(NotificationDeliveryStats) then,
  ) = _$NotificationDeliveryStatsCopyWithImpl<$Res, NotificationDeliveryStats>;
  @useResult
  $Res call({
    int totalSent,
    int totalDelivered,
    int totalFailed,
    int totalRead,
    double deliveryRate,
    double readRate,
    double averageDeliveryTime,
  });
}

/// @nodoc
class _$NotificationDeliveryStatsCopyWithImpl<
  $Res,
  $Val extends NotificationDeliveryStats
>
    implements $NotificationDeliveryStatsCopyWith<$Res> {
  _$NotificationDeliveryStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationDeliveryStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSent = null,
    Object? totalDelivered = null,
    Object? totalFailed = null,
    Object? totalRead = null,
    Object? deliveryRate = null,
    Object? readRate = null,
    Object? averageDeliveryTime = null,
  }) {
    return _then(
      _value.copyWith(
            totalSent: null == totalSent
                ? _value.totalSent
                : totalSent // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDelivered: null == totalDelivered
                ? _value.totalDelivered
                : totalDelivered // ignore: cast_nullable_to_non_nullable
                      as int,
            totalFailed: null == totalFailed
                ? _value.totalFailed
                : totalFailed // ignore: cast_nullable_to_non_nullable
                      as int,
            totalRead: null == totalRead
                ? _value.totalRead
                : totalRead // ignore: cast_nullable_to_non_nullable
                      as int,
            deliveryRate: null == deliveryRate
                ? _value.deliveryRate
                : deliveryRate // ignore: cast_nullable_to_non_nullable
                      as double,
            readRate: null == readRate
                ? _value.readRate
                : readRate // ignore: cast_nullable_to_non_nullable
                      as double,
            averageDeliveryTime: null == averageDeliveryTime
                ? _value.averageDeliveryTime
                : averageDeliveryTime // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationDeliveryStatsImplCopyWith<$Res>
    implements $NotificationDeliveryStatsCopyWith<$Res> {
  factory _$$NotificationDeliveryStatsImplCopyWith(
    _$NotificationDeliveryStatsImpl value,
    $Res Function(_$NotificationDeliveryStatsImpl) then,
  ) = __$$NotificationDeliveryStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalSent,
    int totalDelivered,
    int totalFailed,
    int totalRead,
    double deliveryRate,
    double readRate,
    double averageDeliveryTime,
  });
}

/// @nodoc
class __$$NotificationDeliveryStatsImplCopyWithImpl<$Res>
    extends
        _$NotificationDeliveryStatsCopyWithImpl<
          $Res,
          _$NotificationDeliveryStatsImpl
        >
    implements _$$NotificationDeliveryStatsImplCopyWith<$Res> {
  __$$NotificationDeliveryStatsImplCopyWithImpl(
    _$NotificationDeliveryStatsImpl _value,
    $Res Function(_$NotificationDeliveryStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationDeliveryStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSent = null,
    Object? totalDelivered = null,
    Object? totalFailed = null,
    Object? totalRead = null,
    Object? deliveryRate = null,
    Object? readRate = null,
    Object? averageDeliveryTime = null,
  }) {
    return _then(
      _$NotificationDeliveryStatsImpl(
        totalSent: null == totalSent
            ? _value.totalSent
            : totalSent // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDelivered: null == totalDelivered
            ? _value.totalDelivered
            : totalDelivered // ignore: cast_nullable_to_non_nullable
                  as int,
        totalFailed: null == totalFailed
            ? _value.totalFailed
            : totalFailed // ignore: cast_nullable_to_non_nullable
                  as int,
        totalRead: null == totalRead
            ? _value.totalRead
            : totalRead // ignore: cast_nullable_to_non_nullable
                  as int,
        deliveryRate: null == deliveryRate
            ? _value.deliveryRate
            : deliveryRate // ignore: cast_nullable_to_non_nullable
                  as double,
        readRate: null == readRate
            ? _value.readRate
            : readRate // ignore: cast_nullable_to_non_nullable
                  as double,
        averageDeliveryTime: null == averageDeliveryTime
            ? _value.averageDeliveryTime
            : averageDeliveryTime // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationDeliveryStatsImpl implements _NotificationDeliveryStats {
  const _$NotificationDeliveryStatsImpl({
    required this.totalSent,
    required this.totalDelivered,
    required this.totalFailed,
    required this.totalRead,
    required this.deliveryRate,
    required this.readRate,
    required this.averageDeliveryTime,
  });

  factory _$NotificationDeliveryStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationDeliveryStatsImplFromJson(json);

  @override
  final int totalSent;
  @override
  final int totalDelivered;
  @override
  final int totalFailed;
  @override
  final int totalRead;
  @override
  final double deliveryRate;
  @override
  final double readRate;
  @override
  final double averageDeliveryTime;

  @override
  String toString() {
    return 'NotificationDeliveryStats(totalSent: $totalSent, totalDelivered: $totalDelivered, totalFailed: $totalFailed, totalRead: $totalRead, deliveryRate: $deliveryRate, readRate: $readRate, averageDeliveryTime: $averageDeliveryTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationDeliveryStatsImpl &&
            (identical(other.totalSent, totalSent) ||
                other.totalSent == totalSent) &&
            (identical(other.totalDelivered, totalDelivered) ||
                other.totalDelivered == totalDelivered) &&
            (identical(other.totalFailed, totalFailed) ||
                other.totalFailed == totalFailed) &&
            (identical(other.totalRead, totalRead) ||
                other.totalRead == totalRead) &&
            (identical(other.deliveryRate, deliveryRate) ||
                other.deliveryRate == deliveryRate) &&
            (identical(other.readRate, readRate) ||
                other.readRate == readRate) &&
            (identical(other.averageDeliveryTime, averageDeliveryTime) ||
                other.averageDeliveryTime == averageDeliveryTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalSent,
    totalDelivered,
    totalFailed,
    totalRead,
    deliveryRate,
    readRate,
    averageDeliveryTime,
  );

  /// Create a copy of NotificationDeliveryStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationDeliveryStatsImplCopyWith<_$NotificationDeliveryStatsImpl>
  get copyWith =>
      __$$NotificationDeliveryStatsImplCopyWithImpl<
        _$NotificationDeliveryStatsImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationDeliveryStatsImplToJson(this);
  }
}

abstract class _NotificationDeliveryStats implements NotificationDeliveryStats {
  const factory _NotificationDeliveryStats({
    required final int totalSent,
    required final int totalDelivered,
    required final int totalFailed,
    required final int totalRead,
    required final double deliveryRate,
    required final double readRate,
    required final double averageDeliveryTime,
  }) = _$NotificationDeliveryStatsImpl;

  factory _NotificationDeliveryStats.fromJson(Map<String, dynamic> json) =
      _$NotificationDeliveryStatsImpl.fromJson;

  @override
  int get totalSent;
  @override
  int get totalDelivered;
  @override
  int get totalFailed;
  @override
  int get totalRead;
  @override
  double get deliveryRate;
  @override
  double get readRate;
  @override
  double get averageDeliveryTime;

  /// Create a copy of NotificationDeliveryStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationDeliveryStatsImplCopyWith<_$NotificationDeliveryStatsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

NotificationTypeMetric _$NotificationTypeMetricFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationTypeMetric.fromJson(json);
}

/// @nodoc
mixin _$NotificationTypeMetric {
  NotificationType get type => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  double get deliveryRate => throw _privateConstructorUsedError;
  double get readRate => throw _privateConstructorUsedError;
  double get averageEngagementTime => throw _privateConstructorUsedError;

  /// Serializes this NotificationTypeMetric to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationTypeMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationTypeMetricCopyWith<NotificationTypeMetric> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationTypeMetricCopyWith<$Res> {
  factory $NotificationTypeMetricCopyWith(
    NotificationTypeMetric value,
    $Res Function(NotificationTypeMetric) then,
  ) = _$NotificationTypeMetricCopyWithImpl<$Res, NotificationTypeMetric>;
  @useResult
  $Res call({
    NotificationType type,
    int count,
    double deliveryRate,
    double readRate,
    double averageEngagementTime,
  });
}

/// @nodoc
class _$NotificationTypeMetricCopyWithImpl<
  $Res,
  $Val extends NotificationTypeMetric
>
    implements $NotificationTypeMetricCopyWith<$Res> {
  _$NotificationTypeMetricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationTypeMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? count = null,
    Object? deliveryRate = null,
    Object? readRate = null,
    Object? averageEngagementTime = null,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NotificationType,
            count: null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int,
            deliveryRate: null == deliveryRate
                ? _value.deliveryRate
                : deliveryRate // ignore: cast_nullable_to_non_nullable
                      as double,
            readRate: null == readRate
                ? _value.readRate
                : readRate // ignore: cast_nullable_to_non_nullable
                      as double,
            averageEngagementTime: null == averageEngagementTime
                ? _value.averageEngagementTime
                : averageEngagementTime // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationTypeMetricImplCopyWith<$Res>
    implements $NotificationTypeMetricCopyWith<$Res> {
  factory _$$NotificationTypeMetricImplCopyWith(
    _$NotificationTypeMetricImpl value,
    $Res Function(_$NotificationTypeMetricImpl) then,
  ) = __$$NotificationTypeMetricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    NotificationType type,
    int count,
    double deliveryRate,
    double readRate,
    double averageEngagementTime,
  });
}

/// @nodoc
class __$$NotificationTypeMetricImplCopyWithImpl<$Res>
    extends
        _$NotificationTypeMetricCopyWithImpl<$Res, _$NotificationTypeMetricImpl>
    implements _$$NotificationTypeMetricImplCopyWith<$Res> {
  __$$NotificationTypeMetricImplCopyWithImpl(
    _$NotificationTypeMetricImpl _value,
    $Res Function(_$NotificationTypeMetricImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationTypeMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? count = null,
    Object? deliveryRate = null,
    Object? readRate = null,
    Object? averageEngagementTime = null,
  }) {
    return _then(
      _$NotificationTypeMetricImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NotificationType,
        count: null == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int,
        deliveryRate: null == deliveryRate
            ? _value.deliveryRate
            : deliveryRate // ignore: cast_nullable_to_non_nullable
                  as double,
        readRate: null == readRate
            ? _value.readRate
            : readRate // ignore: cast_nullable_to_non_nullable
                  as double,
        averageEngagementTime: null == averageEngagementTime
            ? _value.averageEngagementTime
            : averageEngagementTime // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationTypeMetricImpl implements _NotificationTypeMetric {
  const _$NotificationTypeMetricImpl({
    required this.type,
    required this.count,
    required this.deliveryRate,
    required this.readRate,
    required this.averageEngagementTime,
  });

  factory _$NotificationTypeMetricImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationTypeMetricImplFromJson(json);

  @override
  final NotificationType type;
  @override
  final int count;
  @override
  final double deliveryRate;
  @override
  final double readRate;
  @override
  final double averageEngagementTime;

  @override
  String toString() {
    return 'NotificationTypeMetric(type: $type, count: $count, deliveryRate: $deliveryRate, readRate: $readRate, averageEngagementTime: $averageEngagementTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationTypeMetricImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.deliveryRate, deliveryRate) ||
                other.deliveryRate == deliveryRate) &&
            (identical(other.readRate, readRate) ||
                other.readRate == readRate) &&
            (identical(other.averageEngagementTime, averageEngagementTime) ||
                other.averageEngagementTime == averageEngagementTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    count,
    deliveryRate,
    readRate,
    averageEngagementTime,
  );

  /// Create a copy of NotificationTypeMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationTypeMetricImplCopyWith<_$NotificationTypeMetricImpl>
  get copyWith =>
      __$$NotificationTypeMetricImplCopyWithImpl<_$NotificationTypeMetricImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationTypeMetricImplToJson(this);
  }
}

abstract class _NotificationTypeMetric implements NotificationTypeMetric {
  const factory _NotificationTypeMetric({
    required final NotificationType type,
    required final int count,
    required final double deliveryRate,
    required final double readRate,
    required final double averageEngagementTime,
  }) = _$NotificationTypeMetricImpl;

  factory _NotificationTypeMetric.fromJson(Map<String, dynamic> json) =
      _$NotificationTypeMetricImpl.fromJson;

  @override
  NotificationType get type;
  @override
  int get count;
  @override
  double get deliveryRate;
  @override
  double get readRate;
  @override
  double get averageEngagementTime;

  /// Create a copy of NotificationTypeMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationTypeMetricImplCopyWith<_$NotificationTypeMetricImpl>
  get copyWith => throw _privateConstructorUsedError;
}

NotificationChannelMetric _$NotificationChannelMetricFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationChannelMetric.fromJson(json);
}

/// @nodoc
mixin _$NotificationChannelMetric {
  NotificationChannel get channel => throw _privateConstructorUsedError;
  int get sent => throw _privateConstructorUsedError;
  int get delivered => throw _privateConstructorUsedError;
  int get failed => throw _privateConstructorUsedError;
  double get deliveryRate => throw _privateConstructorUsedError;
  double get averageDeliveryTime => throw _privateConstructorUsedError;

  /// Serializes this NotificationChannelMetric to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationChannelMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationChannelMetricCopyWith<NotificationChannelMetric> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationChannelMetricCopyWith<$Res> {
  factory $NotificationChannelMetricCopyWith(
    NotificationChannelMetric value,
    $Res Function(NotificationChannelMetric) then,
  ) = _$NotificationChannelMetricCopyWithImpl<$Res, NotificationChannelMetric>;
  @useResult
  $Res call({
    NotificationChannel channel,
    int sent,
    int delivered,
    int failed,
    double deliveryRate,
    double averageDeliveryTime,
  });
}

/// @nodoc
class _$NotificationChannelMetricCopyWithImpl<
  $Res,
  $Val extends NotificationChannelMetric
>
    implements $NotificationChannelMetricCopyWith<$Res> {
  _$NotificationChannelMetricCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationChannelMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? channel = null,
    Object? sent = null,
    Object? delivered = null,
    Object? failed = null,
    Object? deliveryRate = null,
    Object? averageDeliveryTime = null,
  }) {
    return _then(
      _value.copyWith(
            channel: null == channel
                ? _value.channel
                : channel // ignore: cast_nullable_to_non_nullable
                      as NotificationChannel,
            sent: null == sent
                ? _value.sent
                : sent // ignore: cast_nullable_to_non_nullable
                      as int,
            delivered: null == delivered
                ? _value.delivered
                : delivered // ignore: cast_nullable_to_non_nullable
                      as int,
            failed: null == failed
                ? _value.failed
                : failed // ignore: cast_nullable_to_non_nullable
                      as int,
            deliveryRate: null == deliveryRate
                ? _value.deliveryRate
                : deliveryRate // ignore: cast_nullable_to_non_nullable
                      as double,
            averageDeliveryTime: null == averageDeliveryTime
                ? _value.averageDeliveryTime
                : averageDeliveryTime // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationChannelMetricImplCopyWith<$Res>
    implements $NotificationChannelMetricCopyWith<$Res> {
  factory _$$NotificationChannelMetricImplCopyWith(
    _$NotificationChannelMetricImpl value,
    $Res Function(_$NotificationChannelMetricImpl) then,
  ) = __$$NotificationChannelMetricImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    NotificationChannel channel,
    int sent,
    int delivered,
    int failed,
    double deliveryRate,
    double averageDeliveryTime,
  });
}

/// @nodoc
class __$$NotificationChannelMetricImplCopyWithImpl<$Res>
    extends
        _$NotificationChannelMetricCopyWithImpl<
          $Res,
          _$NotificationChannelMetricImpl
        >
    implements _$$NotificationChannelMetricImplCopyWith<$Res> {
  __$$NotificationChannelMetricImplCopyWithImpl(
    _$NotificationChannelMetricImpl _value,
    $Res Function(_$NotificationChannelMetricImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationChannelMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? channel = null,
    Object? sent = null,
    Object? delivered = null,
    Object? failed = null,
    Object? deliveryRate = null,
    Object? averageDeliveryTime = null,
  }) {
    return _then(
      _$NotificationChannelMetricImpl(
        channel: null == channel
            ? _value.channel
            : channel // ignore: cast_nullable_to_non_nullable
                  as NotificationChannel,
        sent: null == sent
            ? _value.sent
            : sent // ignore: cast_nullable_to_non_nullable
                  as int,
        delivered: null == delivered
            ? _value.delivered
            : delivered // ignore: cast_nullable_to_non_nullable
                  as int,
        failed: null == failed
            ? _value.failed
            : failed // ignore: cast_nullable_to_non_nullable
                  as int,
        deliveryRate: null == deliveryRate
            ? _value.deliveryRate
            : deliveryRate // ignore: cast_nullable_to_non_nullable
                  as double,
        averageDeliveryTime: null == averageDeliveryTime
            ? _value.averageDeliveryTime
            : averageDeliveryTime // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationChannelMetricImpl implements _NotificationChannelMetric {
  const _$NotificationChannelMetricImpl({
    required this.channel,
    required this.sent,
    required this.delivered,
    required this.failed,
    required this.deliveryRate,
    required this.averageDeliveryTime,
  });

  factory _$NotificationChannelMetricImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationChannelMetricImplFromJson(json);

  @override
  final NotificationChannel channel;
  @override
  final int sent;
  @override
  final int delivered;
  @override
  final int failed;
  @override
  final double deliveryRate;
  @override
  final double averageDeliveryTime;

  @override
  String toString() {
    return 'NotificationChannelMetric(channel: $channel, sent: $sent, delivered: $delivered, failed: $failed, deliveryRate: $deliveryRate, averageDeliveryTime: $averageDeliveryTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationChannelMetricImpl &&
            (identical(other.channel, channel) || other.channel == channel) &&
            (identical(other.sent, sent) || other.sent == sent) &&
            (identical(other.delivered, delivered) ||
                other.delivered == delivered) &&
            (identical(other.failed, failed) || other.failed == failed) &&
            (identical(other.deliveryRate, deliveryRate) ||
                other.deliveryRate == deliveryRate) &&
            (identical(other.averageDeliveryTime, averageDeliveryTime) ||
                other.averageDeliveryTime == averageDeliveryTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    channel,
    sent,
    delivered,
    failed,
    deliveryRate,
    averageDeliveryTime,
  );

  /// Create a copy of NotificationChannelMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationChannelMetricImplCopyWith<_$NotificationChannelMetricImpl>
  get copyWith =>
      __$$NotificationChannelMetricImplCopyWithImpl<
        _$NotificationChannelMetricImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationChannelMetricImplToJson(this);
  }
}

abstract class _NotificationChannelMetric implements NotificationChannelMetric {
  const factory _NotificationChannelMetric({
    required final NotificationChannel channel,
    required final int sent,
    required final int delivered,
    required final int failed,
    required final double deliveryRate,
    required final double averageDeliveryTime,
  }) = _$NotificationChannelMetricImpl;

  factory _NotificationChannelMetric.fromJson(Map<String, dynamic> json) =
      _$NotificationChannelMetricImpl.fromJson;

  @override
  NotificationChannel get channel;
  @override
  int get sent;
  @override
  int get delivered;
  @override
  int get failed;
  @override
  double get deliveryRate;
  @override
  double get averageDeliveryTime;

  /// Create a copy of NotificationChannelMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationChannelMetricImplCopyWith<_$NotificationChannelMetricImpl>
  get copyWith => throw _privateConstructorUsedError;
}

NotificationEngagementMetrics _$NotificationEngagementMetricsFromJson(
  Map<String, dynamic> json,
) {
  return _NotificationEngagementMetrics.fromJson(json);
}

/// @nodoc
mixin _$NotificationEngagementMetrics {
  double get averageReadTime => throw _privateConstructorUsedError;
  double get clickThroughRate => throw _privateConstructorUsedError;
  int get totalClicks => throw _privateConstructorUsedError;
  int get totalDismissals => throw _privateConstructorUsedError;
  Map<String, int>? get actionCounts => throw _privateConstructorUsedError;

  /// Serializes this NotificationEngagementMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationEngagementMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationEngagementMetricsCopyWith<NotificationEngagementMetrics>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationEngagementMetricsCopyWith<$Res> {
  factory $NotificationEngagementMetricsCopyWith(
    NotificationEngagementMetrics value,
    $Res Function(NotificationEngagementMetrics) then,
  ) =
      _$NotificationEngagementMetricsCopyWithImpl<
        $Res,
        NotificationEngagementMetrics
      >;
  @useResult
  $Res call({
    double averageReadTime,
    double clickThroughRate,
    int totalClicks,
    int totalDismissals,
    Map<String, int>? actionCounts,
  });
}

/// @nodoc
class _$NotificationEngagementMetricsCopyWithImpl<
  $Res,
  $Val extends NotificationEngagementMetrics
>
    implements $NotificationEngagementMetricsCopyWith<$Res> {
  _$NotificationEngagementMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationEngagementMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? averageReadTime = null,
    Object? clickThroughRate = null,
    Object? totalClicks = null,
    Object? totalDismissals = null,
    Object? actionCounts = freezed,
  }) {
    return _then(
      _value.copyWith(
            averageReadTime: null == averageReadTime
                ? _value.averageReadTime
                : averageReadTime // ignore: cast_nullable_to_non_nullable
                      as double,
            clickThroughRate: null == clickThroughRate
                ? _value.clickThroughRate
                : clickThroughRate // ignore: cast_nullable_to_non_nullable
                      as double,
            totalClicks: null == totalClicks
                ? _value.totalClicks
                : totalClicks // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDismissals: null == totalDismissals
                ? _value.totalDismissals
                : totalDismissals // ignore: cast_nullable_to_non_nullable
                      as int,
            actionCounts: freezed == actionCounts
                ? _value.actionCounts
                : actionCounts // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NotificationEngagementMetricsImplCopyWith<$Res>
    implements $NotificationEngagementMetricsCopyWith<$Res> {
  factory _$$NotificationEngagementMetricsImplCopyWith(
    _$NotificationEngagementMetricsImpl value,
    $Res Function(_$NotificationEngagementMetricsImpl) then,
  ) = __$$NotificationEngagementMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double averageReadTime,
    double clickThroughRate,
    int totalClicks,
    int totalDismissals,
    Map<String, int>? actionCounts,
  });
}

/// @nodoc
class __$$NotificationEngagementMetricsImplCopyWithImpl<$Res>
    extends
        _$NotificationEngagementMetricsCopyWithImpl<
          $Res,
          _$NotificationEngagementMetricsImpl
        >
    implements _$$NotificationEngagementMetricsImplCopyWith<$Res> {
  __$$NotificationEngagementMetricsImplCopyWithImpl(
    _$NotificationEngagementMetricsImpl _value,
    $Res Function(_$NotificationEngagementMetricsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NotificationEngagementMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? averageReadTime = null,
    Object? clickThroughRate = null,
    Object? totalClicks = null,
    Object? totalDismissals = null,
    Object? actionCounts = freezed,
  }) {
    return _then(
      _$NotificationEngagementMetricsImpl(
        averageReadTime: null == averageReadTime
            ? _value.averageReadTime
            : averageReadTime // ignore: cast_nullable_to_non_nullable
                  as double,
        clickThroughRate: null == clickThroughRate
            ? _value.clickThroughRate
            : clickThroughRate // ignore: cast_nullable_to_non_nullable
                  as double,
        totalClicks: null == totalClicks
            ? _value.totalClicks
            : totalClicks // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDismissals: null == totalDismissals
            ? _value.totalDismissals
            : totalDismissals // ignore: cast_nullable_to_non_nullable
                  as int,
        actionCounts: freezed == actionCounts
            ? _value._actionCounts
            : actionCounts // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationEngagementMetricsImpl
    implements _NotificationEngagementMetrics {
  const _$NotificationEngagementMetricsImpl({
    required this.averageReadTime,
    required this.clickThroughRate,
    required this.totalClicks,
    required this.totalDismissals,
    final Map<String, int>? actionCounts,
  }) : _actionCounts = actionCounts;

  factory _$NotificationEngagementMetricsImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$NotificationEngagementMetricsImplFromJson(json);

  @override
  final double averageReadTime;
  @override
  final double clickThroughRate;
  @override
  final int totalClicks;
  @override
  final int totalDismissals;
  final Map<String, int>? _actionCounts;
  @override
  Map<String, int>? get actionCounts {
    final value = _actionCounts;
    if (value == null) return null;
    if (_actionCounts is EqualUnmodifiableMapView) return _actionCounts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'NotificationEngagementMetrics(averageReadTime: $averageReadTime, clickThroughRate: $clickThroughRate, totalClicks: $totalClicks, totalDismissals: $totalDismissals, actionCounts: $actionCounts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationEngagementMetricsImpl &&
            (identical(other.averageReadTime, averageReadTime) ||
                other.averageReadTime == averageReadTime) &&
            (identical(other.clickThroughRate, clickThroughRate) ||
                other.clickThroughRate == clickThroughRate) &&
            (identical(other.totalClicks, totalClicks) ||
                other.totalClicks == totalClicks) &&
            (identical(other.totalDismissals, totalDismissals) ||
                other.totalDismissals == totalDismissals) &&
            const DeepCollectionEquality().equals(
              other._actionCounts,
              _actionCounts,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    averageReadTime,
    clickThroughRate,
    totalClicks,
    totalDismissals,
    const DeepCollectionEquality().hash(_actionCounts),
  );

  /// Create a copy of NotificationEngagementMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationEngagementMetricsImplCopyWith<
    _$NotificationEngagementMetricsImpl
  >
  get copyWith =>
      __$$NotificationEngagementMetricsImplCopyWithImpl<
        _$NotificationEngagementMetricsImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationEngagementMetricsImplToJson(this);
  }
}

abstract class _NotificationEngagementMetrics
    implements NotificationEngagementMetrics {
  const factory _NotificationEngagementMetrics({
    required final double averageReadTime,
    required final double clickThroughRate,
    required final int totalClicks,
    required final int totalDismissals,
    final Map<String, int>? actionCounts,
  }) = _$NotificationEngagementMetricsImpl;

  factory _NotificationEngagementMetrics.fromJson(Map<String, dynamic> json) =
      _$NotificationEngagementMetricsImpl.fromJson;

  @override
  double get averageReadTime;
  @override
  double get clickThroughRate;
  @override
  int get totalClicks;
  @override
  int get totalDismissals;
  @override
  Map<String, int>? get actionCounts;

  /// Create a copy of NotificationEngagementMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationEngagementMetricsImplCopyWith<
    _$NotificationEngagementMetricsImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

CreateNotificationRequest _$CreateNotificationRequestFromJson(
  Map<String, dynamic> json,
) {
  return _CreateNotificationRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateNotificationRequest {
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  NotificationType get type => throw _privateConstructorUsedError;
  NotificationPriority? get priority => throw _privateConstructorUsedError;
  List<String>? get recipients => throw _privateConstructorUsedError;
  List<NotificationAction>? get actions => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get deepLink => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  DateTime? get scheduledAt => throw _privateConstructorUsedError;
  bool get isPersistent => throw _privateConstructorUsedError;

  /// Serializes this CreateNotificationRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateNotificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateNotificationRequestCopyWith<CreateNotificationRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateNotificationRequestCopyWith<$Res> {
  factory $CreateNotificationRequestCopyWith(
    CreateNotificationRequest value,
    $Res Function(CreateNotificationRequest) then,
  ) = _$CreateNotificationRequestCopyWithImpl<$Res, CreateNotificationRequest>;
  @useResult
  $Res call({
    String title,
    String content,
    NotificationType type,
    NotificationPriority? priority,
    List<String>? recipients,
    List<NotificationAction>? actions,
    String? imageUrl,
    String? deepLink,
    Map<String, dynamic>? metadata,
    DateTime? expiresAt,
    DateTime? scheduledAt,
    bool isPersistent,
  });
}

/// @nodoc
class _$CreateNotificationRequestCopyWithImpl<
  $Res,
  $Val extends CreateNotificationRequest
>
    implements $CreateNotificationRequestCopyWith<$Res> {
  _$CreateNotificationRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateNotificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? content = null,
    Object? type = null,
    Object? priority = freezed,
    Object? recipients = freezed,
    Object? actions = freezed,
    Object? imageUrl = freezed,
    Object? deepLink = freezed,
    Object? metadata = freezed,
    Object? expiresAt = freezed,
    Object? scheduledAt = freezed,
    Object? isPersistent = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as NotificationType,
            priority: freezed == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as NotificationPriority?,
            recipients: freezed == recipients
                ? _value.recipients
                : recipients // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            actions: freezed == actions
                ? _value.actions
                : actions // ignore: cast_nullable_to_non_nullable
                      as List<NotificationAction>?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            deepLink: freezed == deepLink
                ? _value.deepLink
                : deepLink // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            scheduledAt: freezed == scheduledAt
                ? _value.scheduledAt
                : scheduledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isPersistent: null == isPersistent
                ? _value.isPersistent
                : isPersistent // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateNotificationRequestImplCopyWith<$Res>
    implements $CreateNotificationRequestCopyWith<$Res> {
  factory _$$CreateNotificationRequestImplCopyWith(
    _$CreateNotificationRequestImpl value,
    $Res Function(_$CreateNotificationRequestImpl) then,
  ) = __$$CreateNotificationRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String content,
    NotificationType type,
    NotificationPriority? priority,
    List<String>? recipients,
    List<NotificationAction>? actions,
    String? imageUrl,
    String? deepLink,
    Map<String, dynamic>? metadata,
    DateTime? expiresAt,
    DateTime? scheduledAt,
    bool isPersistent,
  });
}

/// @nodoc
class __$$CreateNotificationRequestImplCopyWithImpl<$Res>
    extends
        _$CreateNotificationRequestCopyWithImpl<
          $Res,
          _$CreateNotificationRequestImpl
        >
    implements _$$CreateNotificationRequestImplCopyWith<$Res> {
  __$$CreateNotificationRequestImplCopyWithImpl(
    _$CreateNotificationRequestImpl _value,
    $Res Function(_$CreateNotificationRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateNotificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? content = null,
    Object? type = null,
    Object? priority = freezed,
    Object? recipients = freezed,
    Object? actions = freezed,
    Object? imageUrl = freezed,
    Object? deepLink = freezed,
    Object? metadata = freezed,
    Object? expiresAt = freezed,
    Object? scheduledAt = freezed,
    Object? isPersistent = null,
  }) {
    return _then(
      _$CreateNotificationRequestImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as NotificationType,
        priority: freezed == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as NotificationPriority?,
        recipients: freezed == recipients
            ? _value._recipients
            : recipients // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        actions: freezed == actions
            ? _value._actions
            : actions // ignore: cast_nullable_to_non_nullable
                  as List<NotificationAction>?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        deepLink: freezed == deepLink
            ? _value.deepLink
            : deepLink // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        scheduledAt: freezed == scheduledAt
            ? _value.scheduledAt
            : scheduledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isPersistent: null == isPersistent
            ? _value.isPersistent
            : isPersistent // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateNotificationRequestImpl implements _CreateNotificationRequest {
  const _$CreateNotificationRequestImpl({
    required this.title,
    required this.content,
    required this.type,
    this.priority,
    final List<String>? recipients,
    final List<NotificationAction>? actions,
    this.imageUrl,
    this.deepLink,
    final Map<String, dynamic>? metadata,
    this.expiresAt,
    this.scheduledAt,
    this.isPersistent = false,
  }) : _recipients = recipients,
       _actions = actions,
       _metadata = metadata;

  factory _$CreateNotificationRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateNotificationRequestImplFromJson(json);

  @override
  final String title;
  @override
  final String content;
  @override
  final NotificationType type;
  @override
  final NotificationPriority? priority;
  final List<String>? _recipients;
  @override
  List<String>? get recipients {
    final value = _recipients;
    if (value == null) return null;
    if (_recipients is EqualUnmodifiableListView) return _recipients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<NotificationAction>? _actions;
  @override
  List<NotificationAction>? get actions {
    final value = _actions;
    if (value == null) return null;
    if (_actions is EqualUnmodifiableListView) return _actions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? imageUrl;
  @override
  final String? deepLink;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? expiresAt;
  @override
  final DateTime? scheduledAt;
  @override
  @JsonKey()
  final bool isPersistent;

  @override
  String toString() {
    return 'CreateNotificationRequest(title: $title, content: $content, type: $type, priority: $priority, recipients: $recipients, actions: $actions, imageUrl: $imageUrl, deepLink: $deepLink, metadata: $metadata, expiresAt: $expiresAt, scheduledAt: $scheduledAt, isPersistent: $isPersistent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateNotificationRequestImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality().equals(
              other._recipients,
              _recipients,
            ) &&
            const DeepCollectionEquality().equals(other._actions, _actions) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.deepLink, deepLink) ||
                other.deepLink == deepLink) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.scheduledAt, scheduledAt) ||
                other.scheduledAt == scheduledAt) &&
            (identical(other.isPersistent, isPersistent) ||
                other.isPersistent == isPersistent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    content,
    type,
    priority,
    const DeepCollectionEquality().hash(_recipients),
    const DeepCollectionEquality().hash(_actions),
    imageUrl,
    deepLink,
    const DeepCollectionEquality().hash(_metadata),
    expiresAt,
    scheduledAt,
    isPersistent,
  );

  /// Create a copy of CreateNotificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateNotificationRequestImplCopyWith<_$CreateNotificationRequestImpl>
  get copyWith =>
      __$$CreateNotificationRequestImplCopyWithImpl<
        _$CreateNotificationRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateNotificationRequestImplToJson(this);
  }
}

abstract class _CreateNotificationRequest implements CreateNotificationRequest {
  const factory _CreateNotificationRequest({
    required final String title,
    required final String content,
    required final NotificationType type,
    final NotificationPriority? priority,
    final List<String>? recipients,
    final List<NotificationAction>? actions,
    final String? imageUrl,
    final String? deepLink,
    final Map<String, dynamic>? metadata,
    final DateTime? expiresAt,
    final DateTime? scheduledAt,
    final bool isPersistent,
  }) = _$CreateNotificationRequestImpl;

  factory _CreateNotificationRequest.fromJson(Map<String, dynamic> json) =
      _$CreateNotificationRequestImpl.fromJson;

  @override
  String get title;
  @override
  String get content;
  @override
  NotificationType get type;
  @override
  NotificationPriority? get priority;
  @override
  List<String>? get recipients;
  @override
  List<NotificationAction>? get actions;
  @override
  String? get imageUrl;
  @override
  String? get deepLink;
  @override
  Map<String, dynamic>? get metadata;
  @override
  DateTime? get expiresAt;
  @override
  DateTime? get scheduledAt;
  @override
  bool get isPersistent;

  /// Create a copy of CreateNotificationRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateNotificationRequestImplCopyWith<_$CreateNotificationRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
